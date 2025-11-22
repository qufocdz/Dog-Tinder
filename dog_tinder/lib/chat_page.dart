import 'dart:async';

import 'package:dog_tinder/globals.dart';
import 'package:flutter/material.dart';

import 'services/chat_service.dart';

class ChatMessageView {
  final String id;
  final String text;
  final bool isMe;
  final DateTime createdAt;

  ChatMessageView({
    required this.id,
    required this.text,
    required this.isMe,
    required this.createdAt,
  });
}

class ChatPage extends StatefulWidget {
  final String matchId;
  final String peerId;
  final String dogName;
  final String? dogImageUrl;

  const ChatPage({
    super.key,
    required this.matchId,
    required this.peerId,
    required this.dogName,
    this.dogImageUrl,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();

  bool _loading = false;
  String? _error;
  List<ChatMessageView> _messages = [];
  String? _myUserId;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _myUserId = user != null ? user!['id']?.toString() : null;
    _loadMessages();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _loadMessages(silent: true);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadMessages({bool silent = false}) async {
    if (_myUserId == null || _myUserId!.isEmpty) {
      setState(() {
        _error =
        'Brak zalogowanego użytkownika (user["id"] == null). Nie wiem, które wiadomości są moje.';
      });
      return;
    }

    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final raw = await ChatService.fetchMessages(widget.matchId);
      final msgs = raw.map((e) {
        final m = e as Map<String, dynamic>;
        final fromId = m['from']?.toString() ?? '';
        final createdAt = DateTime.parse(m['createdAt'] as String);
        return ChatMessageView(
          id: m['_id'] as String,
          text: m['text'] as String? ?? '',
          isMe: fromId == _myUserId,
          createdAt: createdAt,
        );
      }).toList();

      setState(() {
        _messages = msgs;
      });

      _scrollToBottom();
    } catch (e) {
      if (!silent) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted && !silent) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    if (_myUserId == null || _myUserId!.isEmpty) return;

    _messageController.clear();

    final localMsg = ChatMessageView(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      isMe: true,
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages.add(localMsg);
    });
    _scrollToBottom();

    try {
      await ChatService.sendMessage(
        matchId: widget.matchId,
        fromUserId: _myUserId!,
        text: text,
      );
      await _loadMessages(silent: true);
    } catch (e) {
      setState(() {
        _error = 'Nie udało się wysłać wiadomości: $e';
      });
    }
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(creamWhite),
      appBar: AppBar(
        backgroundColor: const Color(creamWhite),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(lightGrey),
              backgroundImage: widget.dogImageUrl != null
                  ? NetworkImage(widget.dogImageUrl!)
                  : null,
              child: widget.dogImageUrl == null
                  ? const Icon(Icons.pets, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              widget.dogName,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_error != null)
            Container(
              width: double.infinity,
              color: Colors.red.withOpacity(0.05),
              padding: const EdgeInsets.all(8),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          Expanded(
            child: _loading && _messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: const Color(ashGrey),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: const Color(darkGrey),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Say hi to ${widget.dogName}!',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(ashGrey),
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final showTime = index == _messages.length - 1 ||
                    _formatTime(_messages[index].createdAt) !=
                        _formatTime(
                            _messages[index + 1].createdAt);

                return Column(
                  crossAxisAlignment: message.isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    _buildMessageBubble(message),
                    if (showTime)
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 4, bottom: 8),
                        child: Text(
                          _formatTime(message.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(darkGrey),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _messageFocusNode.requestFocus();
                    },
                    icon: Icon(
                      Icons.emoji_emotions_outlined,
                      color: const Color(darkGrey),
                      size: 28,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(lightGrey),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        focusNode: _messageFocusNode,
                        decoration: const InputDecoration(
                          hintText: 'Message...',
                          border: InputBorder.none,
                          contentPadding:
                          EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: Icon(Icons.send, color: Color(persimon), size: 28),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageView message) {
    return Align(
      alignment:
      message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isMe ? Color(persimon) : const Color(lightGrey),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: 16,
            color: message.isMe ? Colors.white : Colors.black,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
