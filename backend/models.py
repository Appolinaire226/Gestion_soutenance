

from extensions import db

class Filiere(db.Model):
    __tablename__ = "filiere"
    __table_args__ = {"schema": "jury"}

    id_filiere   = db.Column(db.Integer, primary_key=True)
    code_filiere = db.Column(db.String(10), nullable=False, unique=True)
    libelle      = db.Column(db.String(100), nullable=False)

    # Relation : une filière a plusieurs étudiants

    etudiants = db.relationship("Etudiant", back_populates="filiere", lazy=True)

    def to_dict(self):
        return {
            "id_filiere":   self.id_filiere,
            "code_filiere": self.code_filiere,
            "libelle":      self.libelle,
        }


class Salle(db.Model):
    __tablename__ = "salle"
    __table_args__ = {"schema": "jury"}

    id_salle    = db.Column(db.Integer, primary_key=True)
    nom_salle   = db.Column(db.String(50), nullable=False, unique=True)
    capacite    = db.Column(db.Integer, nullable=False)
    batiment    = db.Column(db.String(50), nullable=True)
    equipements = db.Column(db.Text, nullable=True)

    # Relation : une salle accueille plusieurs programmes
    programmes = db.relationship("Programme", back_populates="salle", lazy=True)

    def to_dict(self):
        return {
            "id_salle":    self.id_salle,
            "nom_salle":   self.nom_salle,
            "capacite":    self.capacite,
            "batiment":    self.batiment,
            "equipements": self.equipements,
        }


class Session(db.Model):
    __tablename__ = "session"
    __table_args__ = {"schema": "jury"}

    id_session       = db.Column(db.Integer, primary_key=True)
    libelle          = db.Column(db.String(150), nullable=False)
    annee_academique = db.Column(db.String(10), nullable=False)
    date_debut       = db.Column(db.Date, nullable=False)
    date_fin         = db.Column(db.Date, nullable=False)
    statut           = db.Column(db.String(20), nullable=False, default="planifiée")

    # Relations :
    rapports       = db.relationship("Rapport", back_populates="session", lazy=True)
    disponibilites = db.relationship("Disponibilite", back_populates="session", lazy=True)
    programmes     = db.relationship("Programme", back_populates="session", lazy=True)

    def to_dict(self):
        return {
            "id_session":       self.id_session,
            "libelle":          self.libelle,
            "annee_academique": self.annee_academique,
            "date_debut":       self.date_debut.isoformat(),
            "date_fin":         self.date_fin.isoformat(),
            "statut":           self.statut,
        }

class Enseignant(db.Model):
    __tablename__ = "enseignant"
    __table_args__ = {"schema": "jury"}

    id_enseignant = db.Column(db.Integer, primary_key=True)
    matricule     = db.Column(db.String(20), nullable=False, unique=True)
    nom           = db.Column(db.String(100), nullable=False)
    prenom        = db.Column(db.String(100), nullable=False)
    grade         = db.Column(db.String(50), nullable=True)
    specialite    = db.Column(db.String(100), nullable=True)
    email         = db.Column(db.String(150), nullable=True, unique=True)
    telephone     = db.Column(db.String(20), nullable=True)
    statut        = db.Column(db.String(30), nullable=False, default="actif")

    # Relations
    disponibilites       = db.relationship("Disponibilite", back_populates="enseignant", lazy=True)
    jurys                = db.relationship("Jury", back_populates="enseignant", lazy=True)
    resultats_enregistres = db.relationship("Resultat", back_populates="enregistreur", lazy=True)
    validations          = db.relationship("ValidationProgramme", back_populates="enseignant", lazy=True)
    utilisateur          = db.relationship("Utilisateur", back_populates="enseignant", uselist=False)

    def to_dict(self):
        return {
            "id_enseignant": self.id_enseignant,
            "matricule":     self.matricule,
            "nom":           self.nom,
            "prenom":        self.prenom,
            "grade":         self.grade,
            "specialite":    self.specialite,
            "email":         self.email,
            "telephone":     self.telephone,
            "statut":        self.statut,
        }


class Etudiant(db.Model):
    __tablename__ = "etudiant"
    __table_args__ = {"schema": "jury"}

    id_etudiant    = db.Column(db.Integer, primary_key=True)
    matricule      = db.Column(db.String(20), nullable=False, unique=True)
    nom            = db.Column(db.String(100), nullable=False)
    prenom         = db.Column(db.String(100), nullable=False)
    date_naissance = db.Column(db.Date, nullable=True)
    email          = db.Column(db.String(150), nullable=True, unique=True)
    telephone      = db.Column(db.String(20), nullable=True)
    id_filiere     = db.Column(db.Integer, db.ForeignKey("jury.filiere.id_filiere"), nullable=False)

    # Relations
    filiere  = db.relationship("Filiere", back_populates="etudiants")
    rapports = db.relationship("Rapport", back_populates="etudiant", lazy=True)

    def to_dict(self):
        return {
            "id_etudiant":    self.id_etudiant,
            "matricule":      self.matricule,
            "nom":            self.nom,
            "prenom":         self.prenom,
            "date_naissance": self.date_naissance.isoformat() if self.date_naissance else None,
            "email":          self.email,
            "telephone":      self.telephone,
            "id_filiere":     self.id_filiere,
        }

class Rapport(db.Model):
    __tablename__ = "rapport"
    __table_args__ = {"schema": "jury"}

    id_rapport   = db.Column(db.Integer, primary_key=True)
    titre        = db.Column(db.String(255), nullable=False)
    resume       = db.Column(db.Text, nullable=True)
    fichier_url  = db.Column(db.String(300), nullable=True)
    date_depot   = db.Column(db.DateTime, nullable=False, default=db.func.now())
    id_etudiant  = db.Column(db.Integer, db.ForeignKey("jury.etudiant.id_etudiant"), nullable=False)
    id_session   = db.Column(db.Integer, db.ForeignKey("jury.session.id_session"), nullable=False)
    statut       = db.Column(db.String(30), nullable=False, default="déposé")

    # Relations
    etudiant   = db.relationship("Etudiant", back_populates="rapports")
    session    = db.relationship("Session", back_populates="rapports")
    programme  = db.relationship("Programme", back_populates="rapport", uselist=False)

    def to_dict(self):
        return {
            "id_rapport":  self.id_rapport,
            "titre":       self.titre,
            "resume":      self.resume,
            "fichier_url": self.fichier_url,
            "date_depot":  self.date_depot.isoformat(),
            "id_etudiant": self.id_etudiant,
            "id_session":  self.id_session,
            "statut":      self.statut,
        }


class Disponibilite(db.Model):
    __tablename__ = "disponibilite"
    __table_args__ = {"schema": "jury"}

    id_disponibilite = db.Column(db.Integer, primary_key=True)
    id_enseignant    = db.Column(db.Integer, db.ForeignKey("jury.enseignant.id_enseignant"), nullable=False)
    id_session       = db.Column(db.Integer, db.ForeignKey("jury.session.id_session"), nullable=False)
    date_debut       = db.Column(db.DateTime, nullable=False)
    date_fin         = db.Column(db.DateTime, nullable=False)

    # Relations
    enseignant = db.relationship("Enseignant", back_populates="disponibilites")
    session    = db.relationship("Session", back_populates="disponibilites")

    def to_dict(self):
        return {
            "id_disponibilite": self.id_disponibilite,
            "id_enseignant":    self.id_enseignant,
            "id_session":       self.id_session,
            "date_debut":       self.date_debut.isoformat(),
            "date_fin":         self.date_fin.isoformat(),
        }


class Programme(db.Model):
    __tablename__ = "programme"
    __table_args__ = {"schema": "jury"}

    id_programme   = db.Column(db.Integer, primary_key=True)
    id_session     = db.Column(db.Integer, db.ForeignKey("jury.session.id_session"), nullable=False)
    id_rapport     = db.Column(db.Integer, db.ForeignKey("jury.rapport.id_rapport"), nullable=False)
    id_salle       = db.Column(db.Integer, db.ForeignKey("jury.salle.id_salle"), nullable=False)
    date_heure     = db.Column(db.DateTime, nullable=False)
    duree_minutes  = db.Column(db.Integer, nullable=False, default=45)
    statut         = db.Column(db.String(30), nullable=False, default="proposé")

    # Relations
    session     = db.relationship("Session", back_populates="programmes")
    rapport     = db.relationship("Rapport", back_populates="programme")
    salle       = db.relationship("Salle", back_populates="programmes")
    jurys       = db.relationship("Jury", back_populates="programme", lazy=True)
    resultat    = db.relationship("Resultat", back_populates="programme", uselist=False)
    validations = db.relationship("ValidationProgramme", back_populates="programme", lazy=True)

    def to_dict(self):
        return {
            "id_programme":  self.id_programme,
            "id_session":    self.id_session,
            "id_rapport":    self.id_rapport,
            "id_salle":      self.id_salle,
            "date_heure":    self.date_heure.isoformat(),
            "duree_minutes": self.duree_minutes,
            "statut":        self.statut,
        }


class Jury(db.Model):
    __tablename__ = "jury"
    __table_args__ = {"schema": "jury"}

    id_jury       = db.Column(db.Integer, primary_key=True)
    id_programme  = db.Column(db.Integer, db.ForeignKey("jury.programme.id_programme"), nullable=False)
    id_enseignant = db.Column(db.Integer, db.ForeignKey("jury.enseignant.id_enseignant"), nullable=False)
    role_jury     = db.Column(db.String(30), nullable=False)
    present       = db.Column(db.Boolean, nullable=False, default=False)

    # Relations
    programme  = db.relationship("Programme", back_populates="jurys")
    enseignant = db.relationship("Enseignant", back_populates="jurys")

    def to_dict(self):
        return {
            "id_jury":       self.id_jury,
            "id_programme":  self.id_programme,
            "id_enseignant": self.id_enseignant,
            "role_jury":     self.role_jury,
            "present":       self.present,
        }


class Resultat(db.Model):
    __tablename__ = "resultat"
    __table_args__ = {"schema": "jury"}

    id_resultat        = db.Column(db.Integer, primary_key=True)
    id_programme       = db.Column(db.Integer, db.ForeignKey("jury.programme.id_programme"), nullable=False, unique=True)
    mention            = db.Column(db.String(30), nullable=True)
    note               = db.Column(db.Numeric(4, 2), nullable=True)
    observation        = db.Column(db.Text, nullable=True)
    date_deliberation  = db.Column(db.DateTime, nullable=False, default=db.func.now())
    enregistre_par     = db.Column(db.Integer, db.ForeignKey("jury.enseignant.id_enseignant"), nullable=True)

    # Relations
    programme    = db.relationship("Programme", back_populates="resultat")
    enregistreur = db.relationship("Enseignant", back_populates="resultats_enregistres")

    def to_dict(self):
        return {
            "id_resultat":       self.id_resultat,
            "id_programme":      self.id_programme,
            "mention":           self.mention,
            "note":              float(self.note) if self.note else None,
            "observation":       self.observation,
            "date_deliberation": self.date_deliberation.isoformat(),
            "enregistre_par":    self.enregistre_par,
        }


class ValidationProgramme(db.Model):
    __tablename__ = "validation_programme"
    __table_args__ = {"schema": "jury"}

    id_validation   = db.Column(db.Integer, primary_key=True)
    id_programme    = db.Column(db.Integer, db.ForeignKey("jury.programme.id_programme"), nullable=False)
    id_enseignant   = db.Column(db.Integer, db.ForeignKey("jury.enseignant.id_enseignant"), nullable=False)
    date_validation = db.Column(db.DateTime, nullable=False, default=db.func.now())
    statut          = db.Column(db.String(20), nullable=False, default="en_attente")
    commentaire     = db.Column(db.Text, nullable=True)

    # Relations
    programme  = db.relationship("Programme", back_populates="validations")
    enseignant = db.relationship("Enseignant", back_populates="validations")

    def to_dict(self):
        return {
            "id_validation":   self.id_validation,
            "id_programme":    self.id_programme,
            "id_enseignant":   self.id_enseignant,
            "date_validation": self.date_validation.isoformat(),
            "statut":          self.statut,
            "commentaire":     self.commentaire,
        }

class Utilisateur(db.Model):
    __tablename__ = "utilisateur"
    __table_args__ = {"schema": "jury"}

    id_utilisateur    = db.Column(db.Integer, primary_key=True)
    email             = db.Column(db.String(150), nullable=False, unique=True)
    mot_de_passe_hash = db.Column(db.String(255), nullable=False)
    role              = db.Column(db.String(20), nullable=False)
    # Relation
    #Fonction pour convertir l'objet en dictionnaire 
    def to_dict(self):
        return {
            "id_utilisateur": self.id_utilisateur,
            "email":          self.email,
            "role":           self.role,
        }
