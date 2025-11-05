import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../globals.dart';

/// Simple auth service to communicate with the backend REST API.
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000',
);

class AuthService {
  /// Get headers with authorization token if available
  static Future<Map<String, String>> _getHeaders({
    bool includeAuth = false,
  }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (includeAuth) {
      final token = await TokenManager.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Registers a new user. Sends multipart/form-data with the dog image.
  /// Returns a Map parsed from JSON response on success, or throws an exception.
  static Future<Map<String, dynamic>> register({
    required String dogName,
    required String email,
    required String password,
    required String birthdate, // yyyy-mm-dd
    required String description,
    required File dogImage,
  }) async {
    final uri = Uri.parse('$apiBaseUrl/api/register');

    final request = http.MultipartRequest('POST', uri);
    request.fields['dogName'] = dogName;
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['birthdate'] = birthdate;
    request.fields['description'] = description;

    final fileStream = http.ByteStream(dogImage.openRead());
    final length = await dogImage.length();

    final filename = dogImage.path.split(Platform.pathSeparator).last;
    request.files.add(
      http.MultipartFile('dogImage', fileStream, length, filename: filename),
    );

    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final data = json.decode(resp.body) as Map<String, dynamic>;

      // Save token and user data if registration successful
      if (data['success'] == true && data['token'] != null) {
        await TokenManager.saveToken(data['token']);
        await TokenManager.saveUser(data['user']);
        loggedIn = true;
        user = data['user'];
      }

      return data;
    } else {
      throw Exception('Register failed: ${resp.statusCode} ${resp.body}');
    }
  }

  /// Log in an existing user using email and password.
  /// Returns a Map parsed from JSON response on success, or throws an exception.
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$apiBaseUrl/api/login');
    final headers = await _getHeaders();

    final resp = await http.post(
      uri,
      headers: headers,
      body: json.encode({'email': email, 'password': password}),
    );

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final data = json.decode(resp.body) as Map<String, dynamic>;

      // Save token and user data if login successful
      if (data['success'] == true && data['token'] != null) {
        await TokenManager.saveToken(data['token']);
        await TokenManager.saveUser(data['user']);
        loggedIn = true;
        user = data['user'];
      }

      return data;
    } else if (resp.statusCode == 401) {
      throw Exception('Invalid credentials');
    } else if (resp.statusCode == 400) {
      throw Exception('Missing fields');
    } else {
      throw Exception('Login failed: ${resp.statusCode} ${resp.body}');
    }
  }

  /// Logout user and clear stored data
  static Future<void> logout() async {
    await TokenManager.clearToken();
  }

  /// Check if user is currently logged in with valid token
  static Future<bool> isLoggedIn() async {
    return await TokenManager.isLoggedIn();
  }
}

// Minimal mime-type lookup to avoid extra dependencies
String? lookupMimeType(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
  if (lower.endsWith('.gif')) return 'image/gif';
  return null;
}
