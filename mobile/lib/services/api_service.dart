import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter/foundation.dart';

class ApiService {
  static String get baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }
  final _storage = const FlutterSecureStorage();

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await _storage.write(key: 'jwt_token', value: data['access_token']);
      return data;
    } else {
      throw Exception('Failed to login (${response.statusCode}): ${response.body}');
    }
  }

  Future<Map<String, dynamic>> register(String email, String password, String name, String role) async {
      final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'name': name, 'role': role}),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register');
    }
  }

  Future<Map<String, dynamic>> getPatientTwin(int id) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/patients/$id/twin'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch twin data');
    }
  }

  Future<List<dynamic>> getPatients() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/patients'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch patients');
    }
  }

  Future<Map<String, dynamic>> getNavigationPath(int from, int to) async {
    final response = await http.get(Uri.parse('$baseUrl/navigation/path?from=$from&to=$to'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch path');
    }
  }

  Future<Map<String, dynamic>> sendVoiceCommand(String text) async {
    final response = await http.post(
        Uri.parse('$baseUrl/ai/voice/command'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text})
    );
     if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to process voice command');
    }
  }
}
