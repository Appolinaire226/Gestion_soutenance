from flask import Blueprint, jsonify, request
from extension import db
from models import *
from werkzeug.security import generate_password_hash, check_password_hash

main_bp = Blueprint('main', __name__)

# ===================== UTILISATEUR =====================

@main_bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    if Utilisateur.query.filter_by(email=data['email']).first():
        return jsonify({'message': 'Email déjà utilisé'}), 400
    u = Utilisateur(
        email=data['email'],
        mot_de_passe_hash=generate_password_hash(data['mot_de_passe']),
        role=data['role'],
        id_enseignant=data.get('id_enseignant')
    )
    db.session.add(u)
    db.session.commit()
    return jsonify({'message': 'Utilisateur créé avec succès'}), 201

@main_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    u = Utilisateur.query.filter_by(email=data['email']).first()
    if not u or not check_password_hash(u.mot_de_passe_hash, data['mot_de_passe']):
        return jsonify({'message': 'Email ou mot de passe incorrect'}), 401
    return jsonify({
        'message': 'Connexion réussie',
        'id_utilisateur': u.id_utilisateur,
        'email': u.email,
        'role': u.role
    })

# ===================== FILIERE =====================

@main_bp.route('/filieres', methods=['GET'])
def get_filieres():
    filieres = Filiere.query.all()
    return jsonify([{
        'id_filiere': f.id_filiere,
        'code_filiere': f.code_filiere,
        'libelle': f.libelle
    } for f in filieres])

@main_bp.route('/filieres/<int:id>', methods=['GET'])
def get_filiere(id):
    f = Filiere.query.get_or_404(id)
    return jsonify({
        'id_filiere': f.id_filiere,
        'code_filiere': f.code_filiere,
        'libelle': f.libelle
    })

@main_bp.route('/filieres', methods=['POST'])
def add_filiere():
    data = request.get_json()
    f = Filiere(
        code_filiere=data['code_filiere'],
        libelle=data['libelle']
    )
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

# ===================== SALLE =====================

@main_bp.route('/salles', methods=['GET'])
def get_salles():
    salles = Salle.query.all()
    return jsonify([{
        'id_salle': s.id_salle,
        'nom_salle': s.nom_salle,
        'capacite': s.capacite,
        'batiment': s.batiment,
        'equipements': s.equipements
    } for s in salles])

@main_bp.route('/salles/<int:id>', methods=['GET'])
def get_salle(id):
    s = Salle.query.get_or_404(id)
    return jsonify({
        'id_salle': s.id_salle,
        'nom_salle': s.nom_salle,
        'capacite': s.capacite,
        'batiment': s.batiment,
        'equipements': s.equipements
    })

@main_bp.route('/salles', methods=['POST'])
def add_salle():
    data = request.get_json()
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

# ===================== SESSION =====================

@main_bp.route('/sessions', methods=['GET'])
def get_sessions():
    sessions = Session.query.all()
    return jsonify([{
        'id_session': s.id_session,
        'libelle': s.libelle,
        'annee_academique': s.annee_academique,
        'date_debut': str(s.date_debut),
        'date_fin': str(s.date_fin),
        'statut': s.statut
    } for s in sessions])

@main_bp.route('/sessions/<int:id>', methods=['GET'])
def get_session(id):
    s = Session.query.get_or_404(id)
    return jsonify({
        'id_session': s.id_session,
        'libelle': s.libelle,
        'annee_academique': s.annee_academique,
        'date_debut': str(s.date_debut),
        'date_fin': str(s.date_fin),
        'statut': s.statut
    })

@main_bp.route('/sessions', methods=['POST'])
def add_session():
    data = request.get_json()
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
    return jsonify({'message': 'Session supprimée avec succès'})

# ===================== ENSEIGNANT =====================

@main_bp.route('/enseignants', methods=['GET'])
def get_enseignants():
    enseignants = Enseignant.query.all()
    return jsonify([{
        'id_enseignant': e.id_enseignant,
        'matricule': e.matricule,
        'nom': e.nom,
        'prenom': e.prenom,
        'grade': e.grade,
        'specialite': e.specialite,
        'email': e.email,
        'telephone': e.telephone,
        'statut': e.statut
    } for e in enseignants])

@main_bp.route('/enseignants/<int:id>', methods=['GET'])
def get_enseignant(id):
    e = Enseignant.query.get_or_404(id)
    return jsonify({
        'id_enseignant': e.id_enseignant,
        'matricule': e.matricule,
        'nom': e.nom,
        'prenom': e.prenom,
        'grade': e.grade,
        'specialite': e.specialite,
        'email': e.email,
        'telephone': e.telephone,
        'statut': e.statut
    })

@main_bp.route('/enseignants', methods=['POST'])
def add_enseignant():
    data = request.get_json()
    e = Enseignant(
        matricule=data['matricule'],
        nom=data['nom'],
        prenom=data['prenom'],
        grade=data.get('grade'),
        specialite=data.get('specialite'),
        email=data.get('email'),
        telephone=data.get('telephone'),
        statut=data.get('statut', 'actif')
    )
    db.session.add(e)
    db.session.commit()
    return jsonify({'message': 'Enseignant ajouté avec succès'}), 201

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

# ===================== ETUDIANT =====================

@main_bp.route('/etudiants', methods=['GET'])
def get_etudiants():
    etudiants = Etudiant.query.all()
    return jsonify([{
        'id_etudiant': e.id_etudiant,
        'matricule': e.matricule,
        'nom': e.nom,
        'prenom': e.prenom,
        'date_naissance': str(e.date_naissance),
        'email': e.email,
        'telephone': e.telephone,
        'id_filiere': e.id_filiere
    } for e in etudiants])

@main_bp.route('/etudiants/<int:id>', methods=['GET'])
def get_etudiant(id):
    e = Etudiant.query.get_or_404(id)
    return jsonify({
        'id_etudiant': e.id_etudiant,
        'matricule': e.matricule,
        'nom': e.nom,
        'prenom': e.prenom,
        'date_naissance': str(e.date_naissance),
        'email': e.email,
        'telephone': e.telephone,
        'id_filiere': e.id_filiere
    })

@main_bp.route('/etudiants', methods=['POST'])
def add_etudiant():
    data = request.get_json()
    e = Etudiant(
        matricule=data['matricule'],
        nom=data['nom'],
        prenom=data['prenom'],
        date_naissance=data.get('date_naissance'),
        email=data.get('email'),
        telephone=data.get('telephone'),
        id_filiere=data['id_filiere']
    )
    db.session.add(e)
    db.session.commit()
    return jsonify({'message': 'Etudiant ajouté avec succès'}), 201

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

# ===================== RAPPORT =====================

@main_bp.route('/rapports', methods=['GET'])
def get_rapports():
    rapports = Rapport.query.all()
    return jsonify([{
        'id_rapport': r.id_rapport,
        'titre': r.titre,
        'resume': r.resume,
        'fichier_url': r.fichier_url,
        'date_depot': str(r.date_depot),
        'id_etudiant': r.id_etudiant,
        'id_session': r.id_session,
        'statut': r.statut
    } for r in rapports])

@main_bp.route('/rapports/<int:id>', methods=['GET'])
def get_rapport(id):
    r = Rapport.query.get_or_404(id)
    return jsonify({
        'id_rapport': r.id_rapport,
        'titre': r.titre,
        'resume': r.resume,
        'fichier_url': r.fichier_url,
        'date_depot': str(r.date_depot),
        'id_etudiant': r.id_etudiant,
        'id_session': r.id_session,
        'statut': r.statut
    })

@main_bp.route('/rapports', methods=['POST'])
def add_rapport():
    data = request.get_json()
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

# ===================== DISPONIBILITE =====================

@main_bp.route('/disponibilites', methods=['GET'])
def get_disponibilites():
    disponibilites = Disponibilite.query.all()
    return jsonify([{
        'id_disponibilite': d.id_disponibilite,
        'id_enseignant': d.id_enseignant,
        'id_session': d.id_session,
        'date_debut': str(d.date_debut),
        'date_fin': str(d.date_fin)
    } for d in disponibilites])

@main_bp.route('/disponibilites/<int:id>', methods=['GET'])
def get_disponibilite(id):
    d = Disponibilite.query.get_or_404(id)
    return jsonify({
        'id_disponibilite': d.id_disponibilite,
        'id_enseignant': d.id_enseignant,
        'id_session': d.id_session,
        'date_debut': str(d.date_debut),
        'date_fin': str(d.date_fin)
    })

@main_bp.route('/disponibilites', methods=['POST'])
def add_disponibilite():
    data = request.get_json()
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

# ===================== PROGRAMME =====================

@main_bp.route('/programmes', methods=['GET'])
def get_programmes():
    programmes = Programme.query.all()
    return jsonify([{
        'id_programme': p.id_programme,
        'id_session': p.id_session,
        'id_rapport': p.id_rapport,
        'id_salle': p.id_salle,
        'date_heure': str(p.date_heure),
        'duree_minutes': p.duree_minutes,
        'statut': p.statut
    } for p in programmes])

@main_bp.route('/programmes/<int:id>', methods=['GET'])
def get_programme(id):
    p = Programme.query.get_or_404(id)
    return jsonify({
        'id_programme': p.id_programme,
        'id_session': p.id_session,
        'id_rapport': p.id_rapport,
        'id_salle': p.id_salle,
        'date_heure': str(p.date_heure),
        'duree_minutes': p.duree_minutes,
        'statut': p.statut
    })

@main_bp.route('/programmes', methods=['POST'])
def add_programme():
    data = request.get_json()
    p = Programme(
        id_session=data['id_session'],
        id_rapport=data['id_rapport'],
        id_salle=data['id_salle'],
        date_heure=data['date_heure'],
        duree_minutes=data.get('duree_minutes', 45),
        statut=data.get('statut', 'proposé')
    )
    db.session.add(p)
    db.session.commit()
    return jsonify({'message': 'Programme ajouté avec succès'}), 201

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

# Route spéciale - Valider ou refuser un programme
@main_bp.route('/programmes/<int:id>/valider', methods=['PUT'])
def valider_programme(id):
    p = Programme.query.get_or_404(id)
    data = request.get_json()
    p.statut = data['statut']  # 'validé' ou 'annulé'
    db.session.commit()
    return jsonify({'message': f'Programme {p.statut} avec succès'})

# ===================== JURY =====================

@main_bp.route('/jurys', methods=['GET'])
def get_jurys():
    jurys = Jury.query.all()
    return jsonify([{
        'id_jury': j.id_jury,
        'id_programme': j.id_programme,
        'id_enseignant': j.id_enseignant,
        'role_jury': j.role_jury,
        'present': j.present
    } for j in jurys])

@main_bp.route('/jurys/<int:id>', methods=['GET'])
def get_jury(id):
    j = Jury.query.get_or_404(id)
    return jsonify({
        'id_jury': j.id_jury,
        'id_programme': j.id_programme,
        'id_enseignant': j.id_enseignant,
        'role_jury': j.role_jury,
        'present': j.present
    })

@main_bp.route('/jurys', methods=['POST'])
def add_jury():
    data = request.get_json()
    j = Jury(
        id_programme=data['id_programme'],
        id_enseignant=data['id_enseignant'],
        role_jury=data['role_jury'],
        present=data.get('present', False)
    )
    db.session.add(j)
    db.session.commit()
    return jsonify({'message': 'Jury ajouté avec succès'}), 201

@main_bp.route('/jurys/<int:id>', methods=['PUT'])
def update_jury(id):
    j = Jury.query.get_or_404(id)
    data = request.get_json()
    j.id_programme = data.get('id_programme', j.id_programme)
    j.id_enseignant = data.get('id_enseignant', j.id_enseignant)
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

# ===================== VALIDATION PROGRAMME =====================

@main_bp.route('/validations', methods=['GET'])
def get_validations():
    validations = ValidationProgramme.query.all()
    return jsonify([{
        'id_programme': v.id_programme,
        'id_enseignant': v.id_enseignant,
        'statut': v.statut
    } for v in validations])

@main_bp.route('/validations', methods=['POST'])
def add_validation():
    data = request.get_json()
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
    v.statut = data.get('statut', v.statut)
    db.session.commit()
    return jsonify({'message': 'Validation modifiée avec succès'})

@main_bp.route('/validations/<int:id_programme>/<int:id_enseignant>', methods=['DELETE'])
def delete_validation(id_programme, id_enseignant):
    v = ValidationProgramme.query.get_or_404((id_programme, id_enseignant))
    db.session.delete(v)
    db.session.commit()
    return jsonify({'message': 'Validation supprimée avec succès'})

# ===================== RESULTAT =====================

@main_bp.route('/resultats', methods=['GET'])
def get_resultats():
    resultats = Resultat.query.all()
    return jsonify([{
        'id_resultat': r.id_resultat,
        'id_programme': r.id_programme,
        'mention': r.mention,
        'note': float(r.note) if r.note else None,
        'observation': r.observation,
        'date_deliberation': str(r.date_deliberation),
        'enregistre_par': r.enregistre_par
    } for r in resultats])

@main_bp.route('/resultats/<int:id>', methods=['GET'])
def get_resultat(id):
    r = Resultat.query.get_or_404(id)
    return jsonify({
        'id_resultat': r.id_resultat,
        'id_programme': r.id_programme,
        'mention': r.mention,
        'note': float(r.note) if r.note else None,
        'observation': r.observation,
        'date_deliberation': str(r.date_deliberation),
        'enregistre_par': r.enregistre_par
    })

@main_bp.route('/resultats', methods=['POST'])
def add_resultat():
    data = request.get_json()
    r = Resultat(
        id_programme=data['id_programme'],
        mention=data.get('mention'),
        note=data.get('note'),
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
    r.mention = data.get('mention', r.mention)
    r.note = data.get('note', r.note)
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
