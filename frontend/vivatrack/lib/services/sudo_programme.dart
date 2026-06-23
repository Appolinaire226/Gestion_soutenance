import 'dart:convert';
import 'package:http/http.dart' as http;
// Removed unused kIsWeb import
import 'package:vivatrack/pagesFolder/firebase_auth.dart';

class SudoProgrammeService {
  final String baseUrl = 'https://gestion-soutenance1.onrender.com';
  final String endpoint = '/programme';

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    final token = SudoAuthService().token;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<List<dynamic>> getProgrammesBySession(int idSession) async {
    final uri = Uri.parse('$baseUrl$endpoint/session/$idSession');
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Échec lecture programme : ${response.statusCode}');
  }

  Future<List<dynamic>> getAllProgrammes() async {
    final uri = Uri.parse('$baseUrl$endpoint/');
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Échec lecture programmes : ${response.statusCode}');
  }

  Future<Map<String, dynamic>> generateProgramme(int idSession) async {
    final uri = Uri.parse('$baseUrl$endpoint/generer/$idSession');
    final response = await http.post(uri, headers: _headers);
    if (response.statusCode == 201 || response.statusCode == 207) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Échec génération programme : ${response.statusCode}');
  }
}
