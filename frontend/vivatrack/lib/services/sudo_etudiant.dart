import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class SudoEtudiantService {
  final String baseUrl = kIsWeb
      ? 'https://gestion-soutenance1.onrender.com'
      : 'http://10.0.2.2:5000';
  final String endpoint = '/etudiants';

  Future<List<dynamic>> getAllEtudiants() async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint/'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Échec lecture étudiants : ${response.statusCode}');
  }

  Future<Map<String, dynamic>> getEtudiant(int id) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint/$id'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Étudiant introuvable : ${response.statusCode}');
  }

  Future<Map<String, dynamic>> createEtudiant(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint/'),
      headers: {'Content-Type': 'application/json'},
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
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Échec mise à jour étudiant : ${response.statusCode}');
  }

  Future<void> deleteEtudiant(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl$endpoint/$id'));
    if (response.statusCode != 200) {
      throw Exception('Échec suppression étudiant : ${response.statusCode}');
    }
  }
}
