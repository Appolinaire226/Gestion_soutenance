from flask import Blueprint, jsonify, request
from extensions import db
from models import *
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import timedelta

main_bp = Blueprint('main', __name__)



@main_bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    if not data or not data.get('email') or not data.get('mot_de_passe'):
        return jsonify({'message': 'Email et mot de passe obligatoires'}), 400
    if Utilisateur.query.filter_by(email=data['email']).first():
        return jsonify({'message': 'Email déjà utilisé'}), 400

    u = Utilisateur(
        email=data['email'],
        mot_de_passe_hash=generate_password_hash(data['mot_de_passe']),
        role=data.get('role', 'enseignant'),
    )
    db.session.add(u)
    db.session.flush()

    if u.role == 'enseignant':
        if not data.get('matricule') or not data.get('nom') or not data.get('prenom'):
            return jsonify({'message': 'matricule, nom et prenom obligatoires pour un enseignant'}), 400
        e = Enseignant(
            matricule=data['matricule'],
            nom=data['nom'],
            prenom=data['prenom'],
            grade=data.get('grade'),
            specialite=data.get('specialite'),
            email=data['email'],
            telephone=data.get('telephone'),
            statut='actif'
        )
        db.session.add(e)
        db.session.flush()
        u.id_enseignant = e.id_enseignant

    elif u.role == 'etudiant':
        if not data.get('matricule') or not data.get('nom') or not data.get('prenom') or not data.get('id_filiere'):
            return jsonify({'message': 'matricule, nom, prenom et id_filiere obligatoires pour un etudiant'}), 400
        et = Etudiant(
            matricule=data['matricule'],
            nom=data['nom'],
            prenom=data['prenom'],
            date_naissance=data.get('date_naissance'),
            email=data['email'],
            telephone=data.get('telephone'),
            id_filiere=data['id_filiere']
        )
        db.session.add(et)

    db.session.commit()
    return jsonify({'message': f'Inscription réussie en tant que {u.role}'}), 201

@main_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    if not data or not data.get('email') or not data.get('mot_de_passe'):
        return jsonify({'message': 'Email et mot de passe obligatoires'}), 400
    u = Utilisateur.query.filter_by(email=data['email']).first()
    if not u or not check_password_hash(u.mot_de_passe_hash, data['mot_de_passe']):
        return jsonify({'message': 'Email ou mot de passe incorrect'}), 401
    return jsonify({
        'message': 'Connexion réussie',
        **u.to_dict()
    })



@main_bp.route('/filieres', methods=['GET'])
def get_filieres():
    return jsonify([f.to_dict() for f in Filiere.query.all()])

@main_bp.route('/filieres/<int:id>', methods=['GET'])
def get_filiere(id):
    return jsonify(Filiere.query.get_or_404(id).to_dict())

@main_bp.route('/filieres', methods=['POST'])
def add_filiere():
    data = request.get_json()
    if not data or not data.get('code_filiere') or not data.get('libelle'):
        return jsonify({'message': 'code_filiere et libelle obligatoires'}), 400
    f = Filiere(code_filiere=data['code_filiere'], libelle=data['libelle'])
    db.session.add(f)
    db.session.commit()
    return jsonify({'message': 'Filière ajoutée avec succès'}), 201

@main_bp.route('/filieres/<int:id>', methods=['PUT'])
def update_filiere(id):
    f = Filiere.query.get_or_404(id)
    data = request.get_json()
    f.code_filiere = data.get('code_filiere', f.code_filiere)
    f.libelle = data.get('libelle', f.libelle)
    db.session.commit()
    return jsonify({'message': 'Filière modifiée avec succès'})

@main_bp.route('/filieres/<int:id>', methods=['DELETE'])
def delete_filiere(id):
    f = Filiere.query.get_or_404(id)
    db.session.delete(f)
    db.session.commit()
    return jsonify({'message': 'Filière supprimée avec succès'})



@main_bp.route('/salles', methods=['GET'])
def get_salles():
    return jsonify([s.to_dict() for s in Salle.query.all()])

@main_bp.route('/salles/<int:id>', methods=['GET'])
def get_salle(id):
    return jsonify(Salle.query.get_or_404(id).to_dict())

@main_bp.route('/salles', methods=['POST'])
def add_salle():
    data = request.get_json()
    if not data or not data.get('nom_salle') or not data.get('capacite'):
        return jsonify({'message': 'nom_salle et capacite obligatoires'}), 400
    if data['capacite'] <= 0:
        return jsonify({'message': 'La capacité doit être supérieure à 0'}), 400
    s = Salle(
        nom_salle=data['nom_salle'],
        capacite=data['capacite'],
        batiment=data.get('batiment'),
        equipements=data.get('equipements')
    )
    db.session.add(s)
    db.session.commit()
    return jsonify({'message': 'Salle ajoutée avec succès'}), 201

@main_bp.route('/salles/<int:id>', methods=['PUT'])
def update_salle(id):
    s = Salle.query.get_or_404(id)
    data = request.get_json()
    s.nom_salle = data.get('nom_salle', s.nom_salle)
    s.capacite = data.get('capacite', s.capacite)
    s.batiment = data.get('batiment', s.batiment)
    s.equipements = data.get('equipements', s.equipements)
    db.session.commit()
    return jsonify({'message': 'Salle modifiée avec succès'})

@main_bp.route('/salles/<int:id>', methods=['DELETE'])
def delete_salle(id):
    s = Salle.query.get_or_404(id)
    db.session.delete(s)
    db.session.commit()
    return jsonify({'message': 'Salle supprimée avec succès'})



@main_bp.route('/sessions', methods=['GET'])
def get_sessions():
    return jsonify([s.to_dict() for s in Session.query.all()])

@main_bp.route('/sessions/<int:id>', methods=['GET'])
def get_session(id):
    return jsonify(Session.query.get_or_404(id).to_dict())

@main_bp.route('/sessions', methods=['POST'])
def add_session():
    data = request.get_json()
    if not data or not data.get('libelle') or not data.get('date_debut') or not data.get('date_fin'):
        return jsonify({'message': 'libelle, date_debut et date_fin obligatoires'}), 400
    if data['date_fin'] < data['date_debut']:
        return jsonify({'message': 'date_fin doit être après date_debut'}), 400
    s = Session(
        libelle=data['libelle'],
        annee_academique=data['annee_academique'],
        date_debut=data['date_debut'],
        date_fin=data['date_fin'],
        statut=data.get('statut', 'planifiée')
    )
    db.session.add(s)
    db.session.commit()
    return jsonify({'message': 'Session ajoutée avec succès'}), 201

@main_bp.route('/sessions/<int:id>', methods=['PUT'])
def update_session(id):
    s = Session.query.get_or_404(id)
    data = request.get_json()
    s.libelle = data.get('libelle', s.libelle)
    s.annee_academique = data.get('annee_academique', s.annee_academique)
    s.date_debut = data.get('date_debut', s.date_debut)
    s.date_fin = data.get('date_fin', s.date_fin)
    s.statut = data.get('statut', s.statut)
    db.session.commit()
    return jsonify({'message': 'Session modifiée avec succès'})

@main_bp.route('/sessions/<int:id>', methods=['DELETE'])
def delete_session(id):
    s = Session.query.get_or_404(id)
    db.session.delete(s)
    db.session.commit()
    return jsonify({'message': 'Session supprimée'})

@main_bp.route('/enseignants', methods=['GET'])
def get_enseignants():
    return jsonify([e.to_dict() for e in Enseignant.query.all()])

@main_bp.route('/enseignants/<int:id>', methods=['GET'])
def get_enseignant(id):
    return jsonify(Enseignant.query.get_or_404(id).to_dict())

@main_bp.route('/enseignants/<int:id>', methods=['PUT'])
def update_enseignant(id):
    e = Enseignant.query.get_or_404(id)
    data = request.get_json()
    e.matricule = data.get('matricule', e.matricule)
    e.nom = data.get('nom', e.nom)
    e.prenom = data.get('prenom', e.prenom)
    e.grade = data.get('grade', e.grade)
    e.specialite = data.get('specialite', e.specialite)
    e.email = data.get('email', e.email)
    e.telephone = data.get('telephone', e.telephone)
    e.statut = data.get('statut', e.statut)
    db.session.commit()
    return jsonify({'message': 'Enseignant modifié avec succès'})

@main_bp.route('/enseignants/<int:id>', methods=['DELETE'])
def delete_enseignant(id):
    e = Enseignant.query.get_or_404(id)
    db.session.delete(e)
    db.session.commit()
    return jsonify({'message': 'Enseignant supprimé avec succès'})

@main_bp.route('/etudiants', methods=['GET'])
def get_etudiants():
    return jsonify([e.to_dict() for e in Etudiant.query.all()])

@main_bp.route('/etudiants/<int:id>', methods=['GET'])
def get_etudiant(id):
    return jsonify(Etudiant.query.get_or_404(id).to_dict())

@main_bp.route('/etudiants/<int:id>', methods=['PUT'])
def update_etudiant(id):
    e = Etudiant.query.get_or_404(id)
    data = request.get_json()
    e.matricule = data.get('matricule', e.matricule)
    e.nom = data.get('nom', e.nom)
    e.prenom = data.get('prenom', e.prenom)
    e.date_naissance = data.get('date_naissance', e.date_naissance)
    e.email = data.get('email', e.email)
    e.telephone = data.get('telephone', e.telephone)
    e.id_filiere = data.get('id_filiere', e.id_filiere)
    db.session.commit()
    return jsonify({'message': 'Etudiant modifié avec succès'})

@main_bp.route('/etudiants/<int:id>', methods=['DELETE'])
def delete_etudiant(id):
    e = Etudiant.query.get_or_404(id)
    db.session.delete(e)
    db.session.commit()
    return jsonify({'message': 'Etudiant supprimé avec succès'})



@main_bp.route('/rapports', methods=['GET'])
def get_rapports():
    return jsonify([r.to_dict() for r in Rapport.query.all()])

@main_bp.route('/rapports/<int:id>', methods=['GET'])
def get_rapport(id):
    return jsonify(Rapport.query.get_or_404(id).to_dict())

@main_bp.route('/rapports', methods=['POST'])
def add_rapport():
    data = request.get_json()
    if not data or not data.get('titre') or not data.get('id_etudiant') or not data.get('id_session'):
        return jsonify({'message': 'titre, id_etudiant et id_session obligatoires'}), 400
    r = Rapport(
        titre=data['titre'],
        resume=data.get('resume'),
        fichier_url=data.get('fichier_url'),
        id_etudiant=data['id_etudiant'],
        id_session=data['id_session'],
        statut=data.get('statut', 'déposé')
    )
    db.session.add(r)
    db.session.commit()
    return jsonify({'message': 'Rapport ajouté avec succès'}), 201

@main_bp.route('/rapports/<int:id>', methods=['PUT'])
def update_rapport(id):
    r = Rapport.query.get_or_404(id)
    data = request.get_json()
    r.titre = data.get('titre', r.titre)
    r.resume = data.get('resume', r.resume)
    r.fichier_url = data.get('fichier_url', r.fichier_url)
    r.statut = data.get('statut', r.statut)
    db.session.commit()
    return jsonify({'message': 'Rapport modifié avec succès'})

@main_bp.route('/rapports/<int:id>', methods=['DELETE'])
def delete_rapport(id):
    r = Rapport.query.get_or_404(id)
    db.session.delete(r)
    db.session.commit()
    return jsonify({'message': 'Rapport supprimé avec succès'})


@main_bp.route('/disponibilites', methods=['GET'])
def get_disponibilites():
    return jsonify([d.to_dict() for d in Disponibilite.query.all()])

@main_bp.route('/disponibilites/<int:id>', methods=['GET'])
def get_disponibilite(id):
    return jsonify(Disponibilite.query.get_or_404(id).to_dict())

@main_bp.route('/disponibilites', methods=['POST'])
def add_disponibilite():
    data = request.get_json()
    if not data or not data.get('id_enseignant') or not data.get('id_session') or not data.get('date_debut') or not data.get('date_fin'):
        return jsonify({'message': 'id_enseignant, id_session, date_debut et date_fin obligatoires'}), 400
    if data['date_fin'] <= data['date_debut']:
        return jsonify({'message': 'date_fin doit être après date_debut'}), 400
    d = Disponibilite(
        id_enseignant=data['id_enseignant'],
        id_session=data['id_session'],
        date_debut=data['date_debut'],
        date_fin=data['date_fin']
    )
    db.session.add(d)
    db.session.commit()
    return jsonify({'message': 'Disponibilité ajoutée avec succès'}), 201

@main_bp.route('/disponibilites/<int:id>', methods=['PUT'])
def update_disponibilite(id):
    d = Disponibilite.query.get_or_404(id)
    data = request.get_json()
    d.id_enseignant = data.get('id_enseignant', d.id_enseignant)
    d.id_session = data.get('id_session', d.id_session)
    d.date_debut = data.get('date_debut', d.date_debut)
    d.date_fin = data.get('date_fin', d.date_fin)
    db.session.commit()
    return jsonify({'message': 'Disponibilité modifiée avec succès'})

@main_bp.route('/disponibilites/<int:id>', methods=['DELETE'])
def delete_disponibilite(id):
    d = Disponibilite.query.get_or_404(id)
    db.session.delete(d)
    db.session.commit()
    return jsonify({'message': 'Disponibilité supprimée avec succès'})



@main_bp.route('/programmes', methods=['GET'])
def get_programmes():
    return jsonify([p.to_dict() for p in Programme.query.all()])

@main_bp.route('/programmes/<int:id>', methods=['GET'])
def get_programme(id):
    return jsonify(Programme.query.get_or_404(id).to_dict())

@main_bp.route('/programmes/<int:id>', methods=['PUT'])
def update_programme(id):
    p = Programme.query.get_or_404(id)
    data = request.get_json()
    p.id_session = data.get('id_session', p.id_session)
    p.id_rapport = data.get('id_rapport', p.id_rapport)
    p.id_salle = data.get('id_salle', p.id_salle)
    p.date_heure = data.get('date_heure', p.date_heure)
    p.duree_minutes = data.get('duree_minutes', p.duree_minutes)
    p.statut = data.get('statut', p.statut)
    db.session.commit()
    return jsonify({'message': 'Programme modifié avec succès'})

@main_bp.route('/programmes/<int:id>', methods=['DELETE'])
def delete_programme(id):
    p = Programme.query.get_or_404(id)
    db.session.delete(p)
    db.session.commit()
    return jsonify({'message': 'Programme supprimé avec succès'})

@main_bp.route('/programmes/<int:id>/valider', methods=['PUT'])
def valider_programme(id):
    p = Programme.query.get_or_404(id)
    data = request.get_json()
    statut = data.get('statut')
    if statut not in ['validé', 'annulé']:
        return jsonify({'message': 'Statut invalide — choisir validé ou annulé'}), 400
    p.statut = statut
    db.session.commit()
    return jsonify({'message': f'Programme {p.statut}'})

@main_bp.route('/programmes/generer/<int:id_session>', methods=['POST'])
def generer_programme(id_session):
    Session.query.get_or_404(id_session)
    rapports = Rapport.query.filter_by(id_session=id_session, statut='validé').all()
    if not rapports:
        return jsonify({'message': 'Aucun rapport validé pour cette session'}), 400
    salles = Salle.query.all()
    if not salles:
        return jsonify({'message': 'Aucune salle disponible'}), 400
    disponibilites = Disponibilite.query.filter_by(id_session=id_session).all()
    if not disponibilites:
        return jsonify({'message': 'Aucune disponibilité enregistrée'}), 400

    programmes_crees = []
    enseignants_occupes = {}

    for rapport in rapports:
        programme_cree = False
        for dispo in disponibilites:
            date_heure = dispo.date_debut
            salle_libre = None
            for salle in salles:
                if not Programme.query.filter_by(id_salle=salle.id_salle, date_heure=date_heure).first():
                    salle_libre = salle
                    break
            if not salle_libre:
                continue
            enseignants_dispo = Disponibilite.query.filter(
                Disponibilite.id_session == id_session,
                Disponibilite.date_debut <= date_heure,
                Disponibilite.date_fin >= date_heure + timedelta(minutes=45)
            ).all()
            occupes = enseignants_occupes.get(str(date_heure), [])
            enseignants_libres = list(set([
                d.id_enseignant for d in enseignants_dispo
                if d.id_enseignant not in occupes
            ]))
            if len(enseignants_libres) < 4:
                continue
            p = Programme(
                id_session=id_session,
                id_rapport=rapport.id_rapport,
                id_salle=salle_libre.id_salle,
                date_heure=date_heure,
                duree_minutes=45,
                statut='proposé'
            )
            db.session.add(p)
            db.session.flush()
            roles = ['président', 'rapporteur', 'examinateur', 'examinateur']
            for i, role in enumerate(roles):
                db.session.add(Jury(
                    id_programme=p.id_programme,
                    id_enseignant=enseignants_libres[i],
                    role_jury=role,
                    present=False
                ))
            if str(date_heure) not in enseignants_occupes:
                enseignants_occupes[str(date_heure)] = []
            enseignants_occupes[str(date_heure)].extend(enseignants_libres[:4])
            programmes_crees.append(rapport.id_rapport)
            programme_cree = True
            break
        if not programme_cree:
            db.session.rollback()
            return jsonify({'message': f'Impossible de planifier le rapport {rapport.id_rapport}'}), 400

    db.session.commit()
    return jsonify({'message': f'{len(programmes_crees)} programme(s) généré(s) avec succès'}), 201


@main_bp.route('/jurys', methods=['GET'])
def get_jurys():
    return jsonify([j.to_dict() for j in Jury.query.all()])

@main_bp.route('/jurys/<int:id>', methods=['GET'])
def get_jury(id):
    return jsonify(Jury.query.get_or_404(id).to_dict())

@main_bp.route('/jurys/<int:id>', methods=['PUT'])
def update_jury(id):
    j = Jury.query.get_or_404(id)
    data = request.get_json()
    j.role_jury = data.get('role_jury', j.role_jury)
    j.present = data.get('present', j.present)
    db.session.commit()
    return jsonify({'message': 'Jury modifié avec succès'})

@main_bp.route('/jurys/<int:id>', methods=['DELETE'])
def delete_jury(id):
    j = Jury.query.get_or_404(id)
    db.session.delete(j)
    db.session.commit()
    return jsonify({'message': 'Jury supprimé avec succès'})



@main_bp.route('/validations', methods=['GET'])
def get_validations():
    return jsonify([v.to_dict() for v in ValidationProgramme.query.all()])

@main_bp.route('/validations', methods=['POST'])
def add_validation():
    data = request.get_json()
    if not data or not data.get('id_programme') or not data.get('id_enseignant'):
        return jsonify({'message': 'id_programme et id_enseignant obligatoires'}), 400
    Programme.query.get_or_404(data['id_programme'])
    Enseignant.query.get_or_404(data['id_enseignant'])
    if ValidationProgramme.query.filter_by(
        id_programme=data['id_programme'],
        id_enseignant=data['id_enseignant']
    ).first():
        return jsonify({'message': 'Validation déjà enregistrée'}), 400
    v = ValidationProgramme(
        id_programme=data['id_programme'],
        id_enseignant=data['id_enseignant'],
        statut=data.get('statut', 'en_attente')
    )
    db.session.add(v)
    db.session.commit()
    return jsonify({'message': 'Validation ajoutée avec succès'}), 201

@main_bp.route('/validations/<int:id_programme>/<int:id_enseignant>', methods=['PUT'])
def update_validation(id_programme, id_enseignant):
    v = ValidationProgramme.query.get_or_404((id_programme, id_enseignant))
    data = request.get_json()
    statut = data.get('statut')
    if statut not in ['en_attente', 'approuvé', 'réfusé']:
        return jsonify({'message': 'Statut invalide'}), 400
    v.statut = statut
    db.session.commit()
    return jsonify({'message': 'Validation modifiée avec succès'})

@main_bp.route('/validations/<int:id_programme>/<int:id_enseignant>', methods=['DELETE'])
def delete_validation(id_programme, id_enseignant):
    v = ValidationProgramme.query.get_or_404((id_programme, id_enseignant))
    db.session.delete(v)
    db.session.commit()
    return jsonify({'message': 'Validation supprimée avec succès'})



@main_bp.route('/resultats', methods=['GET'])
def get_resultats():
    return jsonify([r.to_dict() for r in Resultat.query.all()])

@main_bp.route('/resultats/<int:id>', methods=['GET'])
def get_resultat(id):
    return jsonify(Resultat.query.get_or_404(id).to_dict())

@main_bp.route('/resultats', methods=['POST'])
def add_resultat():
    data = request.get_json()
    if not data or not data.get('id_programme'):
        return jsonify({'message': 'id_programme obligatoire'}), 400
    p = Programme.query.get_or_404(data['id_programme'])
    if p.statut != 'réalisé':
        return jsonify({'message': 'Le programme doit être réalisé avant d\'enregistrer un résultat'}), 400
    if Resultat.query.filter_by(id_programme=data['id_programme']).first():
        return jsonify({'message': 'Résultat déjà enregistré pour ce programme'}), 400
    note = data.get('note')
    if note is not None and (float(note) < 0 or float(note) > 20):
        return jsonify({'message': 'La note doit être entre 0 et 20'}), 400
    r = Resultat(
        id_programme=data['id_programme'],
        mention=data.get('mention'),
        note=note,
        observation=data.get('observation'),
        enregistre_par=data.get('enregistre_par')
    )
    db.session.add(r)
    db.session.commit()
    return jsonify({'message': 'Résultat ajouté avec succès'}), 201

@main_bp.route('/resultats/<int:id>', methods=['PUT'])
def update_resultat(id):
    r = Resultat.query.get_or_404(id)
    data = request.get_json()
    note = data.get('note', r.note)
    if note is not None and (float(note) < 0 or float(note) > 20):
        return jsonify({'message': 'La note doit être entre 0 et 20'}), 400
    r.mention = data.get('mention', r.mention)
    r.note = note
    r.observation = data.get('observation', r.observation)
    r.enregistre_par = data.get('enregistre_par', r.enregistre_par)
    db.session.commit()
    return jsonify({'message': 'Résultat modifié avec succès'})

@main_bp.route('/resultats/<int:id>', methods=['DELETE'])
def delete_resultat(id):
    r = Resultat.query.get_or_404(id)
    db.session.delete(r)
    db.session.commit()
    return jsonify({'message': 'Résultat supprimé avec succès'})
