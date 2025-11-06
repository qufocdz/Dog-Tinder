import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Simple auth service to communicate with the backend REST API.
///
/// NOTE: Update [apiBaseUrl] to point to your server. If you run the server
/// locally and use Android emulator, use http://10.0.2.2:3000
const String apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:3000');

class AuthService {
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
  request.files.add(http.MultipartFile('dogImage', fileStream, length, filename: filename));

    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return json.decode(resp.body) as Map<String, dynamic>;
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

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return json.decode(resp.body) as Map<String, dynamic>;
    } else if (resp.statusCode == 401) {
      throw Exception('Invalid credentials');
    } else if (resp.statusCode == 400) {
      throw Exception('Missing fields');
    } else {
      throw Exception('Login failed: ${resp.statusCode} ${resp.body}');
    }
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

