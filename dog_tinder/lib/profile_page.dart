import 'package:dog_tinder/globals.dart';
import 'package:flutter/material.dart';
import 'chat_history_page.dart';

// Mock user profile model - to be replaced with API data
class UserProfile {
  String dogName;
  DateTime birthDate;
  String description;
  String imageUrl;

  UserProfile({
    required this.dogName,
    required this.birthDate,
    required this.description,
    required this.imageUrl,
  });

  String getAgeString() {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;

    if (months < 0) {
      years--;
      months += 12;
    }

    if (now.day < birthDate.day) {
      months--;
      if (months < 0) {
        years--;
        months += 12;
      }
    }

    if (years == 0) {
      return '$months ${months == 1 ? "month" : "months"} old';
    } else if (months == 0) {
      return '$years ${years == 1 ? "year" : "years"} old';
    } else {
      return '$years ${years == 1 ? "year" : "years"} and $months ${months == 1 ? "month" : "months"} old';
    }
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditMode = false;
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late DateTime selectedBirthDate;
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode descriptionFocusNode = FocusNode();

  // Mock user data
  final userProfile = UserProfile(
    dogName: 'Bella',
    birthDate: DateTime(2021, 1, 15), // 4 years old approximately
    description: 'Friendly dog who loves to play fetch.',
    imageUrl:
        'https://images.unsplash.com/photo-1568572933382-74d440642117?w=800',
  );

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: userProfile.dogName);
    selectedBirthDate = userProfile.birthDate;
    descriptionController = TextEditingController(
      text: userProfile.description,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    nameFocusNode.dispose();
    descriptionFocusNode.dispose();
    super.dispose();
  }

  String _getAgeStringFromDate(DateTime birthDate) {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;

    if (months < 0) {
      years--;
      months += 12;
    }

    if (now.day < birthDate.day) {
      months--;
      if (months < 0) {
        years--;
        months += 12;
      }
    }

    if (years == 0) {
      return '$months ${months == 1 ? "month" : "months"} old';
    } else if (months == 0) {
      return '$years ${years == 1 ? "year" : "years"} old';
    } else {
      return '$years ${years == 1 ? "year" : "years"} and $months ${months == 1 ? "month" : "months"} old';
    }
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedBirthDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Select birth date',
    );
    if (picked != null && picked != selectedBirthDate) {
      setState(() {
        selectedBirthDate = picked;
      });
    }
  }

  void _toggleEditMode() {
    setState(() {
      if (isEditMode) {
        // Save changes
        userProfile.dogName = nameController.text;
        userProfile.birthDate = selectedBirthDate;
        userProfile.description = descriptionController.text;
      }
      isEditMode = !isEditMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        // Swipe up to go back to discovery page
        if (details.primaryVelocity! < -500) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(creamWhite),
        body: SafeArea(
          child: Column(
            children: [
              // Top Navigation Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Messages button
                    IconButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChatHistoryPage(),
                          ),
                        );
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(persimon),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chat_bubble,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    // Edit button
                    IconButton(
                      onPressed: _toggleEditMode,
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(persimon),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isEditMode ? Icons.check : Icons.edit_outlined,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Profile Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Profile Picture
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 80,
                              backgroundColor: const Color(ashGrey),
                              backgroundImage: NetworkImage(
                                userProfile.imageUrl,
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  userProfile.imageUrl,
                                  fit: BoxFit.cover,
                                  width: 160,
                                  height: 160,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.pets,
                                      size: 60,
                                      color: Colors.white,
                                    );
                                  },
                                ),
                              ),
                            ),
                            if (isEditMode)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(persimon),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Dog Name
                        if (isEditMode)
                          Stack(
                            children: [
                              TextField(
                                controller: nameController,
                                focusNode: nameFocusNode,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Dog name',
                                  filled: true,
                                  fillColor: const Color(lightGrey),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    nameFocusNode.requestFocus();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Color(persimon),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          Text(
                            userProfile.dogName,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(height: 8),
                        // Age
                        if (isEditMode)
                          GestureDetector(
                            onTap: _selectBirthDate,
                            child: Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(lightGrey),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _getAgeStringFromDate(selectedBirthDate),
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: const Color(darkGrey),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: GestureDetector(
                                    onTap: _selectBirthDate,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Color(persimon),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Text(
                            userProfile.getAgeString(),
                            style: TextStyle(
                              fontSize: 18,
                              color: const Color(darkGrey),
                            ),
                          ),
                        const SizedBox(height: 40),
                        // Profile Section Title
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Profile',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Description
                        if (isEditMode)
                          Stack(
                            children: [
                              TextField(
                                controller: descriptionController,
                                focusNode: descriptionFocusNode,
                                maxLines: 5,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: 'Description',
                                  filled: true,
                                  fillColor: const Color(lightGrey),
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                              ),
                              Positioned(
                                right: 8,
                                bottom: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    descriptionFocusNode.requestFocus();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Color(persimon),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              userProfile.description,
                              style: const TextStyle(fontSize: 16, height: 1.5),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              // Swipe up indicator
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Icon(
                      Icons.keyboard_arrow_up,
                      size: 30,
                      color: const Color(darkGrey),
                    ),
                    Icon(
                      Icons.keyboard_arrow_up,
                      size: 30,
                      color: const Color(ashGrey),
                    ),
                    Icon(
                      Icons.keyboard_arrow_up,
                      size: 30,
                      color: const Color(lightGrey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
