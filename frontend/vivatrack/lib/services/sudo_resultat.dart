import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vivatrack/pagesFolder/firebase_auth.dart';

class SudoResultatService {
  final String baseUrl = 'https://gestion-soutenance1.onrender.com';
  final String endpoint = '/resultats';

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    final token = SudoAuthService().token;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> getResultatByProgramme(int idProgramme) async {
    final uri = Uri.parse('$baseUrl$endpoint/programme/$idProgramme');
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Échec lecture résultat : ${response.statusCode}');
  }

  Future<Map<String, dynamic>> saisirResultat(
    int idProgramme,
    double note,
    String mention,
    String? observation,
  ) async {
    final uri = Uri.parse('$baseUrl$endpoint/');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'id_programme': idProgramme,
        'note': note,
        'mention': mention,
        'observation': observation,
      }),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Échec enregistrement résultat : ${response.statusCode}');
  }
}
