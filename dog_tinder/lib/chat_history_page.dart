import 'package:dog_tinder/globals.dart';
import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'chat_page.dart';

// Mock chat model
class ChatPreview {
  final String dogName;
  final String lastMessage;
  final String imageUrl;

  ChatPreview({
    required this.dogName,
    required this.lastMessage,
    required this.imageUrl,
  });
}

class ChatHistoryPage extends StatelessWidget {
  const ChatHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock chat data
    final List<ChatPreview> chats = [
      ChatPreview(
        dogName: 'Buddy',
        lastMessage: 'Hi',
        imageUrl:
            'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=800',
      ),
      ChatPreview(
        dogName: 'Max',
        lastMessage: 'Great to match you too.',
        imageUrl:
            'https://images.unsplash.com/photo-1633722715463-d30f4f325e24?w=800',
      ),
      ChatPreview(
        dogName: 'Luna',
        lastMessage: 'See you 7 PM! :-)',
        imageUrl:
            'https://images.unsplash.com/photo-1568572933382-74d440642117?w=800',
      ),
      ChatPreview(
        dogName: 'Charlie',
        lastMessage: 'He plays with a ball.',
        imageUrl:
            'https://images.unsplash.com/photo-1558788353-f76d92427f16?w=800',
      ),
    ];

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
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Chats',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Profile button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfilePage(),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(ashGrey),
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              // Chat list
              Expanded(
                child: ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    return _buildChatItem(context, chats[index]);
                  },
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

  Widget _buildChatItem(BuildContext context, ChatPreview chat) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ChatPage(dogName: chat.dogName, dogImageUrl: chat.imageUrl),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: const Color(lightGrey), width: 1),
          ),
        ),
        child: Row(
          children: [
            // Dog profile picture
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(ashGrey),
              backgroundImage: NetworkImage(chat.imageUrl),
              child: ClipOval(
                child: Image.network(
                  chat.imageUrl,
                  fit: BoxFit.cover,
                  width: 60,
                  height: 60,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.pets,
                      size: 30,
                      color: Colors.white,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Dog name and last message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.dogName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat.lastMessage,
                    style: TextStyle(
                      fontSize: 15,
                      color: const Color(darkGrey),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
