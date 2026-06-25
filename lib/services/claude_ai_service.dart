import 'dart:convert';
import 'package:http/http.dart' as http;

class ClaudeAIService {
  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const String _apiKey = 'YOUR_API_KEY_HERE';

  static const String _systemPrompt = '''
You are the official AI assistant for Sidama Way Go - the Smart Hawassa City Platform.
You know everything about Hawassa city, Ethiopia.

ABOUT HAWASSA:
- Capital of Sidama Region, Ethiopia
- Located on the shore of Lake Hawassa (Rift Valley lake)
- Major attractions: Lake Hawassa, Amora Gedel Park (bird sanctuary & fish market), Tabor Mountain, Gudumale Cultural Center (Fichee-Chambalaala UNESCO heritage), Fish Market, Haile Resort, Millennium Park, Sidama Cultural Village
- Famous for: Tilapia fish, Fichee-Chambalaala New Year festival, Sidama coffee ceremony, beautiful lake views
- Transport: City taxis from Piassa base (routes to Menaharia 8 ETB, Haik Dar 6 ETB, Tabor 7 ETB, Hawella Tula 10 ETB, Addis Ketema 8 ETB, Gudumale 9 ETB, Misrak 7 ETB, Alamura 12 ETB)
- Intercity buses: Old Terminal (Shashamane 80 ETB, Dilla 120 ETB, Arba Minch 200 ETB, Yirgalem 60 ETB), New Terminal (Addis Ababa 280 ETB, Adama 220 ETB, Jimma 300 ETB, Bahir Dar 450 ETB)
- Hotels: Haile Resort (luxury lakeside), Lewi Hotel (city center), Sidama Guest Lodge (budget)
- Restaurants: Haile Resort Restaurant, Lewi Hotel Restaurant, Sidama Cultural Restaurant, Lake View Cafe
- Hospitals: HUCSH (Hawassa University Comprehensive Specialized Hospital), Hawassa Referral Hospital, Adare General Hospital
- Pharmacies: Sidama Pharmacy (Piazza), Hawassa Medical Pharmacy (Menaharia), Lake Side Pharmacy, University Pharmacy
- Eco-Shine stations: Solar-powered shoe shine + USB charging at Piazza, Hawassa University, Haile Resort, Bus Station
- Emergency: Ambulance 115, Police 011, Fire 939
- Best time to visit: October-January (dry season), June-September (green but rainy)
- Language: Sidaamu Afoo (local), Amharic (national), English

APP SERVICES (Sidama Way Go):
- Book intercity bus tickets with QR codes
- City taxi booking from Piassa
- Hotel and guest house reservations
- Food delivery from local restaurants
- Emergency SOS with GPS
- Tourist guide with AI voice narration
- Eco-Shine station booking
- Pharmacy medicine search

LANGUAGE RULES:
- If user writes in Amharic (አማርኛ), respond ONLY in Amharic
- If user writes in Sidaamu Afoo or says "Sidaamu", respond in simple Sidaamu Afoo with English translation in brackets
- Default: respond in English
- Always be helpful, friendly, and knowledgeable about Hawassa

Keep responses concise (under 150 words) and practical.
''';

  static Future<String> chat(String userMessage, String language) async {
    try {
      String systemWithLang = _systemPrompt;
      if (language == 'am') {
        systemWithLang += '\nIMPORTANT: The user has selected Amharic. Always respond in Amharic only.';
      } else if (language == 'sid') {
        systemWithLang += '\nIMPORTANT: The user has selected Sidaamu Afoo. Respond in Sidaamu Afoo with English translation.';
      }

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-3-5-sonnet-20240620',
          'max_tokens': 500,
          'system': systemWithLang,
          'messages': [
            {'role': 'user', 'content': userMessage}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['content'][0]['text'] as String;
      } else {
        return _getFallbackResponse(userMessage, language);
      }
    } catch (e) {
      return _getFallbackResponse(userMessage, language);
    }
  }

  static String _getFallbackResponse(String query, String lang) {
    final q = query.toLowerCase();
    if (lang == 'am') {
      if (q.contains('ሆቴል') || q.contains('hotel')) return 'ሃዋሳ ውስጥ ጥሩ ሆቴሎች አሉ። ሃይሌ ሪዞርት (ሃይቅ ዳር - ውብ እይታ), ሌዊ ሆቴል (ከተማ ማዕከል), ሲዳማ ጌስት ሎጅ (ዝቅተኛ ዋጋ)።';
      if (q.contains('ታክሲ') || q.contains('taxi')) return 'ከፒያሳ ወደ ሁሉም አቅጣጫዎች ታክሲ አለ። ወደ መናሃርያ 8 ብር, ሃይቅ ዳር 6 ብር, ጣቦር 7 ብር, ጉዱማሌ 9 ብር።';
      if (q.contains('ሃይቅ') || q.contains('ሐይቅ')) return 'ሃዋሳ ሃይቅ በጣም ውብ ነው! የወፍ እይታ, የጀልባ ጉዞ, ትኩስ ዓሣ ይገኛል። ጠዋት 6 ሰዓት ለጥሩ ልምድ ይሂዱ።';
      return 'ሰላም! የሃዋሳ ስማርት ሲቲ AI ረዳት ነኝ። ስለ ትራንስፖርት, ሆቴሎች, ምግብ, ጤና አገልግሎቶች ወይም የሃዋሳ መስህቦች ልጠይቁ!';
    }
    if (q.contains('lake') || q.contains('hawassa lake')) return 'Lake Hawassa is a beautiful Rift Valley lake! Activities: boat rides, bird watching (pelicans, cormorants), fresh Tilapia fish. Visit Amora Gedel fish market for the best local experience. Best time: 6-9 AM.';
    if (q.contains('taxi')) return 'City taxis operate from Piassa base. Destinations: Menaharia 8 ETB (10 min), Haik Dar 6 ETB, Tabor 7 ETB, Gudumale 9 ETB, Misrak 7 ETB, Alamura 12 ETB. Use our app to book your ride!';
    if (q.contains('bus') || q.contains('terminal')) return 'Old Terminal: Shashamane 80 ETB, Dilla 120 ETB, Arba Minch 200 ETB, Yirgalem 60 ETB. New Terminal: Addis Ababa 280 ETB, Adama 220 ETB, Jimma 300 ETB, Bahir Dar 450 ETB. Book tickets with QR codes in our app!';
    if (q.contains('hotel')) return 'Top hotels in Hawassa: 1) Haile Resort - luxury lakeside (2500 ETB/night), 2) Lewi Hotel - city center (1800 ETB/night), 3) Sidama Guest Lodge - budget (800 ETB/night). Book through our app!';
    if (q.contains('food') || q.contains('restaurant')) return 'Best food in Hawassa: Fresh Tilapia fish from Amora Gedel, Bulla and Chukamo (traditional Sidama), Injera with Tibs. Top restaurants: Haile Resort Restaurant, Sidama Cultural Restaurant, Lake View Cafe.';
    if (q.contains('emergency') || q.contains('help')) return 'Emergency contacts: Ambulance 115, Police 011, Fire Brigade 939. Use the SOS button in our app for instant GPS-linked emergency request!';
    if (q.contains('eco') || q.contains('shine')) return 'Eco-Shine solar stations: Piazza, Hawassa University, Haile Resort, Bus Station. Services: Professional shoe shine (30-80 ETB) + Free USB device charging. Book a slot in our app!';
    return 'Hello! I\'m your Hawassa City AI assistant. I can help with: 🚌 Bus tickets, 🚕 Taxi booking, 🏨 Hotels, 🍽️ Food, 🚨 Emergency, 🗺️ Tourism, ☀️ Eco-Shine, 💊 Pharmacy. What do you need?';
  }
}
