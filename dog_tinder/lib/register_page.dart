import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'globals.dart';
import 'discover_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool agreeToTerms = false;

  final TextEditingController nameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController streetAndNumberController =
      TextEditingController();

  final TextEditingController postalCodeController = TextEditingController();

  final TextEditingController cityController = TextEditingController();

  final TextEditingController countryController = TextEditingController();

  Future<void> registerUser() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DiscoverPage()),
    );
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
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Full Name",
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
                          Icons.person_2_outlined,
                          color: Color(richBlack),
                        ),
                        labelStyle: TextStyle(color: Color(richBlack)),
                      ),
                      cursorColor: const Color(persimon),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r"[a-zA-ZąćęłńóśźżĄĘŁŃÓŚŹŻ\s]"),
                        ),
                        LengthLimitingTextInputFormatter(32),
                      ],
                    ),
                    const SizedBox(height: 16.0),
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
                      inputFormatters: [LengthLimitingTextInputFormatter(32)],
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: "Phone number",
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
                          Icons.phone_outlined,
                          color: Color(richBlack),
                        ),
                        prefixText: "+48 ",
                        prefixStyle: TextStyle(
                          color: Color(richBlack),
                          fontSize: 16.0,
                        ),
                        labelStyle: TextStyle(color: Color(richBlack)),
                      ),
                      cursorColor: const Color(persimon),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(9),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: streetAndNumberController,
                      decoration: const InputDecoration(
                        labelText: "Street and number",
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
                          Icons.add_location_outlined,
                          color: Color(richBlack),
                        ),
                        labelStyle: TextStyle(color: Color(richBlack)),
                      ),
                      cursorColor: const Color(persimon),
                      inputFormatters: [LengthLimitingTextInputFormatter(32)],
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: postalCodeController,
                      decoration: const InputDecoration(
                        labelText: "Postal code",
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
                          Icons.local_post_office_outlined,
                          color: Color(richBlack),
                        ),
                        labelStyle: TextStyle(color: Color(richBlack)),
                      ),
                      cursorColor: const Color(persimon),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        PostalCodeFormatter(),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: cityController,
                      decoration: const InputDecoration(
                        labelText: "City",
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
                          Icons.location_city_outlined,
                          color: Color(richBlack),
                        ),
                        labelStyle: TextStyle(color: Color(richBlack)),
                      ),
                      cursorColor: const Color(persimon),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r"[a-zA-ZąćęłńóśźżĄĘŁŃÓŚŹŻ\s]"),
                        ),
                        LengthLimitingTextInputFormatter(32),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: countryController,
                      decoration: const InputDecoration(
                        labelText: "Country",
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
                          Icons.public_outlined,
                          color: Color(richBlack),
                        ),
                        labelStyle: TextStyle(color: Color(richBlack)),
                      ),
                      cursorColor: const Color(persimon),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r"[a-zA-ZąćęłńóśźżĄĘŁŃÓŚŹŻ\s]"),
                        ),
                        LengthLimitingTextInputFormatter(32),
                      ],
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
                      onPressed: registerUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(persimon),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: const Text("Register"),
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
