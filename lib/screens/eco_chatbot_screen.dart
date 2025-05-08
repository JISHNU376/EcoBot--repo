import 'package:flutter/material.dart';
import '../widgets/eco_chatbot.dart';  // Make sure this widget exists

class EcoChatbotScreen extends StatelessWidget {
  const EcoChatbotScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eco Chatbot'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: EcoChatbot(),  // This should be your chatbot widget
          ),
        ),
      ),
    );
  }
}
