import 'package:flutter/material.dart';
import '../models/ai_message.dart';

class AiAssistantProvider with ChangeNotifier {
  final List<AiMessage> _messages = [];
  bool _isTyping = false;

  List<AiMessage> get messages => _messages;
  bool get isTyping => _isTyping;

  void sendMessage(String text) {
    _messages.insert(0, AiMessage(text: text, sender: MessageSender.user, timestamp: DateTime.now()));
    notifyListeners();
    _getAiResponse(text);
  }

  void _getAiResponse(String userText) async {
    _isTyping = true;
    notifyListeners();

    // Mock NLP Logic
    await Future.delayed(const Duration(seconds: 1));
    String response = "I'm not sure about that, but Hawassa is beautiful today!";

    final lowerText = userText.toLowerCase();
    if (lowerText.contains('hello') || lowerText.contains('hi')) {
      response = "Hello! Welcome to Sidama Way Go. How can I help you navigate Hawassa today?";
    } else if (lowerText.contains('lake')) {
      response = "Hawassa Lake is famous for its fish market and Amora Gedel. Would you like to book a ride there?";
    } else if (lowerText.contains('bus')) {
      response = "Public buses run from Piazza to Industrial Park every 15 minutes. Check the Public Transport section for live ETAs.";
    } else if (lowerText.contains('eco-shine') || lowerText.contains('listro')) {
      response = "Zemenaw Listro stations are solar-powered and eco-friendly. You can book a shine at the Piazza station.";
    }

    _messages.insert(0, AiMessage(text: response, sender: MessageSender.ai, timestamp: DateTime.now()));
    _isTyping = false;
    notifyListeners();
  }
}
