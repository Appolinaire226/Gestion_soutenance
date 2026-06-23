import 'dart:convert';
import 'package:http/http.dart' as http;
// Removed unused import of kIsWeb

class SudoService {
  // Utilise l'instance Render (hébergée) pour toutes les plateformes
  final String baseUrl = 'https://gestion-soutenance1.onrender.com';

  Future<void> createData(String endpoint, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 201) {
      throw Exception(
        'Échec de la création sur $endpoint : ${response.statusCode}',
      );
    }
  }

  Future<List<dynamic>> readData(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception(
      'Échec de la lecture sur $endpoint : ${response.statusCode}',
    );
  }

  Future<Map<String, dynamic>> readItem(String endpoint, int id) async {
    final uri = Uri.parse('$baseUrl$endpoint/$id');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception(
      'Échec de la lecture sur $endpoint/$id : ${response.statusCode}',
    );
  }

  Future<void> updateData(
    String endpoint,
    int id,
    Map<String, dynamic> data,
  ) async {
    final uri = Uri.parse('$baseUrl$endpoint/$id');
    final response = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Échec de la mise à jour sur $endpoint/$id : ${response.statusCode}',
      );
    }
  }

  Future<void> deleteData(String endpoint, int id) async {
    final uri = Uri.parse('$baseUrl$endpoint/$id');
    final response = await http.delete(uri);
    if (response.statusCode != 200) {
      throw Exception(
        'Échec de la suppression sur $endpoint/$id : ${response.statusCode}',
      );
    }
  }
}
