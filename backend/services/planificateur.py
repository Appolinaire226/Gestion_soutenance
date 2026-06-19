"""
services/planificateur.py
Algorithme de génération automatique du programme de soutenance (P1 du sujet).

Principe (glouton simple) :
  Pour chaque rapport à soutenir, on cherche un créneau de disponibilité
  partagé entre au moins 2 enseignants, et une salle libre à ce moment-là.
  On affecte, on marque les ressources occupées, on passe au suivant.

Limite assumée :  Si un rapport ne trouve aucun
créneau valide, il est simplement signalé comme "non planifié" plutôt
que de tout recalculer en arrière. C'est une simplification raisonnable
pour un projet académique.
"""

from datetime import timedelta
from extensions import db
from models import Rapport, Disponibilite, Salle, Programme, Jury


def generer_programme(id_session):
    """
    Génère le programme pour tous les rapports d'une session donnée.

    Retourne :
        (programmes_crees, erreurs)
        - programmes_crees : liste des Programme créés
        - erreurs : liste de messages pour les rapports non planifiés
    """

    # Récupérer les rapports à soutenir pour cette session
    rapports = Rapport.query.filter_by(id_session=id_session, statut="déposé").all()

    # Récupérer toutes les disponibilités des enseignants pour cette session
    disponibilites = Disponibilite.query.filter_by(id_session=id_session).all()

    # Récupérer toutes les salles
    salles = Salle.query.all()

    # Mémoriser ce qui est déjà occupé pendant la génération
    creneaux_enseignants = {}
    creneaux_salles = {}

    programmes_crees = []
    erreurs = []

    DUREE_SOUTENANCE = timedelta(minutes=45)
    NB_MEMBRES_JURY = 2  # simplification : 2 enseignants par jury

    for rapport in rapports:
        creneau_trouve = None
        salle_trouvee = None
        enseignants_choisis = []

        # Chercher un créneau commun à au moins NB_MEMBRES_JURY enseignants
        for dispo in disponibilites:
            debut_test = dispo.date_debut
            fin_test = debut_test + DUREE_SOUTENANCE

            if fin_test > dispo.date_fin:
                continue  # le créneau ne rentre pas dans cette disponibilité

            # Vérifier que cet enseignant n'est pas déjà occupé sur ce créneau
            occupations = creneaux_enseignants.get(dispo.id_enseignant, [])
            conflit = any(
                debut_test < fin_occ and fin_test > debut_occ
                for (debut_occ, fin_occ) in occupations
            )
            if conflit:
                continue

            # Trouver une salle libre sur ce créneau
            for salle in salles:
                occ_salle = creneaux_salles.get(salle.id_salle, [])
                conflit_salle = any(
                    debut_test < fin_occ and fin_test > debut_occ
                    for (debut_occ, fin_occ) in occ_salle
                )
                if not conflit_salle:
                    salle_trouvee = salle
                    break

            if salle_trouvee and dispo.id_enseignant not in enseignants_choisis:
                enseignants_choisis.append(dispo.id_enseignant)
                creneau_trouve = (debut_test, fin_test)

            if len(enseignants_choisis) >= NB_MEMBRES_JURY and salle_trouvee:
                break

        # Si on n'a pas trouvé assez d'enseignants ou pas de salle
        if len(enseignants_choisis) < NB_MEMBRES_JURY or not creneau_trouve or not salle_trouvee:
            erreurs.append(f"Rapport '{rapport.titre}' (id={rapport.id_rapport}) non planifié : "
                            f"pas assez de disponibilités communes ou pas de salle libre")
            continue

        debut, fin = creneau_trouve

        # Créer le programme
        nouveau_programme = Programme(
            id_session=id_session,
            id_rapport=rapport.id_rapport,
            id_salle=salle_trouvee.id_salle,
            date_heure=debut,
            duree_minutes=45,
            statut="proposé"
        )
        db.session.add(nouveau_programme)
        db.session.flush()  # pour obtenir nouveau_programme.id_programme tout de suite

        # Créer les entrées du jury (1 président, le reste membres)
        for i, id_enseignant in enumerate(enseignants_choisis):
            role = "président" if i == 0 else "examinateur"
            membre_jury = Jury(
                id_programme=nouveau_programme.id_programme,
                id_enseignant=id_enseignant,
                role_jury=role,
                present=False
            )
            db.session.add(membre_jury)

        # Marquer les ressources comme occupées
        for id_enseignant in enseignants_choisis:
            creneaux_enseignants.setdefault(id_enseignant, []).append((debut, fin))
        creneaux_salles.setdefault(salle_trouvee.id_salle, []).append((debut, fin))

        programmes_crees.append(nouveau_programme)

    db.session.commit()

    return programmes_crees, erreurs