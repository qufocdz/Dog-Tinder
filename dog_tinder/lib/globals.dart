import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Global variables
bool loggedIn = false;
Map<String, dynamic>? user;
String? authToken;

// Colors
const int creamWhite = 0xFFFBFAF9;
const int bleakWhite = 0xFFF5F5F5;
const int richBlack = 0xFF001011;
const int ashGrey = 0xFFB0B0B0;
const int darkGrey = 0xFF4A4A4A;
const int lightGrey = 0xFFD9D9D9;
const int persimon = 0xFFEC5800;

// Token management functions
class TokenManager {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    authToken = token;
  }

  /// Zapisujemy usera jako JSON i aktualizujemy globalną zmienną `user`
  static Future<void> saveUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
    user = userData;
  }

  /// Wczytujemy usera z pamięci (SharedPreferences) do globalnej zmiennej
  static Future<Map<String, dynamic>?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_userKey);
    if (stored == null) return null;

    try {
      final map = jsonDecode(stored) as Map<String, dynamic>;
      user = map;
      return map;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString(_tokenKey);
    return authToken;
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    authToken = null;
    user = null;
    loggedIn = false;
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      // przy okazji spróbujmy wczytać usera
      await loadUser();
      loggedIn = true;
      return true;
    }
    loggedIn = false;
    return false;
  }
}
