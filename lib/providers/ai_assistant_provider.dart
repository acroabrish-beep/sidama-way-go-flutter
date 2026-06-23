import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/ai_message.dart';
import '../utils/language_provider.dart';

import '../services/smart_services.dart';

import '../services/firestore_service.dart';
import '../models/city_os_models.dart';

class AiAssistantProvider with ChangeNotifier {
  final FirestoreService _fs = FirestoreService();
  final List<AiMessage> _messages = [];
  bool _isTyping = false;
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _stt = SpeechToText();
  bool _isListening = false;

  List<AiMessage> get messages => _messages;
  bool get isTyping => _isTyping;
  bool get isListening => _isListening;

  AiAssistantProvider() {
    _initTts();
  }

  void _initTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
  }

  Future<void> startListening(AppLanguage lang) async {
    bool available = await _stt.initialize();
    if (available) {
      _isListening = true;
      notifyListeners();
      _stt.listen(
        onResult: (result) {
          if (result.finalResult) {
            sendMessage(result.recognizedWords, lang);
            stopListening();
          }
        },
      );
    }
  }

  void stopListening() {
    _stt.stop();
    _isListening = false;
    notifyListeners();
  }

  void sendMessage(String text, AppLanguage lang) {
    _messages.insert(0, AiMessage(text: text, sender: MessageSender.user, timestamp: DateTime.now()));
    notifyListeners();
    _getAiResponse(text, lang);
  }

  void _getAiResponse(String userText, AppLanguage lang) async {
    _isTyping = true;
    notifyListeners();

    final input = userText.toLowerCase();
    String response = "I'm analyzing city data for you...";

    try {
      if (input.contains('taxi') && input.contains('online')) {
        int count = await _fs.getCollectionCount(CityOSCollection.taxis);
        response = lang == AppLanguage.amharic
          ? "በአሁኑ ሰዓት $count ታክሲዎች በመስመር ላይ ይገኛሉ።"
          : "There are currently $count taxis online in Hawassa.";
      } else if (input.contains('revenue') || input.contains('income')) {
        double rev = await _fs.getTotalRevenue();
        response = lang == AppLanguage.amharic
          ? "የዛሬው ጠቅላላ ገቢ ${rev.toInt()} ብር ነው።"
          : "Today's total revenue across all sectors is ${rev.toInt()} ETB.";
      } else if (input.contains('emergency') || input.contains('active')) {
        int count = await _fs.getCollectionCount(CityOSCollection.emergencyRequests);
        response = lang == AppLanguage.amharic
          ? "በአሁኑ ጊዜ $count ንቁ የአደጋ ጊዜ ጥሪዎች አሉ።"
          : "There are $count active emergency requests currently being handled.";
      } else if (input.contains('hotel')) {
        int count = await _fs.getCollectionCount(CityOSCollection.hotels);
        response = lang == AppLanguage.amharic
          ? "$count ሆቴሎች በስርዓቱ ውስጥ ተመዝግበዋል።"
          : "There are $count hotels registered in the Smart City platform.";
      }
else {
        response = _generateLocalResponse(userText, lang);
      }
    } catch (e) {
      response = "I encountered an error accessing city databases.";
    }

    _messages.insert(0, AiMessage(text: response, sender: MessageSender.ai, timestamp: DateTime.now()));
    _isTyping = false;
    notifyListeners();
    _speak(response, lang);
  }

  String _generateLocalResponse(String input, AppLanguage lang) {
    final lower = input.toLowerCase();

    // Sidamu Afoo
    if (lang == AppLanguage.sidaamuAfoo) {
      if (lower.contains('keere') || lower.contains('hiitto')) {
        return "Keere! Hawassa Smart City kaa'laanchote. Hiitto kaa'lotto?";
      }
      if (lower.contains('taxete')) {
        return "Taxete daafira xa'mi. Hi'nne taxi no?";
      }
      if (lower.contains('waga')) {
        return "Gari waga firestore giddo no.";
      }
      return "Maniite, di-afiommo. Busete doogo, taxete fare, woy income daafira xa'mi.";
    }

    // Amharic
    if (lang == AppLanguage.amharic) {
      if (lower.contains('ሰላም')) return "ሰላም! የሀዋሳ ስማርት ሲቲ ረዳት ነኝ። እንዴት ልረዳዎት እችላለሁ?";
      return "ይቅርታ፣ አልገባኝም። ስለ አውቶቡስ፣ ታክሲ፣ ሆቴሎች ወይም ገቢ መጠየቅ ይችላሉ።";
    }

    // English
    if (lower.contains('hello') || lower.contains('hi')) return "Hello! I am your Hawassa Smart City Assistant. How can I help you today?";
    return "I'm not sure about that. Try asking about 'taxis online', 'today's revenue', or 'active emergencies'.";
  }

  void _speak(String text, AppLanguage lang) async {
    if (lang == AppLanguage.amharic) {
      await _tts.setLanguage("am-ET");
    } else if (lang == AppLanguage.sidaamuAfoo) {
      // Sidaamu Afoo often maps to specialized or generic African/English accents if not native
      await _tts.setLanguage("en-ZA");
    } else {
      await _tts.setLanguage("en-US");
    }
    await _tts.speak(text);
  }
}
