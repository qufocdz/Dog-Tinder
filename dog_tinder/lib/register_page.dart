import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'globals.dart';
import 'discover_page.dart';
import 'services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool agreeToTerms = false;

  // New fields for dog-focused registration
  final TextEditingController dogNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController(); // readOnly, shows chosen date
  final TextEditingController descriptionController = TextEditingController();

  File? dogImageFile;
  final ImagePicker _picker = ImagePicker();
  DateTime? dogBirthdate;
  bool isLoading = false;

  Future<void> pickDogImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, maxHeight: 1200, imageQuality: 85);
    if (picked != null) {
      setState(() {
        dogImageFile = File(picked.path);
      });
    }
  }

  Future<void> pickBirthdate() async {
    final DateTime now = DateTime.now();
    final DateTime initial = DateTime(now.year - 2);
    final DateTime first = DateTime(now.year - 20);
    final DateTime last = now;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dogBirthdate ?? initial,
      firstDate: first,
      lastDate: last,
    );

    if (picked != null) {
      setState(() {
        dogBirthdate = picked;
        birthdateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> registerUser() async {
    // Basic validation
    final String dogName = dogNameController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text;
    final String description = descriptionController.text.trim();

    if (dogName.isEmpty || email.isEmpty || password.isEmpty || dogBirthdate == null || description.isEmpty || dogImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields and choose a dog photo.')));
      return;
    }

    if (!agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must agree to the Terms and Conditions.')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final resp = await AuthService.register(
        dogName: dogName,
        email: email,
        password: password,
        birthdate: birthdateController.text,
        description: description,
        dogImage: dogImageFile!,
      );

      // On success, update globals and navigate
      loggedIn = true;
      user = resp['user'] ?? resp;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DiscoverPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
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
    return !loggedIn
        ? Scaffold(
            backgroundColor: const Color(creamWhite),
            appBar: AppBar(
              title: const Text("Registration"),
              automaticallyImplyLeading: false,
              centerTitle: true,
              backgroundColor: const Color(persimon),
              foregroundColor: const Color(bleakWhite),
            ),
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Dog name
                    TextField(
                      controller: dogNameController,
                      decoration: const InputDecoration(
                        labelText: "Dog name",
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(richBlack),
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(richBlack),
                            width: 2.0,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.pets_outlined,
                          color: Color(richBlack),
                        ),
                        labelStyle: TextStyle(color: Color(richBlack)),
                      ),
                      cursorColor: const Color(persimon),
                      inputFormatters: [LengthLimitingTextInputFormatter(32)],
                    ),
                    const SizedBox(height: 16.0),

                    // Dog photo picker
                    Row(
                      children: [
                        GestureDetector(
                          onTap: pickDogImage,
                          child: dogImageFile != null
                              ? CircleAvatar(
                                  radius: 40,
                                  backgroundImage: FileImage(dogImageFile!),
                                )
                              : const CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Color(0xFFEFEFEF),
                                  child: Icon(Icons.add_a_photo_outlined, color: Color(richBlack)),
                                ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: pickDogImage,
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Choose dog photo'),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(persimon)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    // Email
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(richBlack),
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(richBlack),
                            width: 2.0,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Color(richBlack),
                        ),
                        labelStyle: TextStyle(color: Color(richBlack)),
                      ),
                      cursorColor: const Color(persimon),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16.0),

                    // Password
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(richBlack),
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(richBlack),
                            width: 2.0,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          color: Color(richBlack),
                        ),
                        labelStyle: TextStyle(color: Color(richBlack)),
                      ),
                      cursorColor: const Color(persimon),
                      obscureText: true,
                      inputFormatters: [LengthLimitingTextInputFormatter(64)],
                    ),
                    const SizedBox(height: 16.0),

                    // Birthdate picker
                    TextField(
                      controller: birthdateController,
                      readOnly: true,
                      onTap: pickBirthdate,
                      decoration: const InputDecoration(
                        labelText: "Dog birthdate",
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(richBlack),
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(richBlack),
                            width: 2.0,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.cake_outlined,
                          color: Color(richBlack),
                        ),
                        labelStyle: TextStyle(color: Color(richBlack)),
                      ),
                      cursorColor: const Color(persimon),
                    ),
                    const SizedBox(height: 16.0),

                    // Description
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: "Description",
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(richBlack),
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(richBlack),
                            width: 2.0,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.description_outlined,
                          color: Color(richBlack),
                        ),
                        labelStyle: TextStyle(color: Color(richBlack)),
                      ),
                      cursorColor: const Color(persimon),
                      maxLines: 4,
                      inputFormatters: [LengthLimitingTextInputFormatter(500)],
                    ),
                    const SizedBox(height: 16.0),

                    Row(
                      children: [
                        Checkbox(
                          value: agreeToTerms,
                          activeColor: const Color(persimon),
                          side: const BorderSide(
                            color: Colors.black,
                            width: 2.0,
                          ),
                          onChanged: (value) {
                            setState(() {
                              agreeToTerms = value!;
                            });
                          },
                        ),
                        const Expanded(
                          child: Text(
                            "I agree to the Terms and Conditions",
                            style: TextStyle(color: Color(richBlack)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: isLoading ? null : registerUser,
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
                          : const Text("Register"),
                    ),
                    const SizedBox(height: 16.0),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(richBlack),
                      ),
                      child: const Text("Already have an account? Log in"),
                    ),
                  ],
                ),
              ),
            ),
          )
        : const DiscoverPage();
  }
}

class PostalCodeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text;

    if (newText.length > 5) {
      newText = newText.substring(0, 5);
    }

    if (newText.length >= 3 && !newText.contains('-')) {
      newText = newText.substring(0, 2) + '-' + newText.substring(2);
    }

    String formattedText = newText.replaceAll(RegExp(r'[^0-9-]'), '');

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
