import 'package:flutter/material.dart';
import 'globals.dart';
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

  Future<void> loginUser() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DiscoverPage()),
    );
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
              onPressed: loginUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(persimon),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text("Log In"),
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
