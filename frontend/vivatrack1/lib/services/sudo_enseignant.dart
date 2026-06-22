import 'dart:convert';
import 'package:http/http.dart' as http;
// Removed unused kIsWeb import
import 'package:vivatrack/pagesFolder/firebase_auth.dart';

class SudoEnseignantService {
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

  Future<List<dynamic>> getAllEnseignants() async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint/'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Échec lecture enseignants : ${response.statusCode}');
  }

  Future<Map<String, dynamic>> getEnseignant(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint/$id'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Enseignant introuvable : ${response.statusCode}');
  }

  Future<Map<String, dynamic>> createEnseignant(
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Échec création enseignant : ${response.statusCode}');
  }

  Future<Map<String, dynamic>> updateEnseignant(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Échec mise à jour enseignant : ${response.statusCode}');
  }

  Future<void> deleteEnseignant(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl$endpoint/$id'));
    if (response.statusCode != 200) {
      throw Exception('Échec suppression enseignant : ${response.statusCode}');
    }
  }
}
