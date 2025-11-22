import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:dog_tinder/globals.dart';

const String? envApi = String.fromEnvironment('API_BASE_URL');
String get baseUrl {
  if (envApi != null && envApi!.isNotEmpty) return envApi!;
  if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows)
    return 'http://127.0.0.1:3000';
  if (defaultTargetPlatform == TargetPlatform.android)
    return 'http://10.0.2.2:3000';
  return 'http://127.0.0.1:3000';
}

class UserService {
  static Future<Map<String, dynamic>> getProfile(String id) async {
    final uri = Uri.parse('$baseUrl/api/user/$id');
    final token = authToken;

    final resp = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to get profile: ${resp.statusCode} ${resp.body}');
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String id,
    String? dogName,
    String? description,
    String? birthdate, // yyyy-mm-dd
    File? imageFile,
  }) async {
    final uri = Uri.parse('$baseUrl/api/user/$id');
    final token = authToken;

    if (imageFile != null) {
      final req = http.MultipartRequest('PUT', uri);
      if (token != null) {
        req.headers['Authorization'] = 'Bearer $token';
      }
      if (dogName != null) req.fields['dogName'] = dogName;
      if (description != null) req.fields['description'] = description;
      if (birthdate != null) req.fields['birthdate'] = birthdate;

      final stream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();
      final filename = imageFile.path.split(Platform.pathSeparator).last;
      req.files.add(
        http.MultipartFile('dogImage', stream, length, filename: filename),
      );

      final sent = await req.send();
      final resp = await http.Response.fromStream(sent);
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return json.decode(resp.body) as Map<String, dynamic>;
      }
      throw Exception('Update failed: ${resp.statusCode} ${resp.body}');
    } else {
      final resp = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          if (dogName != null) 'dogName': dogName,
          if (description != null) 'description': description,
          if (birthdate != null) 'birthdate': birthdate,
        }),
      );
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return json.decode(resp.body) as Map<String, dynamic>;
      }
      throw Exception('Update failed: ${resp.statusCode} ${resp.body}');
    }
  }
}
