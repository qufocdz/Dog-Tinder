import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'globals.dart';
import 'chat_history_page.dart';
import 'profile_page.dart';
import 'services/chat_service.dart'; // baseUrl + ChatService

class DogProfile {
  final String id;
  final String name;
  final int age;
  final String description;
  final String imageUrl;

  DogProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.description,
    required this.imageUrl,
  });
}

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  List<DogProfile> dogs = [];
  int currentIndex = 0;
  bool loading = true;
  String? errorText;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  String _imageUrlFrom(Map<String, dynamic> e) {
    // Try new imageUrlDb endpoint first
    final imageUrlDb = (e['imageUrlDb'] ?? '').toString();
    if (imageUrlDb.isNotEmpty && imageUrlDb.startsWith('/')) {
      return '$baseUrl$imageUrlDb';
    }
    if (imageUrlDb.isNotEmpty && imageUrlDb.startsWith('http')) {
      return imageUrlDb;
    }
    // Fallback to old imagePath for compatibility
    final imagePath = (e['imagePath'] ?? '').toString();
    if (imagePath.isNotEmpty) {
      return '$baseUrl/uploads/$imagePath';
    }
    final direct = (e['imageUrl'] ?? '').toString();
    if (direct.startsWith('http')) {
      return direct;
    }
    return '';
  }

  Future<void> _loadCandidates() async {
    try {
      final u = user ?? {};
      final me = ((u['id'] ?? u['_id']) ?? '').toString();
      if (me.isEmpty) {
        setState(() {
          loading = false;
          errorText = 'Please log in again.';
        });
        return;
      }

      final uri = Uri.parse('$baseUrl/api/discover?userId=$me');
      final resp = await http.get(uri);

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final data = json.decode(resp.body) as Map<String, dynamic>;
        final list = (data['users'] as List?) ?? [];

        final parsed = list.map<DogProfile>((raw) {
          final e = Map<String, dynamic>.from(raw as Map);
          final id = ((e['id'] ?? e['_id']) ?? '').toString();
          final name = (e['dogName'] ?? e['name'] ?? 'Doggo').toString();
          final desc = (e['description'] ?? '').toString();
          final img = _imageUrlFrom(e);

          return DogProfile(
            id: id,
            name: name,
            age: 3, // jeśli backend nie zwraca wieku
            description: desc,
            imageUrl: img.isEmpty
                ? 'https://picsum.photos/seed/$id/800/600'
                : img,
          );
        }).toList();

        if (!mounted) return;
        setState(() {
          dogs = parsed;
          currentIndex = 0;
          loading = false;
          errorText = null;
        });
      } else {
        throw Exception('HTTP ${resp.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        errorText = 'Failed to load dogs: $e';
      });
    }
  }

  Future<void> _handleReject() async {
    if (currentIndex >= dogs.length) return;

    final u = user ?? {};
    final me = ((u['id'] ?? u['_id']) ?? '').toString();
    if (me.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please log in again.')));
      }
      return;
    }

    final to = dogs[currentIndex].id;

    try {
      await ChatService.swipe(fromUserId: me, toUserId: to, like: false);
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      currentIndex++;
    });
  }

  Future<void> _handleMatch() async {
    if (currentIndex >= dogs.length) return;

    final u = user ?? {};
    final me = ((u['id'] ?? u['_id']) ?? '').toString();
    if (me.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please log in again.')));
      }
      return;
    }

    final dog = dogs[currentIndex];
    final to = dog.id;

    try {
      final res = await ChatService.swipe(
        fromUserId: me,
        toUserId: to,
        like: true,
      );

      if (!mounted) return;
      setState(() {
        currentIndex++;
      });

      if (res['matched'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("It's a match with ${dog.name}!")),
        );
        // tu możesz przejść od razu do ekranu czatu
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Swipe failed: $e')));
      setState(() {
        currentIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(creamWhite),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatHistoryPage(),
                        ),
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
                  const Text(
                    'Discover',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    },
                    icon: CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(ashGrey),
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            if (loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (errorText != null)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(errorText!, textAlign: TextAlign.center),
                  ),
                ),
              )
            else
              Expanded(
                child: currentIndex < dogs.length
                    ? _buildDogCard(dogs[currentIndex])
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'There are no more dogs in your neighborhood! Maybe try expanding your search area.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: const Color(ashGrey),
                            ),
                          ),
                        ),
                      ),
              ),
            if (!loading && errorText == null && currentIndex < dogs.length)
              Padding(
                padding: const EdgeInsets.only(bottom: 32, top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      icon: Icons.close,
                      color: const Color(persimon),
                      onPressed: _handleReject,
                    ),
                    const SizedBox(width: 40),
                    _buildActionButton(
                      icon: Icons.favorite,
                      color: const Color(persimon),
                      onPressed: _handleMatch,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDogCard(DogProfile dog) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  dog.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(lightGrey),
                      child: const Center(
                        child: Icon(Icons.pets, size: 80, color: Colors.white),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: const Color(lightGrey),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dog.name,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${dog.age} years old',
                  style: TextStyle(fontSize: 18, color: const Color(darkGrey)),
                ),
                const SizedBox(height: 12),
                Text(
                  dog.description,
                  style: TextStyle(fontSize: 16, color: const Color(darkGrey)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: const Color(creamWhite),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 36),
      ),
    );
  }
}
