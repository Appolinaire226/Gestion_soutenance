//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vivatrack/pagesFolder/firebase_auth.dart';
import '../widgets/responsive_container.dart';
import 'redirect_page.dart';
import 'home_page.dart';

class ProfileCompletionPage extends StatefulWidget {
  final String role;
  const ProfileCompletionPage({super.key, this.role = 'student'});

  @override
  State<ProfileCompletionPage> createState() => _ProfileCompletionPageState();
}

class _ProfileCompletionPageState extends State<ProfileCompletionPage> {
  final _formKey = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _prenom = TextEditingController();
  final _matricule = TextEditingController();
  final _telephone = TextEditingController();
  final _filiere = TextEditingController();
  final _grade = TextEditingController();
  final _specialite = TextEditingController();
  String _niveau = 'L1';

  @override
  void dispose() {
    _nom.dispose();
    _prenom.dispose();
    _matricule.dispose();
    _telephone.dispose();
    _filiere.dispose();
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
      'role': widget.role,
      'email': SudoAuthService().currentEmail,
      'uid': null,
      //'updated_at': FieldValue.serverTimestamp(),
    };
    if (isStudent) {
      data['filiere'] = _filiere.text.trim();
      data['niveau'] = _niveau;
    } else {
      data['grade'] = _grade.text.trim();
      data['specialite'] = _specialite.text.trim();
    }

    try {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil enregistré avec succès.')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RedirectPage(role: widget.role),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
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
                  const SizedBox(height: 20),
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
                  if (isStudent) ...[
                    TextFormField(
                      controller: _filiere,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.book, color: Colors.blue),
                        labelText: 'Filière',
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
                    DropdownButtonFormField<String>(
                      value: _niveau,
                      items: const [
                        DropdownMenuItem(value: 'L1', child: Text('L1')),
                        DropdownMenuItem(value: 'L2', child: Text('L2')),
                        DropdownMenuItem(value: 'L3', child: Text('L3')),
                        DropdownMenuItem(value: 'M1', child: Text('M1')),
                        DropdownMenuItem(value: 'M2', child: Text('M2')),
                        DropdownMenuItem(
                          value: 'Master',
                          child: Text('Master'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _niveau = v ?? 'L1'),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.list, color: Colors.blue),
                        labelText: 'Niveau',
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
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
                      if (!reg.hasMatch(phone))
                        return 'Au moins 8 chiffres requis';
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
