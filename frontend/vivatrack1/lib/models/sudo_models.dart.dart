// lib/models/models.dart
//import 'dart:convert';

// --- FILIERE ---
class Filiere {
  final int idFiliere;
  final String codeFiliere;
  final String libelle;
  Filiere({
    required this.idFiliere,
    required this.codeFiliere,
    required this.libelle,
  });
  factory Filiere.fromJson(Map<String, dynamic> json) => Filiere(
    idFiliere: json['id_filiere'],
    codeFiliere: json['code_filiere'],
    libelle: json['libelle'],
  );
  Map<String, dynamic> toJson() => {
    'id_filiere': idFiliere,
    'code_filiere': codeFiliere,
    'libelle': libelle,
  };
}

// --- SALLE ---
class Salle {
  final int idSalle;
  final String nomSalle;
  final int capacite;
  final String? batiment;
  final String? equipements;
  Salle({
    required this.idSalle,
    required this.nomSalle,
    required this.capacite,
    this.batiment,
    this.equipements,
  });
  factory Salle.fromJson(Map<String, dynamic> json) => Salle(
    idSalle: json['id_salle'],
    nomSalle: json['nom_salle'],
    capacite: json['capacite'],
    batiment: json['batiment'],
    equipements: json['equipements'],
  );
  Map<String, dynamic> toJson() => {
    'id_salle': idSalle,
    'nom_salle': nomSalle,
    'capacite': capacite,
    'batiment': batiment,
    'equipements': equipements,
  };
}

// --- SESSION ---
class Session {
  final int idSession;
  final String libelle, anneeAcademique, statut;
  final DateTime dateDebut, dateFin;
  Session({
    required this.idSession,
    required this.libelle,
    required this.anneeAcademique,
    required this.dateDebut,
    required this.dateFin,
    required this.statut,
  });
  factory Session.fromJson(Map<String, dynamic> json) => Session(
    idSession: json['id_session'],
    libelle: json['libelle'],
    anneeAcademique: json['annee_academique'],
    dateDebut: DateTime.parse(json['date_debut']),
    dateFin: DateTime.parse(json['date_fin']),
    statut: json['statut'],
  );
  Map<String, dynamic> toJson() => {
    'id_session': idSession,
    'libelle': libelle,
    'annee_academique': anneeAcademique,
    'date_debut': dateDebut.toIso8601String(),
    'date_fin': dateFin.toIso8601String(),
    'statut': statut,
  };
}

// --- ENSEIGNANT ---
class Enseignant {
  final int idEnseignant;
  final String matricule, nom, prenom, statut;
  final String? grade, specialite, email, telephone;
  Enseignant({
    required this.idEnseignant,
    required this.matricule,
    required this.nom,
    required this.prenom,
    this.grade,
    this.specialite,
    this.email,
    this.telephone,
    required this.statut,
  });
  factory Enseignant.fromJson(Map<String, dynamic> json) => Enseignant(
    idEnseignant: json['id_enseignant'],
    matricule: json['matricule'],
    nom: json['nom'],
    prenom: json['prenom'],
    grade: json['grade'],
    specialite: json['specialite'],
    email: json['email'],
    telephone: json['telephone'],
    statut: json['statut'],
  );
  Map<String, dynamic> toJson() => {
    'id_enseignant': idEnseignant,
    'matricule': matricule,
    'nom': nom,
    'prenom': prenom,
    'grade': grade,
    'specialite': specialite,
    'email': email,
    'telephone': telephone,
    'statut': statut,
  };
}

// --- ETUDIANT ---
class Etudiant {
  final int idEtudiant, idFiliere;
  final String matricule, nom, prenom;
  final DateTime? dateNaissance;
  final String? email, telephone;
  Etudiant({
    required this.idEtudiant,
    required this.matricule,
    required this.nom,
    required this.prenom,
    this.dateNaissance,
    this.email,
    this.telephone,
    required this.idFiliere,
  });
  factory Etudiant.fromJson(Map<String, dynamic> json) => Etudiant(
    idEtudiant: json['id_etudiant'],
    matricule: json['matricule'],
    nom: json['nom'],
    prenom: json['prenom'],
    dateNaissance: json['date_naissance'] != null
        ? DateTime.parse(json['date_naissance'])
        : null,
    email: json['email'],
    telephone: json['telephone'],
    idFiliere: json['id_filiere'],
  );
  Map<String, dynamic> toJson() => {
    'id_etudiant': idEtudiant,
    'matricule': matricule,
    'nom': nom,
    'prenom': prenom,
    'date_naissance': dateNaissance?.toIso8601String(),
    'email': email,
    'telephone': telephone,
    'id_filiere': idFiliere,
  };
}

// --- RAPPORT ---
class Rapport {
  final int idRapport, idEtudiant, idSession;
  final String titre, statut;
  final String? resume, fichierUrl;
  final DateTime dateDepot;
  Rapport({
    required this.idRapport,
    required this.titre,
    this.resume,
    this.fichierUrl,
    required this.dateDepot,
    required this.idEtudiant,
    required this.idSession,
    required this.statut,
  });
  factory Rapport.fromJson(Map<String, dynamic> json) => Rapport(
    idRapport: json['id_rapport'],
    titre: json['titre'],
    resume: json['resume'],
    fichierUrl: json['fichier_url'],
    dateDepot: DateTime.parse(json['date_depot']),
    idEtudiant: json['id_etudiant'],
    idSession: json['id_session'],
    statut: json['statut'],
  );
  Map<String, dynamic> toJson() => {
    'id_rapport': idRapport,
    'titre': titre,
    'resume': resume,
    'fichier_url': fichierUrl,
    'date_depot': dateDepot.toIso8601String(),
    'id_etudiant': idEtudiant,
    'id_session': idSession,
    'statut': statut,
  };
}

// --- DISPONIBILITE ---
class Disponibilite {
  final int idDisponibilite, idEnseignant, idSession;
  final DateTime dateDebut, dateFin;
  Disponibilite({
    required this.idDisponibilite,
    required this.idEnseignant,
    required this.idSession,
    required this.dateDebut,
    required this.dateFin,
  });
  factory Disponibilite.fromJson(Map<String, dynamic> json) => Disponibilite(
    idDisponibilite: json['id_disponibilite'],
    idEnseignant: json['id_enseignant'],
    idSession: json['id_session'],
    dateDebut: DateTime.parse(json['date_debut']),
    dateFin: DateTime.parse(json['date_fin']),
  );
  Map<String, dynamic> toJson() => {
    'id_disponibilite': idDisponibilite,
    'id_enseignant': idEnseignant,
    'id_session': idSession,
    'date_debut': dateDebut.toIso8601String(),
    'date_fin': dateFin.toIso8601String(),
  };
}

// --- PROGRAMME ---
class Programme {
  final int idProgramme, idSession, idRapport, idSalle, dureeMinutes;
  final DateTime dateHeure;
  final String statut;
  Programme({
    required this.idProgramme,
    required this.idSession,
    required this.idRapport,
    required this.idSalle,
    required this.dateHeure,
    required this.dureeMinutes,
    required this.statut,
  });
  factory Programme.fromJson(Map<String, dynamic> json) => Programme(
    idProgramme: json['id_programme'],
    idSession: json['id_session'],
    idRapport: json['id_rapport'],
    idSalle: json['id_salle'],
    dateHeure: DateTime.parse(json['date_heure']),
    dureeMinutes: json['duree_minutes'],
    statut: json['statut'],
  );
  Map<String, dynamic> toJson() => {
    'id_programme': idProgramme,
    'id_session': idSession,
    'id_rapport': idRapport,
    'id_salle': idSalle,
    'date_heure': dateHeure.toIso8601String(),
    'duree_minutes': dureeMinutes,
    'statut': statut,
  };
}

// --- JURY ---
class Jury {
  final int idJury, idProgramme, idEnseignant;
  final String roleJury;
  final bool present;
  Jury({
    required this.idJury,
    required this.idProgramme,
    required this.idEnseignant,
    required this.roleJury,
    required this.present,
  });
  factory Jury.fromJson(Map<String, dynamic> json) => Jury(
    idJury: json['id_jury'],
    idProgramme: json['id_programme'],
    idEnseignant: json['id_enseignant'],
    roleJury: json['role_jury'],
    present: json['present'],
  );
  Map<String, dynamic> toJson() => {
    'id_jury': idJury,
    'id_programme': idProgramme,
    'id_enseignant': idEnseignant,
    'role_jury': roleJury,
    'present': present,
  };
}

// --- RESULTAT ---
class Resultat {
  final int idResultat, idProgramme;
  final String? mention, observation;
  final double? note;
  final DateTime dateDeliberation;
  final int? enregistrePar;
  Resultat({
    required this.idResultat,
    required this.idProgramme,
    this.mention,
    this.note,
    this.observation,
    required this.dateDeliberation,
    this.enregistrePar,
  });
  factory Resultat.fromJson(Map<String, dynamic> json) => Resultat(
    idResultat: json['id_resultat'],
    idProgramme: json['id_programme'],
    mention: json['mention'],
    note: (json['note'] as num?)?.toDouble(),
    observation: json['observation'],
    dateDeliberation: DateTime.parse(json['date_deliberation']),
    enregistrePar: json['enregistre_par'],
  );
  Map<String, dynamic> toJson() => {
    'id_resultat': idResultat,
    'id_programme': idProgramme,
    'mention': mention,
    'note': note,
    'observation': observation,
    'date_deliberation': dateDeliberation.toIso8601String(),
    'enregistre_par': enregistrePar,
  };
}

// --- VALIDATION PROGRAMME ---
class ValidationProgramme {
  final int idValidation, idProgramme, idEnseignant;
  final DateTime dateValidation;
  final String statut;
  final String? commentaire;
  ValidationProgramme({
    required this.idValidation,
    required this.idProgramme,
    required this.idEnseignant,
    required this.dateValidation,
    required this.statut,
    this.commentaire,
  });
  factory ValidationProgramme.fromJson(Map<String, dynamic> json) =>
      ValidationProgramme(
        idValidation: json['id_validation'],
        idProgramme: json['id_programme'],
        idEnseignant: json['id_enseignant'],
        dateValidation: DateTime.parse(json['date_validation']),
        statut: json['statut'],
        commentaire: json['commentaire'],
      );
  Map<String, dynamic> toJson() => {
    'id_validation': idValidation,
    'id_programme': idProgramme,
    'id_enseignant': idEnseignant,
    'date_validation': dateValidation.toIso8601String(),
    'statut': statut,
    'commentaire': commentaire,
  };
}

// --- UTILISATEUR ---
class Utilisateur {
  final int idUtilisateur;
  final String email, role;
  final int? idEnseignant;
  Utilisateur({
    required this.idUtilisateur,
    required this.email,
    required this.role,
    this.idEnseignant,
  });
  factory Utilisateur.fromJson(Map<String, dynamic> json) => Utilisateur(
    idUtilisateur: json['id_utilisateur'],
    email: json['email'],
    role: json['role'],
    idEnseignant: json['id_enseignant'],
  );
  Map<String, dynamic> toJson() => {
    'id_utilisateur': idUtilisateur,
    'email': email,
    'role': role,
    'id_enseignant': idEnseignant,
  };
}
