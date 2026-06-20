import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class SudoRapportService {
  final String baseUrl = kIsWeb
      ? 'https://gestion-soutenance1.onrender.com'
      : 'http://10.0.2.2:5000';
  final String endpoint = '/rapports';

  Future<List<dynamic>> getAllRapports({int? idSession}) async {
    final uri = idSession != null
        ? Uri.parse('$baseUrl$endpoint/?id_session=$idSession')
        : Uri.parse('$baseUrl$endpoint/');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Échec lecture rapports : ${response.statusCode}');
  }

  Future<Map<String, dynamic>> getRapport(int id) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint/$id'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Rapport introuvable : ${response.statusCode}');
  }

  Future<Map<String, dynamic>> createRapport(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Échec création rapport : ${response.statusCode}');
  }

  Future<Map<String, dynamic>> updateRapport(
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
    throw Exception('Échec mise à jour rapport : ${response.statusCode}');
  }

  Future<void> deleteRapport(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl$endpoint/$id'));
    if (response.statusCode != 200) {
      throw Exception('Échec suppression rapport : ${response.statusCode}');
    }
  }
}
