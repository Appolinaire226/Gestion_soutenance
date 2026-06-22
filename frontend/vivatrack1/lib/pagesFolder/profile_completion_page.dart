//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vivatrack/pagesFolder/firebase_auth.dart';
import 'package:vivatrack/services/sudo_etudiant.dart';
import '../widgets/responsive_container.dart';
import 'redirect_page.dart';
import 'home_page.dart';

class ProfileCompletionPage extends StatefulWidget {
  final String role;
  const ProfileCompletionPage({super.key, this.role = 'etudiant'});

  @override
  State<ProfileCompletionPage> createState() => _ProfileCompletionPageState();
}

class _ProfileCompletionPageState extends State<ProfileCompletionPage> {
  final _formKey = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _prenom = TextEditingController();
  final _matricule = TextEditingController();
  final _telephone = TextEditingController();
  final _idFiliere = TextEditingController();
  final _dateNaissance = TextEditingController();
  final _grade = TextEditingController();
  final _specialite = TextEditingController();

  @override
  void dispose() {
    _nom.dispose();
    _prenom.dispose();
    _matricule.dispose();
    _telephone.dispose();
    _idFiliere.dispose();
    _dateNaissance.dispose();
    _grade.dispose();
    _specialite.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Normaliser le rôle
    final roleLower = widget.role.toLowerCase();
    final isStudent = roleLower == 'student' || roleLower == 'etudiant';

    final data = <String, dynamic>{
      'nom': _nom.text.trim(),
      'prenom': _prenom.text.trim(),
      'matricule': _matricule.text.trim(),
      'telephone': _telephone.text.trim(),
    };

    final String? currentEmail = SudoAuthService().currentEmail;
    if (currentEmail != null && currentEmail.isNotEmpty) {
      data['email'] = currentEmail;
    }

    if (isStudent) {
      final idFiliere = int.tryParse(_idFiliere.text.trim());
      if (idFiliere == null) {
        throw Exception('ID de filière invalide');
      }
      data['id_filiere'] = idFiliere;
      if (_dateNaissance.text.trim().isNotEmpty) {
        data['date_naissance'] = _dateNaissance.text.trim();
      }
    } else {
      data['grade'] = _grade.text.trim();
      data['specialite'] = _specialite.text.trim();
    }

    try {
      if (isStudent) {
        await SudoEtudiantService().createEtudiant(data);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil enregistré avec succès.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RedirectPage(role: widget.role),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleLower = widget.role.toLowerCase();
    final isStudent = roleLower == 'student' || roleLower == 'etudiant';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isStudent ? 'Compléter profil étudiant' : 'Compléter profil admin',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: sudocolor,
      ),
      body: SingleChildScrollView(
        child: ResponsivePageContainer(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Section d'accueil avec icône et description
                  Icon(
                    isStudent ? Icons.school : Icons.person_4,
                    size: 64,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isStudent
                        ? 'Complétez votre profil étudiant'
                        : 'Complétez votre profil enseignant',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Veuillez remplir les informations ci-dessous pour finaliser votre inscription',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.blue),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _nom,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person, color: Colors.blue),
                      labelText: 'Nom',
                      labelStyle: const TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requis';
                      if (v.trim().length < 2) return 'Trop court';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _prenom,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person, color: Colors.blue),
                      labelText: 'Prénom',
                      labelStyle: const TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requis';
                      if (v.trim().length < 2) return 'Trop court';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _matricule,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.badge, color: Colors.blue),
                      labelText: 'Matricule',
                      labelStyle: const TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requis';
                      if (v.trim().length < 3) return 'Matricule invalide';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: SudoAuthService().currentEmail ?? '',
                    enabled: false,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email, color: Colors.blue),
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (isStudent) ...[
                    TextFormField(
                      controller: _idFiliere,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.school,
                          color: Colors.blue,
                        ),
                        labelText: 'ID filière',
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requis';
                        if (int.tryParse(v.trim()) == null) {
                          return 'Entrez un nombre valide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _dateNaissance,
                      readOnly: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.calendar_today,
                          color: Colors.blue,
                        ),
                        labelText: 'Date de naissance',
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onTap: () async {
                        final now = DateTime.now();
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: now,
                          firstDate: DateTime(1900),
                          lastDate: now,
                        );
                        if (selectedDate != null) {
                          _dateNaissance.text = selectedDate
                              .toIso8601String()
                              .split('T')
                              .first;
                        }
                      },
                      validator: (v) {
                        if (v == null || v.isEmpty) return null;
                        try {
                          DateTime.parse(v.trim());
                          return null;
                        } catch (_) {
                          return 'Format AAAA-MM-JJ requis';
                        }
                      },
                    ),
                  ] else ...[
                    TextFormField(
                      controller: _grade,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.school,
                          color: Colors.blue,
                        ),
                        labelText: 'Grade',
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Requis' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _specialite,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.work, color: Colors.blue),
                        labelText: 'Spécialité',
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Requis' : null,
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _telephone,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.phone, color: Colors.blue),
                      labelText: 'Téléphone',
                      labelStyle: const TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requis';
                      final phone = v.trim();
                      final reg = RegExp(r'^\+?\d{8,}$');
                      if (!reg.hasMatch(phone)) {
                        return 'Au moins 8 chiffres requis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sudocolor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      'Enregistrer',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
