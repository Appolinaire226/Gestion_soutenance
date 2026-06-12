from flask import Blueprint,jsonify,request
from extension import db
#from models import Etudiant # Enseignant,Salle,Jurry,Participation,Soutenance,Programmce,Disponibilite,Session,Resultat
etudiant_bp = Blueprint('etudiant', __name__)

@etudiant_bp.route('/etudiants', methods=['GET'])
def get_etudiants():
    e = Etudiant.query.all()
    return jsonify([{
        'id_etudiant': e.id_etudiant,
        'nom_etudiant': e.nom_etudiant,
        'prenom_etudiant': e.prenom_etudiant,
        'filiere': e.filiere,
        'titre_memoire': e.theme_memoire
    } for e in etudiants])


@etudiant_bp.route('/etudiants/<String:id_etudiant>', methods=['GET'])
def get_etudiant(id_etudiant):
    e = Etudiant.query.get_or_404(id_etudiant)
    return jsonify({
        'id_etudiant': e.id_etudiant,
        'nom_etudiant': e.nom_etudiant,
        'prenom_etudiant': e.prenom_etudiant,
        'filiere': e.filiere,
        'titre_memoire': e.theme_memoire
    })


@etudiant_bp.route('/etudiants', methods=['POST'])
def add_etudiant():
    data = request.get_json()
    etudiant = Etudiant(
        nom_etudiant=data['nom_etudiant'],
        prenom_etudiant=data['prenom_etudiant'],
        filiere=data['filiere'],
        theme_memoire=data['theme_memoire']
    )
    db.session.add(etudiant)
    db.session.commit()
    return jsonify({'message': 'Etudiant ajouté'}), 201


@etudiant_bp.route('/etudiants/<String:id_etudiant>', methods=['PUT'])
def update_etudiant(id):
    e = Etudiant.query.get_or_404(id)
    data = request.get_json()
    e.nom_etudiant = data.get('nom_etudiant', e.nom_etudiant)
    e.prenom_etudiant = data.get('prenom_etudiant', e.prenom_etudiant)
    e.filiere = data.get('filiere', e.filiere)
    e.theme_memoire = data.get('theme_memoire', e.theme_memoire)
    db.session.commit()
    return jsonify({'message': 'Etudiant modifié n'})


@etudiant_bp.route('/etudiants/<String:id_etudiant>', methods=['DELETE'])
def delete_etudiant(id_etudiant):
    e = Etudiant.query.get_or_404(id_etudiant)
    db.session.delete(e)
    db.session.commit()
    return jsonify({'message': 'Etudiant supprimé'})


#----------------------------------------------------------------------------------------------


disponibilite_bp = Blueprint('disponibilite', __name__)


@disponibilite_bp.route('/disponibilites', methods=['GET'])
def get_disponibilites():
    disponibilites = Disponibilite.query.all()
    return jsonify([{
        'id': d.id,
        'enseignant_id': d.enseignant_id,
        'date': str(d.date),
        'heure_debut': str(d.heure_debut),
        'heure_fin': str(d.heure_fin)
    } for d in disponibilites])


@disponibilite_bp.route('/disponibilites/<int:id>', methods=['GET'])
def get_disponibilite(id):
    d = Disponibilite.query.get_or_404(id)
    return jsonify({
        'id': d.id,
        'enseignant_id': d.enseignant_id,
        'date': str(d.date),
        'heure_debut': str(d.heure_debut),
        'heure_fin': str(d.heure_fin)
    })


@disponibilite_bp.route('/disponibilites', methods=['POST'])
def add_disponibilite():
    data = request.get_json()
    d = Disponibilite(
        enseignant_id=data['enseignant_id'],
        date=data['date'],
        heure_debut=data['heure_debut'],
        heure_fin=data['heure_fin']
    )
    db.session.add(d)
    db.session.commit()
    return jsonify({'message': 'Disponibilité ajoutée  '})


@disponibilite_bp.route('/disponibilites/<int:id>', methods=['PUT'])
def update_disponibilite(id):
    d = Disponibilite.query.get_or_404(id)
    data = request.get_json()
    d.enseignant_id = data.get('enseignant_id', d.enseignant_id)
    d.date = data.get('date', d.date)
    d.heure_debut = data.get('heure_debut', d.heure_debut)
    d.heure_fin = data.get('heure_fin', d.heure_fin)
    db.session.commit()

    return jsonify({'message': 'Disponibilité modifiée'})


@disponibilite_bp.route('/disponibilites/<int:id>', methods=['DELETE'])
def delete_disponibilite(id):
    d = Disponibilite.query.get_or_404(id)
    db.session.delete(d)
    db.session.commit()
    return jsonify({'message': 'Disponibilité supprimée avec succès'})



#---------------------------------------------------------------------------------------------------------------
salle_bp = Blueprint('salle', __name__)


@salle_bp.route('/salles', methods=['GET'])
def get_salles():
    s= Salle.query.all()
    return jsonify([{
        'id_salle': s.id_salle,
        'nom_salle': s.nom_salle,
        'capacite': s.capacite
    } for s in salles])


@salle_bp.route('/salles/<int:id>', methods=['GET'])
def get_salle(id_salle):
    s = Salle.query.get_or_404(id_salle)
    return jsonify({
        'id_salle': s.id_salle,
        'nom_salle': s.nom_salle,
        'capacite': s.capacite
    })


@salle_bp.route('/salles', methods=['POST'])
def add_salle():
    data = request.get_json()
    s = Salle(
        nom_salle=data['nom_salle'],
        capacite=data['capacite']
    )
    db.session.add(s)
    db.session.commit()
    return jsonify({'message': 'Salle ajoutée '})


@salle_bp.route('/salles/<int:id>', methods=['PUT'])
def update_salle(id_salle):
    s = Salle.query.get_or_404(id_salle)
    data = request.get_json()
    s.nom_salle = data.get('nom_salle', s.nom_salle)
    s.capacite = data.get('capacite', s.capacite)
    db.session.commit()
    return jsonify({'message': 'Salle modifiée'})


@salle_bp.route('/salles/<int:id_salle>', methods=['DELETE'])
def delete_salle(id_salle):
    s = Salle.query.get_or_404(id_salle)
    db.session.delete(s)
    db.session.commit()
    return jsonify({'message': 'Salle supprimée'})



enseignant_bp= Blueprint('enseignant',__name__)
@enseignant_bp('/enseignants/',method=['GET'])
def get_enseignant():
   E=Enseignant.querry.all()
  
