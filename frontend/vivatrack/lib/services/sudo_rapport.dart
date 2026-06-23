import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:vivatrack/pagesFolder/firebase_auth.dart';

class SudoRapportService {
  final String baseUrl = 'https://gestion-soutenance1.onrender.com';
  final String endpoint = '/rapports';

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    final token = SudoAuthService().token;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<List<dynamic>> getAllRapports({int? idSession}) async {
    final uri = idSession != null
        ? Uri.parse('$baseUrl$endpoint/?id_session=$idSession')
        : Uri.parse('$baseUrl$endpoint/');
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Échec lecture rapports : ${response.statusCode}');
  }

  Future<Map<String, dynamic>> getRapport(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint/$id'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Rapport introuvable : ${response.statusCode}');
  }

  // ===== CRÉER UN RAPPORT =====
  // Payload: titre (requis), matricule (requis), id_session (requis),
  //          resume (opt), fichier_url (opt)
  // Retour: id_rapport, titre, resume, fichier_url, date_depot, id_etudiant, id_session, statut
  Future<Map<String, dynamic>> createRapport(Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl$endpoint/');
    final body = jsonEncode(data);
    debugPrint('[SudoRapportService] POST $uri body: $body');
    final response = await http.post(uri, headers: _headers, body: body);
    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    final responseBody = response.body.isNotEmpty ? response.body : 'no body';
    throw Exception(
      'Échec création rapport : ${response.statusCode} - $responseBody',
    );
  }

  Future<Map<String, dynamic>> updateRapport(
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
    throw Exception('Échec mise à jour rapport : ${response.statusCode}');
  }

  Future<void> deleteRapport(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint/$id'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Échec suppression rapport : ${response.statusCode}');
    }
  }
}
