import 'package:flutter/material.dart';
import '../models/ai_message.dart';
import 'language_provider.dart';

class AiAssistantProvider with ChangeNotifier {
  final List<AiMessage> _messages = [];
  bool _isTyping = false;

  List<AiMessage> get messages => _messages;
  bool get isTyping => _isTyping;

  void sendMessage(String text, AppLanguage language) {
    _messages.insert(0, AiMessage(text: text, sender: MessageSender.user, timestamp: DateTime.now()));
    notifyListeners();
    _getAiResponse(text, language);
  }

  void _getAiResponse(String userText, AppLanguage language) async {
    _isTyping = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    String response = "";
    final lowerText = userText.toLowerCase();

    // Multilingual Knowledge Base
    if (language == AppLanguage.amharic) {
      response = "እኔ የእርስዎ ስማርት ሀዋሳ ረዳት ነኝ። በትራንስፖርት፣ በቱሪዝም እና በከተማ አገልግሎቶች ላይ መርዳት እችላለሁ!";
      if (lowerText.contains('ትራንስፖርት') || lowerText.contains('መንገድ') || lowerText.contains('አውቶቡስ')) {
        response = "ሀዋሳ በዘመናዊ የህዝብ ትራንስፖርት እየተገነባች ነው። ዋና መስመሮች: ፒያሳ - ኢንዱስትሪ ፓርክ (መስመር 4) እና አላሙራ - ገበያ (መስመር 12)። በአሁኑ ሰዓት 142 ተሽከርካሪዎች በስራ ላይ ናቸው።";
      } else if (lowerText.contains('ቱሪዝም') || lowerText.contains('ሀይቅ') || lowerText.contains('ቦታ')) {
        response = "መጎብኘት ያለባቸው ቦታዎች:\n1. የሀዋሳ ሀይቅ: ለጀልባ ሽርሽር እና ለዓሳ ገበያ።\n2. አሞራ ገደል: ለዝንጀሮዎች እና ለተፈጥሮ ውበት።\n3. ታቦር ተራራ: የከተማዋን ሙሉ እይታ ለማየት።";
      } else if (lowerText.contains('ኢኮ-ሻይን') || lowerText.contains('ሊስትሮ')) {
        response = "ዘመናዊ የኢኮ-ሻይን ጣቢያዎች በፀሐይ ኃይል የሚሰሩ እና 92% ውሃን መልሰው የሚጠቀሙ ናቸው። በፒያሳ ማዕከል አገልግሎት ማግኘት ይችላሉ።";
      }
    } else if (language == AppLanguage.sidaamuAfoo) {
      response = "Smart Hawaasa Assistant nite. Hiitto muree kaa'lotto?";
      if (lowerText.contains('bus') || lowerText.contains('doogo')) {
        response = "Hawaasa giddo busete doogo Piazza - Industrial Park no. Line 4 nite.";
      } else if (lowerText.contains('baara') || lowerText.contains('tourism')) {
        response = "Hawaasa Baara, Amora Gedel, Tabora moolla visit assa dandiitanno.";
      }
    } else {
      // English Default
      response = "I'm your Smart Hawassa assistant. I can help with transport, tourism, and city services!";
      if (lowerText.contains('transport') || lowerText.contains('bus') || lowerText.contains('route')) {
        response = "Hawassa transit is optimized via AI. Active routes: Piazza to Industrial Park (Line 4), Alamura to Central Market (Line 12). Tracking is live on your Map tab.";
      } else if (lowerText.contains('tourism') || lowerText.contains('lake') || lowerText.contains('spot')) {
        response = "Must-visit in Hawassa:\n- Hawassa Lake: Stunning sunsets & fresh fish.\n- Amora Gedel: Wildlife & lush greenery.\n- Tabor Mountain: Hiking & city panoramic views.";
      } else if (lowerText.contains('eco-shine') || lowerText.contains('listro') || lowerText.contains('zemenaw')) {
        response = "Eco-Shine (Zemenaw Listro) stations feature 100% solar power and advanced water recycling. Visit the Piazza Hub for a smart shine experience.";
      }
    }

    _messages.insert(0, AiMessage(text: response, sender: MessageSender.ai, timestamp: DateTime.now()));
    _isTyping = false;
    notifyListeners();
  }
}
