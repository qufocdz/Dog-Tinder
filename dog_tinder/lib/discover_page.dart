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
    _checkUnseenMatches();
    _loadCandidates();
  }

  Future<void> _checkUnseenMatches() async {
    try {
      final u = user ?? {};
      final me = ((u['id'] ?? u['_id']) ?? '').toString();
      if (me.isEmpty) return;

      final uri = Uri.parse('$baseUrl/api/matches/unseen?userId=$me');
      final resp = await http.get(uri);

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final data = json.decode(resp.body) as Map<String, dynamic>;
        final matches = (data['matches'] as List?) ?? [];

        if (matches.isNotEmpty && mounted) {
          // Show popups for each unseen match with delay
          for (int i = 0; i < matches.length; i++) {
            await Future.delayed(
              Duration(milliseconds: i * 500),
            ); // Delay between popups
            if (!mounted) return;

            final matchData = Map<String, dynamic>.from(matches[i] as Map);
            final matchId = matchData['matchId'].toString();
            final userData = Map<String, dynamic>.from(
              matchData['user'] as Map,
            );

            final dogProfile = DogProfile(
              id: userData['id'].toString(),
              name: userData['dogName'].toString(),
              age: _calculateAge(userData['birthdate']?.toString()),
              description: userData['description']?.toString() ?? '',
              imageUrl: _imageUrlFrom(userData),
            );

            _showMatchDialog(dogProfile, matchId);
          }
        }
      }
    } catch (e) {
      // Silently fail - unseen matches are not critical
      print('Error checking unseen matches: $e');
    }
  }

  Future<void> _markMatchAsSeen(String matchId) async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) return;

      final u = user ?? {};
      final me = ((u['id'] ?? u['_id']) ?? '').toString();
      if (me.isEmpty) return;

      await http.post(
        Uri.parse('$baseUrl/api/matches/$matchId/seen'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'userId': me}),
      );
    } catch (e) {
      print('Error marking match as seen: $e');
    }
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

  int _calculateAge(String? birthdateStr) {
    if (birthdateStr == null || birthdateStr.isEmpty) {
      return 0;
    }

    try {
      final birthdate = DateTime.parse(birthdateStr);
      final now = DateTime.now();
      int age = now.year - birthdate.year;
      if (now.month < birthdate.month ||
          (now.month == birthdate.month && now.day < birthdate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
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
          final birthdateStr = (e['birthdate'] ?? '').toString();
          final age = _calculateAge(birthdateStr);

          return DogProfile(
            id: id,
            name: name,
            age: age > 0 ? age : 3, // fallback to 3 if no birthdate
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
        _showMatchDialog(dog);
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

  void _showMatchDialog(DogProfile dog, [String? matchId]) async {
    // If matchId is provided, mark it as seen when dialog closes
    if (matchId != null) {
      _markMatchAsSeen(matchId);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(creamWhite),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(51),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Match icon with animation
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(persimon).withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Color(persimon),
                    size: 60,
                  ),
                ),
                const SizedBox(height: 24),
                // It's a Match! text
                const Text(
                  "It's a Match!",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(richBlack),
                  ),
                ),
                const SizedBox(height: 12),
                // Matched with name
                Text(
                  "You and ${dog.name} liked each other!",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Color(darkGrey)),
                ),
                const SizedBox(height: 32),
                // Dog image
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(lightGrey),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: dog.imageUrl.isNotEmpty
                        ? Image.network(
                            dog.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.pets,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color(persimon),
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Icon(
                              Icons.pets,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                // Action buttons
                Row(
                  children: [
                    // Send Message button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Navigate to chat - teammate will implement
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.chat_bubble),
                        label: const Text('Send Message'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(persimon),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Keep Swiping button
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(darkGrey),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Keep Swiping',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
