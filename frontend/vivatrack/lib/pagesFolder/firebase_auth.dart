import 'dart:convert';

import 'package:http/http.dart' as http;

class SudoAuthService {
  static String? _token;
  static String? _email;
  static String? _role;

  String? get currentEmail => _email;
  String? get currentRole => _role;
  String? get token => _token;

  // URL de base du backend hébergé sur Render
  final Uri backendBase = Uri.parse('https://gestion-soutenance1.onrender.com');

  // Connexion : envoie email/mot_de_passe au backend et stocke token + role
  Future<void> loginInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final url = Uri.parse('${backendBase.toString()}/auth/login');

    final body = jsonEncode({'email': email, 'mot_de_passe': password});

    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Connexion échouée : ${resp.body}');
    }

    final Map<String, dynamic> data = jsonDecode(resp.body);
    _token = data['token'] as String?;
    _role = data['role'] as String?;
    _email = email;
  }

  // Inscription : enregistre l'utilisateur dans le backend
  Future<void> createUserWithEmailAndPassword(
    String email,
    String password,
    String role,
  ) async {
    final url = Uri.parse('${backendBase.toString()}/auth/register');

    final body = jsonEncode({
      'email': email,
      'mot_de_passe': password,
      'role': role,
    });

    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Enregistrement backend échoué: ${resp.body}');
    }

    // Après création côté backend, on conserve l'email/role localement (sans token).
    _email = email;
    _role = role;
  }

  // Déconnexion locale : efface le token / email / role
  Future<void> signOut() async {
    _token = null;
    _email = null;
    _role = null;
  }
}
