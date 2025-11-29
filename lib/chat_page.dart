import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const ChatScreen({super.key, required this.userId, required this.userName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final ScrollController _scrollController = ScrollController();

  String get _chatId {
    final a = _currentUserId;
    final b = widget.userId;
    return (a.compareTo(b) <= 0) ? '${a}_$b' : '${b}_$a';
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final chatRef = _firestore.collection('chats').doc(_chatId);
    final messagesRef = chatRef.collection('messages');
    final now = DateTime.now();

    await messagesRef.add({
      'senderId': _currentUserId,
      'text': text,
      'timestamp': now,
    });

    await chatRef.set({
      'lastMessage': text,
      'lastSenderId': _currentUserId,
      'lastTimestamp': now,
      'unreadFor': {widget.userId: true},
    }, SetOptions(merge: true));

    _controller.clear();
    _scrollToBottom();
  }

  Widget _buildMessage(Map<String, dynamic> data) {
    final isMe = data['senderId'] == _currentUserId;
    final text = data['text'] ?? '';
    final ts = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
    final timeString = DateFormat.jm().format(ts);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isMe ? Colors.green : Colors.blueAccent,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(color: isMe ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              timeString,
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markMessagesAsRead() async {
    final chatRef = _firestore.collection('chats').doc(_chatId);
    await chatRef.set({
      'unreadFor': {_currentUserId: false}
    }, SetOptions(merge: true));
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatRef = _firestore.collection('chats').doc(_chatId);
    final messagesRef = chatRef.collection('messages').orderBy('timestamp');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                return ListView.builder(
                  controller: _scrollController,
                  reverse: false,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return _buildMessage(data);
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blueAccent,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
