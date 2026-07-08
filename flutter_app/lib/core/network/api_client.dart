import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'http://localhost:5000/api';
  String? _jwtToken;

  void setToken(String token) {
    _jwtToken = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_jwtToken != null) 'Authorization': 'Bearer $_jwtToken',
      };

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$endpoint'), headers: _headers);
      return _processResponse(response);
    } catch (e) {
      throw Exception('Network connection failed: $e');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(body),
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception('Network connection failed: $e');
    }
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      final err = json.decode(response.body);
      throw Exception(err['error'] ?? 'API request failed with status: ${response.statusCode}');
    }
  }
}
