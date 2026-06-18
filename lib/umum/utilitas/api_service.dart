import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  final String baseUrl = 'http://192.168.1.6:8000/api';

  ApiService._internal();

  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? data,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    return await http.post(
      url,
      headers: headers,
      body: data != null ? jsonEncode(data) : null,
    );
  }

  Future<http.Response> get(String endpoint, {String? token}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    return await http.get(url, headers: headers);
  }

  // Tambahkan PUT, DELETE jika butuh
}
