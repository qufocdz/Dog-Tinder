import 'package:flutter/material.dart';
import 'globals.dart';
import 'services/auth_service.dart';
import 'register_page.dart';
import 'discover_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> loginUser() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await AuthService.login(email: email, password: password);
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DiscoverPage()),
      );
    } catch (e) {
      final msg = e.toString();
      String friendly = 'Logowanie nie powiodło się.';
      if (msg.contains('Invalid credentials')) {
        friendly = 'Nieprawidłowy email lub hasło.';
      } else if (msg.contains('Missing fields')) {
        friendly = 'Podaj email i hasło.';
      } else if (msg.contains('Session expired')) {
        friendly = 'Sesja wygasła. Zaloguj się ponownie.';
      } else if (msg.contains('Login failed:')) {
        // show server-provided message if any
        final parts = msg.split(':');
        if (parts.length > 1) friendly = parts.sublist(1).join(':').trim();
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(friendly)));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(creamWhite),
      appBar: AppBar(
        title: const Text("Dog Tinder"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(persimon),
        foregroundColor: const Color(bleakWhite),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(richBlack), width: 2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(richBlack), width: 2.0),
                ),
                prefixIcon: Icon(Icons.email_outlined, color: Color(richBlack)),
                labelStyle: TextStyle(color: Color(richBlack)),
              ),
              cursorColor: const Color(persimon),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: "Password",
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(richBlack), width: 2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(richBlack), width: 2.0),
                ),
                prefixIcon: Icon(Icons.lock_outline, color: Color(richBlack)),
                labelStyle: TextStyle(color: Color(richBlack)),
              ),
              cursorColor: const Color(persimon),
              obscureText: true,
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: isLoading ? null : loginUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(persimon),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: Colors.white,
                      ),
                    )
                  : const Text("Log In"),
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(richBlack),
              ),
              child: const Text(
                "You don't have an account? Click here to register.",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
