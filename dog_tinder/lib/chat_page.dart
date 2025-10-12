import 'package:dog_tinder/globals.dart';
import 'package:flutter/material.dart';

// Mock message model
class ChatMessage {
  final String text;
  final bool isMe;
  final String time;

  ChatMessage({required this.text, required this.isMe, required this.time});
}

class ChatPage extends StatefulWidget {
  final String dogName;
  final String dogImageUrl;

  const ChatPage({super.key, required this.dogName, required this.dogImageUrl});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();

  late List<ChatMessage> messages;

  @override
  void initState() {
    super.initState();
    // Mock messages - only for Charlie, others will be empty - to be added from API
    if (widget.dogName == 'Charlie') {
      messages = [
        ChatMessage(
          text: 'Hi, great to match with Charlie! He looks so nice 😊',
          isMe: false,
          time: '11:05',
        ),
        ChatMessage(
          text:
              'Hi Lisa. Yes, also glad to match with Maz. he looks the a good boy 😊 What does Charlie not like?',
          isMe: true,
          time: '11:05',
        ),
        ChatMessage(
          text: 'Hmm.. big cats aren\'t his favourite 😅',
          isMe: false,
          time: '11:29',
        ),
        ChatMessage(
          text: 'Ha! Then they both seem to be scared of big cats.',
          isMe: true,
          time: '11:29',
        ),
      ];
    } else {
      messages = [];
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      messages.add(
        ChatMessage(
          text: _messageController.text,
          isMe: true,
          time: _getCurrentTime(),
        ),
      );
      _messageController.clear();
    });

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
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
              backgroundImage: NetworkImage(widget.dogImageUrl),
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
          // Messages list
          Expanded(
            child: messages.isEmpty
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
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final showTime =
                          index == messages.length - 1 ||
                          messages[index].time != messages[index + 1].time;

                      return Column(
                        children: [
                          _buildMessageBubble(message),
                          if (showTime)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, bottom: 8),
                              child: Text(
                                message.time,
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
          // Message input
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
                  // Emoji button
                  IconButton(
                    onPressed: () {
                      _messageFocusNode.requestFocus();
                      // For now idk how to open emojis so it just opens keyboard xD
                    },
                    icon: Icon(
                      Icons.emoji_emotions_outlined,
                      color: const Color(darkGrey),
                      size: 28,
                    ),
                  ),
                  // Text field
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
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  // Send button
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

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
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
