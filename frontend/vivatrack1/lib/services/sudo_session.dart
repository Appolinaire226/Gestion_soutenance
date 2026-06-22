import 'dart:convert';
import 'package:http/http.dart' as http;
// Removed unused kIsWeb import
import 'package:vivatrack/pagesFolder/firebase_auth.dart';

class SudoSessionService {
  final String baseUrl = 'https://gestion-soutenance1.onrender.com';
  final String endpoint = '/sessions';

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    final token = SudoAuthService().token;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<List<dynamic>> getAllSessions() async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint/'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Échec lecture sessions : ${response.statusCode}');
  }

  Future<Map<String, dynamic>> getSession(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint/$id'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Session introuvable : ${response.statusCode}');
  }

  Future<Map<String, dynamic>> createSession(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint/'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Échec création session : ${response.statusCode}');
  }

  Future<Map<String, dynamic>> updateSession(
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
    throw Exception('Échec mise à jour session : ${response.statusCode}');
  }

  Future<void> deleteSession(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint/$id'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Échec suppression session : ${response.statusCode}');
    }
  }
}
