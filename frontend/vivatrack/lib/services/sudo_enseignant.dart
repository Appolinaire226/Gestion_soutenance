import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class SudoEnseignantService {
  final String baseUrl = kIsWeb
      ? 'https://gestion-soutenance1.onrender.com'
      : 'http://10.0.2.2:5000';
  final String endpoint = '/enseignants';

  Future<List<dynamic>> getAllEnseignants() async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint/'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Échec lecture enseignants : ${response.statusCode}');
  }

  Future<Map<String, dynamic>> getEnseignant(int id) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint/$id'));
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
