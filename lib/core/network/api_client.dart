import 'dart:convert';
import "package:http/http.dart" as http show Client;
import 'package:parent_5sur5/core/error/exceptions.dart';

class ApiClient {
  final http.Client client;

  ApiClient(this.client);

  Future<Map<String, dynamic>> post(String url, Map<String, dynamic> body) async {
    final response = await client.post(
      Uri.parse(url),
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ServerException(); // Utiliser l'exception personnalisée
    }
  }
}
