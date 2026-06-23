import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:vivatrack/pagesFolder/firebase_auth.dart';

class SudoEtudiantService {
  final String baseUrl = 'https://gestion-soutenance1.onrender.com';
  final String endpoint = '/etudiants';

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    final token = SudoAuthService().token;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<List<dynamic>> getAllEtudiants() async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint/'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Échec lecture étudiants : ${response.statusCode}');
  }

  Future<Map<String, dynamic>> getEtudiant(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint/$id'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Étudiant introuvable : ${response.statusCode}');
  }

  Future<Map<String, dynamic>?> getEtudiantByMatricule(String matricule) async {
    final uri = Uri.parse(
      '$baseUrl$endpoint/search?matricule=${Uri.encodeComponent(matricule)}',
    );
    debugPrint(
      '[SudoEtudiantService] GET $uri AuthorizationPresent=${_headers.containsKey('Authorization')}',
    );
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    if (response.statusCode == 404) return null;
    throw Exception(
      'Erreur recherche étudiant : ${response.statusCode} - ${response.body}',
    );
  }

  Future<Map<String, dynamic>> createEtudiant(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint/'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Échec création étudiant : ${response.statusCode}');
  }

  Future<Map<String, dynamic>> updateEtudiant(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Échec mise à jour étudiant : ${response.statusCode}');
  }

  Future<void> deleteEtudiant(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint/$id'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Échec suppression étudiant : ${response.statusCode}');
    }
  }
}
