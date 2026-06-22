import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show debugPrint;

class SudoAuthService {
  static String? _token;
  static String? _email;
  static String? _role;

  String? get currentEmail => _email;
  String? get currentRole => _role;
  String? get token => _token;

  int? get currentIdEnseignant {
    if (_token == null) return null;
    final parts = _token!.split('.');
    if (parts.length != 3) return null;
    try {
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> claims = jsonDecode(decoded);
      final id = claims['id_enseignant'];
      if (id is int) return id;
      if (id is String) return int.tryParse(id);
      return null;
    } catch (_) {
      return null;
    }
  }

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

  // Inscription : enregistre l'utilisateur dans le backend Render
  Future<void> createUserWithEmailAndPassword(
    String email,
    String password,
    String role,
  ) async {
    final url = backendBase.replace(path: '/auth/register');

    final body = jsonEncode({
      'email': email,
      'mot_de_passe': password,
      'role': role,
    });

    debugPrint('Inscription payload: $body');

    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (resp.statusCode != 201) {
      throw Exception('Échec de l’inscription : ${resp.body}');
    }

    // Après création côté backend, se connecter automatiquement pour obtenir un token.
    _email = email;
    _role = role;
    await loginInWithEmailAndPassword(email, password);
  }

  // Déconnexion locale : efface le token / email / role
  Future<void> signOut() async {
    _token = null;
    _email = null;
    _role = null;
  }
}
