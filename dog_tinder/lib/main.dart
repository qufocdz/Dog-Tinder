import 'package:flutter/material.dart';
import 'package:dog_tinder/login_page.dart';
import 'package:dog_tinder/discover_page.dart';
import 'package:dog_tinder/globals.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isCheckingAuth = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await TokenManager.isLoggedIn();
      if (isLoggedIn) {
        // Try to get user profile to verify token is still valid
        final token = await TokenManager.getToken();
        if (token != null && token.isNotEmpty) {
          setState(() {
            _isLoggedIn = true;
            loggedIn = true;
          });
        }
      }
    } catch (e) {
      // If there's an error, clear any stored auth data
      await TokenManager.clearToken();
    } finally {
      setState(() {
        _isCheckingAuth = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _isCheckingAuth
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _isLoggedIn
          ? const DiscoverPage()
          : const LoginPage(),
    );
  }
}
