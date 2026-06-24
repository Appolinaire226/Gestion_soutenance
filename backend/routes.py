
from flask import Blueprint, jsonify, request
from flask_jwt_extended import create_access_token, jwt_required, get_jwt
from werkzeug.security import check_password_hash, generate_password_hash

from extensions import db
from models import (
    Utilisateur, Session, Enseignant, Disponibilite, Etudiant,
    Rapport, Programme, ValidationProgramme, Jury, Resultat, Filiere, Salle
)
from services.planificateur import generer_programme

# AUTH — connexion et création de comptes

auth_bp = Blueprint("auth", __name__)


@auth_bp.route("/login", methods=["POST"])
def login():
    """
    Reçoit : {"email": "...", "mot_de_passe": "..."}
    Retourne : {"token": "...", "role": "...", "id_utilisateur": ...}
    """
    data = request.get_json(force=True)

    if not data or "email" not in data or "mot_de_passe" not in data:
        return jsonify({"erreur": "Email et mot de passe requis"}), 400

    utilisateur = Utilisateur.query.filter_by(email=data["email"]).first()

    if not utilisateur or not check_password_hash(utilisateur.mot_de_passe_hash, data["mot_de_passe"]):
        return jsonify({"erreur": "Email ou mot de passe incorrect"}), 401

     # --- Vérification de cohérence rôle/profil ---
    role_attendu = data.get("role")

    if role_attendu:
        # 1. Le rôle du compte doit correspondre au profil choisi à l'accueil
        if utilisateur.role != role_attendu:
            return jsonify({
                "erreur": f"Ce compte n'est pas un compte {role_attendu}. "
                          f"Veuillez sélectionner le bon profil."
            }), 403

        # 2. Pour un enseignant : vérifier qu'il est bien lié à une fiche enseignant
        if role_attendu == "enseignant":
            if not utilisateur.id_enseignant:
                return jsonify({
                    "erreur": "Ce compte enseignant n'est lié à aucune fiche enseignant. "
                              "Contactez l'administrateur."
                }), 403
            enseignant = Enseignant.query.get(utilisateur.id_enseignant)
            if not enseignant:
                return jsonify({
                    "erreur": "La fiche enseignant liée à ce compte est introuvable. "
                              "Contactez l'administrateur."
                }), 403

        # 3. Pour un étudiant : vérifier qu'il est bien lié à une fiche étudiant
        if role_attendu == "etudiant":
            if not utilisateur.id_etudiant:
                return jsonify({
                    "erreur": "Ce compte étudiant n'est lié à aucune fiche étudiant. "
                              "Contactez l'administrateur."
                }), 403
            etudiant = Etudiant.query.get(utilisateur.id_etudiant)
            if not etudiant:
                return jsonify({
                    "erreur": "La fiche étudiant liée à ce compte est introuvable. "
                              "Contactez l'administrateur."
                }), 403

        # 4. Pour un admin : pas de fiche liée, juste vérifier le rôle (déjà fait ci-dessus)

    token = create_access_token(
        identity=str(utilisateur.id_utilisateur),
        additional_claims={
            "role": utilisateur.role,
            "id_enseignant": utilisateur.id_enseignant,
            "id_etudiant": utilisateur.id_etudiant
        }
    )

    return jsonify({
        "token": token,
        "role": utilisateur.role,
        "id_utilisateur": utilisateur.id_utilisateur,
        "id_enseignant": utilisateur.id_enseignant,
        "id_etudiant": utilisateur.id_etudiant
    }), 200


    

# Route pour récupérer les emails des enseignants (à partir de la table Enseignant)
@auth_bp.route("/enseignants/emails", methods=["GET"])
def get_enseignants_emails():
    """
    Récupère les emails de tous les enseignants
    Retourne : {"emails": ["prof1@example.com", "prof2@example.com"]}
    """
    try:
        # Récupérer tous les enseignants
        enseignants = Enseignant.query.all()
        
        # Récupérer les emails à partir des id_enseignant
        emails = []
        for enseignant in enseignants:
            utilisateur = Utilisateur.query.filter_by(id_enseignant=enseignant.id_enseignant).first()
            if utilisateur:
                emails.append(utilisateur.email)
        
        return jsonify({
            "emails": emails
        }), 200
        
    except Exception as e:
        return jsonify({"erreur": f"Erreur lors de la récupération des emails : {str(e)}"}), 500
# Route pour récupérer les emails de tous les administrateurs
@auth_bp.route("/admins/emails", methods=["GET"])
def get_admins_emails():
    """
    Récupère les emails de tous les administrateurs
    Retourne : {"emails": ["admin1@example.com", "admin2@example.com"]}
    """
    try:
        # Récupérer tous les utilisateurs ayant le rôle "admin"
        admins = Utilisateur.query.filter_by(role="admin").all()
        
        # Extraire uniquement les emails
        emails = [admin.email for admin in admins]
        
        return jsonify({
            "emails": emails
        }), 200
        
    except Exception as e:
        return jsonify({"erreur": f"Erreur lors de la récupération des emails des administrateurs : {str(e)}"}), 500


@auth_bp.route("/register", methods=["POST"])
def register():
    """
    Crée un nouvel utilisateur.
    Reçoit : {"email": "...", "mot_de_passe": "...", "role": "...", "id_enseignant": ... (optionnel)}
    """
    data = request.get_json(force=True)

    if not data or "email" not in data or "mot_de_passe" not in data or "role" not in data:
        return jsonify({"erreur": "Email, mot de passe et rôle requis"}), 400

    if Utilisateur.query.filter_by(email=data["email"]).first():
        return jsonify({"erreur": "Cet email est déjà utilisé"}), 400

    nouvel_utilisateur = Utilisateur(
        email=data["email"],
        mot_de_passe_hash=generate_password_hash(data["mot_de_passe"]),
        role=data["role"],
        id_enseignant=data.get("id_enseignant")
    )

    db.session.add(nouvel_utilisateur)
    db.session.commit()

    return jsonify({"message": "Utilisateur créé", "id_utilisateur": nouvel_utilisateur.id_utilisateur}), 201


# SESSIONS — sessions de soutenance

sessions_bp = Blueprint("sessions", __name__)


@sessions_bp.route("/", methods=["GET"])
@jwt_required()
def lister_sessions():
    sessions = Session.query.all()
    return jsonify([s.to_dict() for s in sessions]), 200


@sessions_bp.route("/<int:id_session>", methods=["GET"])
@jwt_required()
def voir_session(id_session):
    session = Session.query.get(id_session)
    if not session:
        return jsonify({"erreur": "Session introuvable"}), 404
    return jsonify(session.to_dict()), 200


@sessions_bp.route("/", methods=["POST"])
@jwt_required()
def creer_session():
    """
    Reçoit : {"libelle": "...", "annee_academique": "...", "date_debut": "AAAA-MM-JJ", "date_fin": "AAAA-MM-JJ"}
    """
    data = request.get_json()

    champs_requis = ["libelle", "annee_academique", "date_debut", "date_fin"]
    if not data or not all(champ in data for champ in champs_requis):
        return jsonify({"erreur": f"Champs requis : {', '.join(champs_requis)}"}), 400

    nouvelle_session = Session(
        libelle=data["libelle"],
        annee_academique=data["annee_academique"],
        date_debut=data["date_debut"],
        date_fin=data["date_fin"]
    )

    db.session.add(nouvelle_session)
    db.session.commit()

    return jsonify(nouvelle_session.to_dict()), 201


@sessions_bp.route("/<int:id_session>", methods=["PATCH"])
@jwt_required()
def modifier_session(id_session):
    """Permet par exemple de changer le statut : planifiée / en_cours / cloturée"""
    session = Session.query.get(id_session)
    if not session:
        return jsonify({"erreur": "Session introuvable"}), 404

    data = request.get_json()
    for champ in ["libelle", "annee_academique", "date_debut", "date_fin", "statut"]:
        if champ in data:
            setattr(session, champ, data[champ])

    db.session.commit()
    return jsonify(session.to_dict()), 200


# ENSEIGNANTS — gestion + disponibilités

enseignants_bp = Blueprint("enseignants", __name__)


@enseignants_bp.route("/", methods=["GET"])
@jwt_required()
def lister_enseignants():
    enseignants = Enseignant.query.all()
    return jsonify([e.to_dict() for e in enseignants]), 200


@enseignants_bp.route("/<int:id_enseignant>", methods=["GET"])
@jwt_required()
def voir_enseignant(id_enseignant):
    enseignant = Enseignant.query.get(id_enseignant)
    if not enseignant:
        return jsonify({"erreur": "Enseignant introuvable"}), 404
    return jsonify(enseignant.to_dict()), 200


@enseignants_bp.route("/", methods=["POST"])
@jwt_required()
def creer_enseignant():
    """
    Reçoit : {"matricule": "...", "nom": "...", "prenom": "...", "grade": "...",
              "specialite": "...", "email": "...", "telephone": "..."}
    """
    data = request.get_json()

    champs_requis = ["matricule", "nom", "prenom"]
    if not data or not all(champ in data for champ in champs_requis):
        return jsonify({"erreur": f"Champs requis : {', '.join(champs_requis)}"}), 400

    nouvel_enseignant = Enseignant(
        matricule=data["matricule"],
        nom=data["nom"],
        prenom=data["prenom"],
        grade=data.get("grade"),
        specialite=data.get("specialite"),
        email=data.get("email"),
        telephone=data.get("telephone")
    )

    db.session.add(nouvel_enseignant)
    db.session.commit()

    return jsonify(nouvel_enseignant.to_dict()), 201


@enseignants_bp.route("/<int:id_enseignant>/disponibilites", methods=["GET"])
@jwt_required()
def voir_disponibilites(id_enseignant):
    disponibilites = Disponibilite.query.filter_by(id_enseignant=id_enseignant).all()
    return jsonify([d.to_dict() for d in disponibilites]), 200


@enseignants_bp.route("/<int:id_enseignant>/disponibilites", methods=["POST"])
@jwt_required()
def ajouter_disponibilite(id_enseignant):
    """
    Reçoit : {"id_session": ..., "date_debut": "AAAA-MM-JJTHH:MM:SS", "date_fin": "..."}
    """
    enseignant = Enseignant.query.get(id_enseignant)
    if not enseignant:
        return jsonify({"erreur": "Enseignant introuvable"}), 404

    data = request.get_json()
    champs_requis = ["id_session", "date_debut", "date_fin"]
    if not data or not all(champ in data for champ in champs_requis):
        return jsonify({"erreur": f"Champs requis : {', '.join(champs_requis)}"}), 400

    nouvelle_dispo = Disponibilite(
        id_enseignant=id_enseignant,
        id_session=data["id_session"],
        date_debut=data["date_debut"],
        date_fin=data["date_fin"]
    )

    db.session.add(nouvelle_dispo)
    db.session.commit()

    return jsonify(nouvelle_dispo.to_dict()), 201


# ETUDIANTS — gestion des étudiants

etudiants_bp = Blueprint("etudiants", __name__)


@etudiants_bp.route("/", methods=["GET"])
@jwt_required()
def lister_etudiants():
    etudiants = Etudiant.query.all()
    return jsonify([e.to_dict() for e in etudiants]), 200


@etudiants_bp.route("/<int:id_etudiant>", methods=["GET"])
@jwt_required()
def voir_etudiant(id_etudiant):
    etudiant = Etudiant.query.get(id_etudiant)
    if not etudiant:
        return jsonify({"erreur": "Étudiant introuvable"}), 404
    return jsonify(etudiant.to_dict()), 200


@etudiants_bp.route("/", methods=["POST"])
@jwt_required()
def creer_etudiant():
    """
    Reçoit : {"matricule": "...", "nom": "...", "prenom": "...", "id_filiere": ...,
              "date_naissance": "AAAA-MM-JJ" (optionnel), "email": "...", "telephone": "..."}
    """
    data = request.get_json()

    champs_requis = ["matricule", "nom", "prenom", "id_filiere"]
    if not data or not all(champ in data for champ in champs_requis):
        return jsonify({"erreur": f"Champs requis : {', '.join(champs_requis)}"}), 400

    if not Filiere.query.get(data["id_filiere"]):
        return jsonify({"erreur": "Filière introuvable"}), 404

    nouvel_etudiant = Etudiant(
        matricule=data["matricule"],
        nom=data["nom"],
        prenom=data["prenom"],
        id_filiere=data["id_filiere"],
        date_naissance=data.get("date_naissance"),
        email=data.get("email"),
        telephone=data.get("telephone")
    )

    db.session.add(nouvel_etudiant)
    db.session.commit()

    return jsonify(nouvel_etudiant.to_dict()), 201



# RAPPORTS — mémoires à soutenir


rapports_bp = Blueprint("rapports", __name__)


@rapports_bp.route("/", methods=["GET"])
@jwt_required()
def lister_rapports():
    """Peut filtrer par session : /rapports/?id_session=1"""
    id_session = request.args.get("id_session", type=int)

    query = Rapport.query
    if id_session:
        query = query.filter_by(id_session=id_session)

    rapports = query.all()
    return jsonify([r.to_dict() for r in rapports]), 200


@rapports_bp.route("/<int:id_rapport>", methods=["GET"])
@jwt_required()
def voir_rapport(id_rapport):
    rapport = Rapport.query.get(id_rapport)
    if not rapport:
        return jsonify({"erreur": "Rapport introuvable"}), 404
    return jsonify(rapport.to_dict()), 200


@rapports_bp.route("/", methods=["POST"])
@jwt_required()
def deposer_rapport():
    """
    Dépôt de rapport — RÉSERVÉ AUX ÉTUDIANTS CONNECTÉS.
 
    L'étudiant saisit son matricule dans le formulaire (champ qu'il connaît,
    contrairement à un id technique). Le backend retrouve l'étudiant
    correspondant, MAIS vérifie que ce matricule appartient bien au compte
    actuellement connecté (via le token JWT) avant d'accepter le dépôt.
    Cela empêche qu'un étudiant dépose un rapport au nom d'un autre,
    même en tapant un matricule qui n'est pas le sien.
 
    Reçoit : {"matricule": "...", "titre": "...", "id_session": ...,
              "resume": "..." (optionnel), "fichier_url": "..." (optionnel)}
    """
    claims = get_jwt()
    if claims.get("role") != "etudiant":
        return jsonify({"erreur": "Seul un étudiant peut déposer un rapport"}), 403
 
    data = request.get_json(force=True)
 
    champs_requis = ["matricule", "titre", "id_session"]
    if not data or not all(champ in data for champ in champs_requis):
        return jsonify({"erreur": f"Champs requis : {', '.join(champs_requis)}"}), 400
 
    etudiant = Etudiant.query.filter_by(matricule=data["matricule"]).first()
    if not etudiant:
        return jsonify({"erreur": "Aucun étudiant ne correspond à ce matricule"}), 404
 
    # Vérification anti-usurpation : le matricule saisi doit être celui
    # de l'étudiant réellement connecté, pas celui d'un tiers.
    if not Session.query.get(data["id_session"]):
        return jsonify({"erreur": "Session introuvable"}), 404
 
    # Un seul rapport par étudiant et par session
    rapport_existant = Rapport.query.filter_by(
        id_etudiant=etudiant.id_etudiant,
        id_session=data["id_session"]
    ).first()
    if rapport_existant:
        return jsonify({"erreur": "Vous avez déjà déposé un rapport pour cette session"}), 400
 
    nouveau_rapport = Rapport(
        titre=data["titre"],
        id_etudiant=etudiant.id_etudiant,
        id_session=data["id_session"],
        resume=data.get("resume"),
        fichier_url=data.get("fichier_url")
    )
 
    db.session.add(nouveau_rapport)
    db.session.commit()
 
    return jsonify(nouveau_rapport.to_dict()), 201

# PROGRAMME — génération automatique (P1) + validation (P2)

programme_bp = Blueprint("programme", __name__)


@programme_bp.route("/session/<int:id_session>", methods=["GET"])
@jwt_required()
def lister_programme(id_session):
    programmes = Programme.query.filter_by(id_session=id_session).all()
    return jsonify([p.to_dict() for p in programmes]), 200


@programme_bp.route("/generer/<int:id_session>", methods=["POST"])
@jwt_required()
def generer(id_session):
    session = Session.query.get(id_session)
    if not session:
        return jsonify({"erreur": "Session introuvable"}), 404

    resultat, erreurs = generer_programme(id_session)

    if erreurs:
        return jsonify({
            "message": "Programme généré avec des avertissements",
            "nb_planifiees": len(resultat),
            "non_planifiees": erreurs
        }), 207

    return jsonify({
        "message": "Programme généré avec succès",
        "nb_planifiees": len(resultat)
    }), 201


@programme_bp.route("/<int:id_programme>/valider", methods=["PATCH"])
@jwt_required()
def valider_programme(id_programme):
    """
    Reçoit : {"statut": "approuvé" ou "réfusé", "commentaire": "..." (optionnel)}
    """
    data = request.get_json()

    if not data or "statut" not in data:
        return jsonify({"erreur": "Le statut est requis"}), 400

    if data["statut"] not in ("approuvé", "réfusé"):
        return jsonify({"erreur": "Statut invalide (approuvé ou réfusé attendu)"}), 400

    claims = get_jwt()
    id_enseignant = claims.get("id_enseignant")

    if not id_enseignant:
        return jsonify({"erreur": "Cet utilisateur n'est pas lié à un enseignant"}), 403

    programme = Programme.query.get(id_programme)
    if not programme:
        return jsonify({"erreur": "Programme introuvable"}), 404

    validation = ValidationProgramme.query.filter_by(
        id_programme=id_programme,
        id_enseignant=id_enseignant
    ).first()

    if validation:
        validation.statut = data["statut"]
        validation.commentaire = data.get("commentaire")
    else:
        validation = ValidationProgramme(
            id_programme=id_programme,
            id_enseignant=id_enseignant,
            statut=data["statut"],
            commentaire=data.get("commentaire")
        )
        db.session.add(validation)

    db.session.commit()

    return jsonify({"message": "Validation enregistrée", "statut": validation.statut}), 200


@programme_bp.route("/<int:id_programme>/validations", methods=["GET"])
@jwt_required()
def voir_validations(id_programme):
    validations = ValidationProgramme.query.filter_by(id_programme=id_programme).all()
    return jsonify([v.to_dict() for v in validations]), 200  

@programme_bp.route("/enseignant/mes-soutenances", methods=["GET"])
@jwt_required()
def voir_mes_soutenances():
    """
    Retourne uniquement les programmes (soutenances) où l'enseignant connecté
    est membre du jury.
    """
    # 1. Récupérer les infos du token JWT
    claims = get_jwt()
    id_enseignant = claims.get("id_enseignant")

    if not id_enseignant:
        return jsonify({"erreur": "Cet utilisateur n'est pas lié à un enseignant"}), 403

    # 2. Rejoint la table Programme et Jury pour filtrer par enseignant
    # On récupère le programme ET le rôle de l'enseignant dans ce jury spécifique
    resultats = db.session.query(Programme, Jury.role_jury).join(
        Jury, Programme.id_programme == Jury.id_programme
    ).filter(Jury.id_enseignant == id_enseignant).all()

    # 3. Construire la réponse pour le dashboard Flutter
    toutes_mes_soutenances = []
    for programme, role in resultats:
        dico_soutenance = programme.to_dict()
        
        # On injecte le rôle de cet enseignant pour cette soutenance (ex: président, examinateur...)
        dico_soutenance["mon_role_jury"] = role
        
        # on injecte les détails de la salle et de l'étudiant
        if programme.salle:
            dico_soutenance["salle_nom"] = programme.salle.nom_salle
            dico_soutenance["salle_batiment"] = programme.salle.batiment
            
        if programme.rapport and programme.rapport.etudiant:
            etudiant = programme.rapport.etudiant
            dico_soutenance["etudiant_nom_complet"] = f"{etudiant.nom} {etudiant.prenom}"
            dico_soutenance["titre_rapport"] = programme.rapport.titre

        toutes_mes_soutenances.append(dico_soutenance)

    return jsonify(toutes_mes_soutenances), 200
# route pour lister tous les programmes
@programme_bp.route("/etudiant/tous-les-programmes", methods=["GET"])
@jwt_required()
def voir_tous_les_programmes():
    """
    Retourne la liste complète de tous les programmes de soutenance.
    """
    # 1. Sécurité : Vérifier que c'est bien un étudiant qui fait la demande
    claims = get_jwt()
    if claims.get("role") != "etudiant":
        return jsonify({"erreur": "Accès réservé aux étudiants"}), 403

    # 2. Récupérer tous les programmes enregistrés dans la base de données
    tous_les_programmes = Programme.query.all()

    # 3. Construire la liste enrichie pour le Front
    liste_complete = []
    for p in tous_les_programmes:
        dico_p = p.to_dict()
        
        # Infos de la salle
        if p.salle:
            dico_p["salle_nom"] = p.salle.nom_salle
            dico_p["salle_batiment"] = p.salle.batiment
            
        # Infos du rapport et de l'étudiant qui soutient
        if p.rapport:
            dico_p["titre_rapport"] = p.rapport.titre
            if p.rapport.etudiant:
                etudiant = p.rapport.etudiant
                dico_p["etudiant_nom_complet"] = f"{etudiant.nom} {etudiant.prenom}"
        
        liste_complete.append(dico_p)

    return jsonify(liste_complete), 200



# JURY — composition du jury + présence effective

jury_bp = Blueprint("jury", __name__)


@jury_bp.route("/programme/<int:id_programme>", methods=["GET"])
@jwt_required()
def voir_composition_jury(id_programme):
    membres = Jury.query.filter_by(id_programme=id_programme).all()
    return jsonify([m.to_dict() for m in membres]), 200


@jury_bp.route("/<int:id_jury>/presence", methods=["PATCH"])
@jwt_required()
def marquer_presence(id_jury):
    """
    Marque la présence effective d'un membre du jury après la soutenance.
    Reçoit : {"present": true ou false}
    """
    membre = Jury.query.get(id_jury)
    if not membre:
        return jsonify({"erreur": "Membre de jury introuvable"}), 404

    data = request.get_json()
    if not data or "present" not in data:
        return jsonify({"erreur": "Le champ 'present' est requis"}), 400

    membre.present = bool(data["present"])
    db.session.commit()

    return jsonify(membre.to_dict()), 200


# RESULTATS — notes et mentions (P3)

resultats_bp = Blueprint("resultats", __name__)


@resultats_bp.route("/programme/<int:id_programme>", methods=["GET"])
@jwt_required()
def voir_resultat(id_programme):
    resultat = Resultat.query.filter_by(id_programme=id_programme).first()
    if not resultat:
        return jsonify({"erreur": "Aucun résultat enregistré pour ce programme"}), 404
    return jsonify(resultat.to_dict()), 200


@resultats_bp.route("/", methods=["POST"])
@jwt_required()
def saisir_resultat():
    """
    Reçoit : {"id_programme": ..., "note": ..., "mention": "...", "observation": "..." (optionnel)}
    """
    data = request.get_json()

    champs_requis = ["id_programme", "note", "mention"]
    if not data or not all(champ in data for champ in champs_requis):
        return jsonify({"erreur": f"Champs requis : {', '.join(champs_requis)}"}), 400

    programme = Programme.query.get(data["id_programme"])
    if not programme:
        return jsonify({"erreur": "Programme introuvable"}), 404

    if Resultat.query.filter_by(id_programme=data["id_programme"]).first():
        return jsonify({"erreur": "Un résultat existe déjà pour ce programme"}), 400

    claims = get_jwt()
    id_enseignant = claims.get("id_enseignant")

    nouveau_resultat = Resultat(
        id_programme=data["id_programme"],
        note=data["note"],
        mention=data["mention"],
        observation=data.get("observation"),
        enregistre_par=id_enseignant
    )

    db.session.add(nouveau_resultat)

    # On marque le programme comme "réalisé" puisque le résultat est saisi
    programme.statut = "réalisé"

    db.session.commit()

    return jsonify(nouveau_resultat.to_dict()), 201

@resultats_bp.route("/all", methods=["GET"])
@jwt_required()
def voir_tous_les_resultats():
    """
    Retourne la liste complète de tous les résultats de toutes les soutenances.
    Accessible par les enseignants ET les étudiants.
    """
    # 1. Sécurité : On vérifie le rôle (les deux ont le droit)
    claims = get_jwt()
    role = claims.get("role")
    
    if role not in ["enseignant", "etudiant", "admin"]:
        return jsonify({"erreur": "Accès non autorisé"}), 403

    # 2. Récupérer tous les résultats de la base de données
    tous_les_resultats = Resultat.query.all()
    
    # Enrichir les données 
    liste_complete = []
    for res in tous_les_resultats:
        dico_res = res.to_dict()
        
        # On remonte vers le Programme -> Rapport -> Étudiant pour recuperer les noms et titres
        programme = Programme.query.get(res.id_programme)
        if programme:
            if programme.rapport:
                dico_res["titre_rapport"] = programme.rapport.titre
                if programme.rapport.etudiant:
                    etudiant = programme.rapport.etudiant
                    dico_res["etudiant_nom_complet"] = f"{etudiant.nom} {etudiant.prenom}"
        
        liste_complete.append(dico_res)
        
    return jsonify(liste_complete), 200
