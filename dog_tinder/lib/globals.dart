import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Globalne zmienne
bool loggedIn = false;
Map<String, dynamic>? user;
String? authToken;

// Kolory
const int creamWhite = 0xFFFBFAF9;
const int bleakWhite = 0xFFF5F5F5;
const int richBlack = 0xFF001011;
const int ashGrey = 0xFFB0B0B0;
const int darkGrey = 0xFF4A4A4A;
const int lightGrey = 0xFFD9D9D9;
const int persimon = 0xFFEC5800;

class TokenManager {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  /// Zapis tokena
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    authToken = token;
  }

  /// Zapis danych usera jako JSON
  static Future<void> saveUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
    user = userData;
  }

  /// Odczyt tokena
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString(_tokenKey);
    return authToken;
  }

  /// Odczyt usera z pamięci (SharedPreferences) – używane np. w ChatHistoryPage
  static Future<Map<String, dynamic>?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_userKey);
    if (str == null) return null;

    try {
      final data = jsonDecode(str) as Map<String, dynamic>;
      user = data;
      return data;
    } catch (_) {
      return null;
    }
  }

  /// Wylogowanie – czyścimy wszystko
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    authToken = null;
    user = null;
    loggedIn = false;
  }

  /// Sprawdzenie, czy mamy zapisany token
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      loggedIn = true;
      return true;
    }
    loggedIn = false;
    return false;
  }
}
