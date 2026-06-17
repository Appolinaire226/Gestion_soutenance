
from extensions import db


class Filiere(db.Model):
    __tablename__ = 'filiere'
    __table_args__ = {'schema': 'jury'}

    id_filiere = db.Column(db.Integer, primary_key=True)
    code_filiere = db.Column(db.String(10), unique=True, nullable=False)
    libelle = db.Column(db.String(100), nullable=False)
    etudiants = db.relationship('Etudiant', backref='filiere')

    def to_dict(self):
        return {
            'id_filiere': self.id_filiere,
            'code_filiere': self.code_filiere,
            'libelle': self.libelle
        }


class Salle(db.Model):
    __tablename__ = 'salle'
    __table_args__ = {'schema': 'jury'}

    id_salle = db.Column(db.Integer, primary_key=True)
    nom_salle = db.Column(db.String(50), unique=True, nullable=False)
    capacite = db.Column(db.Integer, nullable=False)
    batiment = db.Column(db.String(50))
    equipements = db.Column(db.Text)
    programmes = db.relationship('Programme', backref='salle')

    def to_dict(self):
        return {
            'id_salle': self.id_salle,
            'nom_salle': self.nom_salle,
            'capacite': self.capacite,
            'batiment': self.batiment,
            'equipements': self.equipements
        }


class Session(db.Model):
    __tablename__ = 'session'
    __table_args__ = {'schema': 'jury'}

    id_session = db.Column(db.Integer, primary_key=True)
    libelle = db.Column(db.String(150), nullable=False)
    annee_academique = db.Column(db.String(10), nullable=False)
    date_debut = db.Column(db.Date, nullable=False)
    date_fin = db.Column(db.Date, nullable=False)
    statut = db.Column(db.String(20), default='planifiée', nullable=False)
    disponibilites = db.relationship('Disponibilite', backref='session')
    rapports = db.relationship('Rapport', backref='session')
    programmes = db.relationship('Programme', backref='session')

    def to_dict(self):
        return {
            'id_session': self.id_session,
            'libelle': self.libelle,
            'annee_academique': self.annee_academique,
            'date_debut': str(self.date_debut),
            'date_fin': str(self.date_fin),
            'statut': self.statut
        }


class Enseignant(db.Model):
    __tablename__ = 'enseignant'
    __table_args__ = {'schema': 'jury'}

    id_enseignant = db.Column(db.Integer, primary_key=True)
    matricule = db.Column(db.String(20), unique=True, nullable=False)
    nom = db.Column(db.String(100), nullable=False)
    prenom = db.Column(db.String(100), nullable=False)
    grade = db.Column(db.String(50))
    specialite = db.Column(db.String(100))
    email = db.Column(db.String(150), unique=True)
    telephone = db.Column(db.String(20))
    statut = db.Column(db.String(30), default='actif', nullable=False)
    disponibilites = db.relationship('Disponibilite', backref='enseignant')
    jurys = db.relationship('Jury', backref='enseignant')
    validations = db.relationship('ValidationProgramme', backref='enseignant')
    utilisateur = db.relationship('Utilisateur', backref='enseignant', uselist=False)

    def to_dict(self):
        return {
            'id_enseignant': self.id_enseignant,
            'matricule': self.matricule,
            'nom': self.nom,
            'prenom': self.prenom,
            'grade': self.grade,
            'specialite': self.specialite,
            'email': self.email,
            'telephone': self.telephone,
            'statut': self.statut
        }


class Etudiant(db.Model):
    __tablename__ = 'etudiant'
    __table_args__ = {'schema': 'jury'}

    id_etudiant = db.Column(db.Integer, primary_key=True)
    matricule = db.Column(db.String(20), unique=True, nullable=False)
    nom = db.Column(db.String(100), nullable=False)
    prenom = db.Column(db.String(100), nullable=False)
    date_naissance = db.Column(db.Date)
    email = db.Column(db.String(150), unique=True)
    telephone = db.Column(db.String(20))
    id_filiere = db.Column(db.Integer, db.ForeignKey('jury.filiere.id_filiere'), nullable=False)
    rapports = db.relationship('Rapport', backref='etudiant')

    def to_dict(self):
        return {
            'id_etudiant': self.id_etudiant,
            'matricule': self.matricule,
            'nom': self.nom,
            'prenom': self.prenom,
            'date_naissance': str(self.date_naissance) if self.date_naissance else None,
            'email': self.email,
            'telephone': self.telephone,
            'id_filiere': self.id_filiere
        }

class Rapport(db.Model):
    __tablename__ = 'rapport'
    __table_args__ = {'schema': 'jury'}

    id_rapport = db.Column(db.Integer, primary_key=True)
    titre = db.Column(db.String(255), nullable=False)
    resume = db.Column(db.Text)
    fichier_url = db.Column(db.String(300))
    date_depot = db.Column(db.DateTime, default=db.func.now(), nullable=False)
    id_etudiant = db.Column(db.Integer, db.ForeignKey('jury.etudiant.id_etudiant'), nullable=False)
    id_session = db.Column(db.Integer, db.ForeignKey('jury.session.id_session'), nullable=False)
    statut = db.Column(db.String(30), default='déposé', nullable=False)
    programmes = db.relationship('Programme', backref='rapport')

    def to_dict(self):
        return {
            'id_rapport': self.id_rapport,
            'titre': self.titre,
            'resume': self.resume,
            'fichier_url': self.fichier_url,
            'date_depot': str(self.date_depot),
            'id_etudiant': self.id_etudiant,
            'id_session': self.id_session,
            'statut': self.statut
        }


class Disponibilite(db.Model):
    __tablename__ = 'disponibilite'
    __table_args__ = {'schema': 'jury'}

    id_disponibilite = db.Column(db.Integer, primary_key=True)
    id_enseignant = db.Column(db.Integer, db.ForeignKey('jury.enseignant.id_enseignant'), nullable=False)
    id_session = db.Column(db.Integer, db.ForeignKey('jury.session.id_session'), nullable=False)
    date_debut = db.Column(db.DateTime, nullable=False)
    date_fin = db.Column(db.DateTime, nullable=False)

    def to_dict(self):
        return {
            'id_disponibilite': self.id_disponibilite,
            'id_enseignant': self.id_enseignant,
            'id_session': self.id_session,
            'date_debut': str(self.date_debut),
            'date_fin': str(self.date_fin)
        }


class Programme(db.Model):
    __tablename__ = 'programme'
    __table_args__ = {'schema': 'jury'}

    id_programme = db.Column(db.Integer, primary_key=True)
    id_session = db.Column(db.Integer, db.ForeignKey('jury.session.id_session'), nullable=False)
    id_rapport = db.Column(db.Integer, db.ForeignKey('jury.rapport.id_rapport'), nullable=False)
    id_salle = db.Column(db.Integer, db.ForeignKey('jury.salle.id_salle'), nullable=False)
    date_heure = db.Column(db.DateTime, nullable=False)
    duree_minutes = db.Column(db.Integer, default=45, nullable=False)
    statut = db.Column(db.String(30), default='proposé', nullable=False)
    jurys = db.relationship('Jury', backref='programme')
    resultat = db.relationship('Resultat', backref='programme', uselist=False)
    validations = db.relationship('ValidationProgramme', backref='programme')

    def to_dict(self):
        return {
            'id_programme': self.id_programme,
            'id_session': self.id_session,
            'id_rapport': self.id_rapport,
            'id_salle': self.id_salle,
            'date_heure': str(self.date_heure),
            'duree_minutes': self.duree_minutes,
            'statut': self.statut
        }


class Jury(db.Model):
    __tablename__ = 'jury'
    __table_args__ = {'schema': 'jury'}

    id_jury = db.Column(db.Integer, primary_key=True)
    id_programme = db.Column(db.Integer, db.ForeignKey('jury.programme.id_programme'), nullable=False)
    id_enseignant = db.Column(db.Integer, db.ForeignKey('jury.enseignant.id_enseignant'), nullable=False)
    role_jury = db.Column(db.String(30), nullable=False)
    present = db.Column(db.Boolean, default=False, nullable=False)

    def to_dict(self):
        return {
            'id_jury': self.id_jury,
            'id_programme': self.id_programme,
            'id_enseignant': self.id_enseignant,
            'role_jury': self.role_jury,
            'present': self.present
        }


class Resultat(db.Model):
    __tablename__ = 'resultat'
    __table_args__ = {'schema': 'jury'}

    id_resultat = db.Column(db.Integer, primary_key=True)
    id_programme = db.Column(db.Integer, db.ForeignKey('jury.programme.id_programme'), unique=True, nullable=False)
    mention = db.Column(db.String(30))
    note = db.Column(db.Numeric(4, 2))
    observation = db.Column(db.Text)
    date_deliberation = db.Column(db.DateTime, default=db.func.now(), nullable=False)
    enregistre_par = db.Column(db.Integer, db.ForeignKey('jury.enseignant.id_enseignant'))

    def to_dict(self):
        return {
            'id_resultat': self.id_resultat,
            'id_programme': self.id_programme,
            'mention': self.mention,
            'note': float(self.note) if self.note else None,
            'observation': self.observation,
            'date_deliberation': str(self.date_deliberation),
            'enregistre_par': self.enregistre_par
        }


class ValidationProgramme(db.Model):
    __tablename__ = 'validation_programme'
    __table_args__ = {'schema': 'jury'}

    id_programme = db.Column(db.Integer, db.ForeignKey('jury.programme.id_programme'), primary_key=True)
    id_enseignant = db.Column(db.Integer, db.ForeignKey('jury.enseignant.id_enseignant'), primary_key=True)
    statut = db.Column(db.String(20), default='en_attente', nullable=False)

    def to_dict(self):
        return {
            'id_programme': self.id_programme,
            'id_enseignant': self.id_enseignant,
            'statut': self.statut
        }


class Utilisateur(db.Model):
    __tablename__ = 'utilisateur'
    __table_args__ = {'schema': 'jury'}

    id_utilisateur = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(150), unique=True, nullable=False)
    mot_de_passe_hash = db.Column(db.String(255), nullable=False)
    role = db.Column(db.String(20), nullable=False)
    id_enseignant = db.Column(db.Integer, db.ForeignKey('jury.enseignant.id_enseignant'))

    def to_dict(self):
        return {
            'id_utilisateur': self.id_utilisateur,
            'email': self.email,
            'role': self.role,
            'id_enseignant': self.id_enseignant
        }
