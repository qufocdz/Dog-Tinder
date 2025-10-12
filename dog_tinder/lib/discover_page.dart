import 'package:flutter/material.dart';
import 'globals.dart';
import 'chat_history_page.dart';
import 'profile_page.dart';

// Simplified dog profile model
class DogProfile {
  final String name;
  final int age;
  final String description;
  final String imageUrl;

  DogProfile({
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
  int currentIndex = 0;

  // Mock dog profiles - to be changed for dogs from API
  final List<DogProfile> dogs = [
    DogProfile(
      name: 'Max',
      age: 5,
      description: 'Friendly dog who loves to play fetch.',
      imageUrl:
          'https://images.unsplash.com/photo-1633722715463-d30f4f325e24?w=800',
    ),
    DogProfile(
      name: 'Bella',
      age: 3,
      description: 'Energetic and playful, loves long walks in the park.',
      imageUrl:
          'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=800',
    ),
    DogProfile(
      name: 'Charlie',
      age: 2,
      description: 'Gentle giant who enjoys cuddles and treats.',
      imageUrl:
          'https://images.unsplash.com/photo-1558788353-f76d92427f16?w=800',
    ),
  ];

  void _handleReject() {
    setState(() {
      if (currentIndex < dogs.length - 1) {
        currentIndex++;
      } else {
        currentIndex++;
      }
    });
  }

  void _handleMatch() {
    setState(() {
      if (currentIndex < dogs.length - 1) {
        currentIndex++;
      } else {
        currentIndex++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(creamWhite),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Messages button
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
                  // Discover title
                  const Text(
                    'Discover',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  // Profile button
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
            // Dog Card
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
            // Action Buttons
            if (currentIndex < dogs.length)
              Padding(
                padding: const EdgeInsets.only(bottom: 32, top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Reject button
                    _buildActionButton(
                      icon: Icons.close,
                      color: const Color(persimon),
                      onPressed: _handleReject,
                    ),
                    const SizedBox(width: 40),
                    // Match button
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
          // Dog Image Card
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
          // Dog Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  dog.name,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // Age
                Text(
                  '${dog.age} years old',
                  style: TextStyle(fontSize: 18, color: const Color(darkGrey)),
                ),
                const SizedBox(height: 12),
                // Description
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
