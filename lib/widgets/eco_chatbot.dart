import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EcoChatbot extends StatefulWidget {
  const EcoChatbot({Key? key}) : super(key: key);

  @override
  _EcoChatbotState createState() => _EcoChatbotState();
}

class _EcoChatbotState extends State<EcoChatbot> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'text': text, 'sender': 'user'});
      _isTyping = true;
    });
    _scrollToBottom();

    _textController.clear();

    try {
      final response = await http.post(
        Uri.parse('http://192.168.137.74:8000/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': text}),
      );

      final data = jsonDecode(response.body);
      final reply = data['reply'] ?? 'Sorry, I had trouble answering.';

      setState(() {
        _messages.add({'text': reply, 'sender': 'bot'});
        _isTyping = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add({'text': 'Hello! Buddy', 'sender': 'bot'});
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _buildMessage(Map<String, String> message) {
    final isUser = message['sender'] == 'user';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              backgroundColor: Colors.blue[200],
              child: const Icon(Icons.eco, color: Colors.white),
            ),
          Flexible(
            child: Container(
              margin: EdgeInsets.only(left: isUser ? 0 : 8, right: isUser ? 8 : 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? Colors.green[100] : Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(message['text'] ?? ''),
            ),
          ),
          if (isUser)
            const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.person, color: Colors.white),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (ctx, i) {
              if (_isTyping && i == _messages.length) {
                return _buildTypingIndicator();
              }
              return _buildMessage(_messages[i]);
            },
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration:
                  const InputDecoration.collapsed(hintText: "Type your question..."),
                  onSubmitted: _sendMessage,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _sendMessage(_textController.text),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.eco, color: Colors.white),
        ),
        const SizedBox(width: 8),
        const Text('EcoBot is typing...'),
      ],
    );
  }
}
