import 'package:flutter/material.dart';
import 'globals.dart';
import 'chat_history_page.dart';
import 'services/chat_service.dart' show baseUrl; // tylko baseUrl
import 'services/user_service.dart' show UserService; // tylko klasa

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

  @override
  void initState() {
    super.initState();
    final u = user ?? {};
    nameController =
        TextEditingController(text: (u['dogName'] ?? '').toString());
    descriptionController =
        TextEditingController(text: (u['description'] ?? '').toString());
    selectedBirthDate =
        _parseIso(u['birthdate']?.toString()) ?? DateTime(2020, 1, 1);
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    nameFocusNode.dispose();
    descriptionFocusNode.dispose();
    super.dispose();
  }

  DateTime? _parseIso(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    try {
      return DateTime.parse(iso);
    } catch (_) {
      return null;
    }
  }

  String _ageString(DateTime? birth) {
    if (birth == null) return '-';
    final now = DateTime.now();
    int years = now.year - birth.year;
    int months = now.month - birth.month;
    if (now.day < birth.day) months--;
    if (months < 0) {
      years--;
      months += 12;
    }
    if (years <= 0) return '$months ${months == 1 ? "month" : "months"} old';
    if (months == 0) return '$years ${years == 1 ? "year" : "years"} old';
    return '$years ${years == 1 ? "year" : "years"} and $months ${months == 1 ? "month" : "months"} old';
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '-';
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  String _imageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    return '$baseUrl/uploads/$imagePath';
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
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

  Future<void> _toggleEditMode() async {
    if (isEditMode) {
      final u = user ?? {};
      final rawId = (u['id'] ?? u['_id']);
      final id = (rawId ?? '').toString();
      if (id.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please log in again.')),
          );
        }
        return;
      }

      final dogName = nameController.text.trim();
      final description = descriptionController.text.trim();
      final b = selectedBirthDate;
      final birthStr =
          '${b.year}-${b.month.toString().padLeft(2, '0')}-${b.day.toString().padLeft(2, '0')}';

      try {
        final resp = await UserService.updateProfile(
          id: id,
          dogName: dogName,
          description: description,
          birthdate: birthStr,
          // imageFile: <dodasz później>
        );

        setState(() {
          user = resp['user'] ?? resp;
          nameController.text = (user?['dogName'] ?? '').toString();
          descriptionController.text =
              (user?['description'] ?? '').toString();
          selectedBirthDate =
              _parseIso(user?['birthdate']?.toString()) ?? selectedBirthDate;
          isEditMode = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile saved')),
          );
        }
        return;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Save failed: $e')),
          );
        }
        return;
      }
    } else {
      setState(() => isEditMode = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = user ?? {};
    final dogName = (u['dogName'] ?? '').toString();
    final email = (u['email'] ?? '').toString();
    final imagePath = (u['imagePath'] ?? '').toString();
    final birthIso = _parseIso(u['birthdate']?.toString());
    final imageUrl = _imageUrl(imagePath);

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! < -500) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(creamWhite),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ChatHistoryPage()),
                        );
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(persimon),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chat_bubble,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _toggleEditMode,
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(persimon),
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
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 80,
                              backgroundColor: const Color(ashGrey),
                              backgroundImage: imageUrl.isNotEmpty
                                  ? NetworkImage(imageUrl)
                                  : null,
                              child: imageUrl.isEmpty
                                  ? const Icon(Icons.pets,
                                      size: 60, color: Colors.white)
                                  : null,
                            ),
                            if (isEditMode)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(persimon),
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
                        if (isEditMode)
                          Stack(
                            children: [
                              TextField(
                                controller: nameController,
                                focusNode: nameFocusNode,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Dog name',
                                  filled: true,
                                  fillColor: const Color(lightGrey),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                ),
                              ),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: GestureDetector(
                                  onTap: () => nameFocusNode.requestFocus(),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: const Color(persimon),
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
                            dogName.isNotEmpty
                                ? dogName
                                : (u['dogName'] ?? '').toString(),
                            style: const TextStyle(
                                fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                        const SizedBox(height: 8),
                        if (isEditMode)
                          GestureDetector(
                            onTap: _selectBirthDate,
                            child: Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(lightGrey),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _ageString(selectedBirthDate),
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
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: const Color(persimon),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Text(
                            _ageString(birthIso),
                            style: TextStyle(
                              fontSize: 18,
                              color: const Color(darkGrey),
                            ),
                          ),
                        const SizedBox(height: 40),
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
                                  onTap: () =>
                                      descriptionFocusNode.requestFocus(),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: const Color(persimon),
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
                              (u['description'] ?? '').toString(),
                              style: const TextStyle(
                                  fontSize: 16, height: 1.5),
                            ),
                          ),
                        const SizedBox(height: 24),
                        _infoTile(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: email,
                        ),
                        _infoTile(
                          icon: Icons.cake_outlined,
                          label: 'Birthdate',
                          value: _formatDate(birthIso),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Icon(Icons.keyboard_arrow_up,
                        size: 30, color: const Color(darkGrey)),
                    Icon(Icons.keyboard_arrow_up,
                        size: 30, color: const Color(ashGrey)),
                    Icon(Icons.keyboard_arrow_up,
                        size: 30, color: const Color(lightGrey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(richBlack)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
