import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

const String? envApi = String.fromEnvironment('API_BASE_URL');

String get baseUrl {
  if (envApi != null && envApi!.isNotEmpty) return envApi!;
  if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) return 'http://127.0.0.1:3000';
  if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:3000';
  return 'http://127.0.0.1:3000';
}

class ChatService {
  static Future<Map<String, dynamic>> swipe({
    required String fromUserId,
    required String toUserId,
    required bool like,
  }) async {
    final uri = Uri.parse('$baseUrl/api/swipe');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'action': like ? 'like' : 'pass',
      }),
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Swipe failed: ${resp.statusCode} ${resp.body}');
  }

  static Future<List<dynamic>> fetchChats(String userId) async {
    final uri = Uri.parse('$baseUrl/api/chats?userId=$userId');
    final resp = await http.get(uri);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final data = json.decode(resp.body) as Map<String, dynamic>;
      return (data['chats'] as List?) ?? [];
    }
    throw Exception('fetchChats failed: ${resp.statusCode} ${resp.body}');
  }

  static Future<List<dynamic>> fetchMessages(String matchId) async {
    final uri = Uri.parse('$baseUrl/api/messages?matchId=$matchId');
    final resp = await http.get(uri);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final data = json.decode(resp.body) as Map<String, dynamic>;
      return (data['messages'] as List?) ?? [];
    }
    throw Exception('fetchMessages failed: ${resp.statusCode} ${resp.body}');
  }

  static Future<void> sendMessage({
    required String matchId,
    required String fromUserId,
    required String text,
  }) async {
    final uri = Uri.parse('$baseUrl/api/messages');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'matchId': matchId, 'fromUserId': fromUserId, 'text': text}),
    );
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('sendMessage failed: ${resp.statusCode} ${resp.body}');
    }
  }
}
