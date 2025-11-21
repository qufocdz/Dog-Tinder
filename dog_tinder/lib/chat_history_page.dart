import 'package:flutter/material.dart';
import 'package:dog_tinder/globals.dart';

import 'profile_page.dart';
import 'chat_page.dart';
import 'services/chat_service.dart';

class ChatPreview {
  final String matchId;
  final String peerId;
  final String dogName;
  final String? lastMessage;
  final String? imageUrl;
  final DateTime lastAt;

  ChatPreview({
    required this.matchId,
    required this.peerId,
    required this.dogName,
    required this.lastAt,
    this.lastMessage,
    this.imageUrl,
  });

  factory ChatPreview.fromJson(Map<String, dynamic> json) {
    final peer = (json['peer'] ?? {}) as Map<String, dynamic>;
    final imageUrlDb = peer['imageUrlDb'] as String?;

    String? fullImageUrl;
    if (imageUrlDb != null && imageUrlDb.isNotEmpty) {
      if (imageUrlDb.startsWith('http')) {
        fullImageUrl = imageUrlDb;
      } else {
        fullImageUrl = '$baseUrl$imageUrlDb';
      }
    }

    return ChatPreview(
      matchId: json['matchId'] as String,
      peerId: (peer['id'] ?? '') as String,
      dogName: (peer['dogName'] ?? '') as String,
      lastMessage: json['lastMessage'] as String?,
      lastAt: DateTime.parse(json['lastAt'] as String),
      imageUrl: fullImageUrl,
    );
  }
}

class ChatHistoryPage extends StatefulWidget {
  const ChatHistoryPage({super.key});

  @override
  State<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  bool _loading = false;
  String? _error;
  List<ChatPreview> _chats = [];

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    // jeśli globalny user jest pusty, spróbujmy go wczytać z pamięci
    if (user == null) {
      await TokenManager.loadUser();
    }

    final uid = user != null ? user!['id']?.toString() : null;

    if (uid == null || uid.isEmpty) {
      setState(() {
        _error =
        'Brak zalogowanego użytkownika (user["id"] == null). Upewnij się, że po logowaniu zapisujesz dane usera w globals.dart.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final raw = await ChatService.fetchChats(uid);
      final chats = raw
          .map((e) => ChatPreview.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        _chats = chats;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
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

              // Chat list / loading / error
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadChats,
                  child: _buildBody(),
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

  Widget _buildBody() {
    if (_loading && _chats.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (_chats.isEmpty) {
      return const Center(
        child: Text(
          'Brak rozmów.\nPolub kogoś w Discover, żeby zacząć czat 😊',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _chats.length,
      itemBuilder: (context, index) {
        return _buildChatItem(context, _chats[index]);
      },
    );
  }

  Widget _buildChatItem(BuildContext context, ChatPreview chat) {
    final imageUrl = chat.imageUrl;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              matchId: chat.matchId,
              peerId: chat.peerId,
              dogName: chat.dogName,
              dogImageUrl: imageUrl,
            ),
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
              child: ClipOval(
                child: imageUrl == null
                    ? const Icon(Icons.pets, size: 30, color: Colors.white)
                    : Image.network(
                  imageUrl,
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
                    chat.lastMessage ?? '',
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
