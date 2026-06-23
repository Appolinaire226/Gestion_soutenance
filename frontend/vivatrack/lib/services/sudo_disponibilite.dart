import 'dart:convert';
import 'package:http/http.dart' as http;
// Removed unused kIsWeb import
import 'package:vivatrack/pagesFolder/firebase_auth.dart';

class SudoDisponibiliteService {
  final String baseUrl = 'https://gestion-soutenance1.onrender.com';
  final String endpoint = '/enseignants';

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    final token = SudoAuthService().token;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<List<dynamic>> getDisponibilites(int idEnseignant) async {
    final uri = Uri.parse('$baseUrl$endpoint/$idEnseignant/disponibilites');
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Échec lecture disponibilités : ${response.statusCode}');
  }

  Future<Map<String, dynamic>> ajouterDisponibilite(
    int idEnseignant,
    Map<String, dynamic> data,
  ) async {
    final uri = Uri.parse('$baseUrl$endpoint/$idEnseignant/disponibilites');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Échec ajout disponibilité : ${response.statusCode}');
  }
}
