import 'package:flutter/material.dart';

enum AppLanguage { english, amharic, sidaamuAfoo }

class LanguageProvider with ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.english;

  AppLanguage get currentLanguage => _currentLanguage;

  void setLanguage(AppLanguage lang) {
    _currentLanguage = lang;
    notifyListeners();
  }

  String translate(String key) {
    return _translations[_currentLanguage]?[key] ?? _translations[AppLanguage.english]?[key] ?? key;
  }

  final Map<AppLanguage, Map<String, String>> _translations = {
    AppLanguage.english: {
      'app_title': 'Sidama Way Go',
      'home': 'Home',
      'transit': 'Transit',
      'explore': 'Explore',
      'ai_chat': 'AI Chat',
      'profile': 'Profile',
      'smart_city_hub': 'Smart City Hub',
      'book_ride': 'Book Ride',
      'public_transit': 'Public Transit',
      'delivery': 'Delivery',
      'eco_shine': 'Eco-Shine',
      'tourism': 'Tourism',
      'healthcare': 'Healthcare',
      'admin_dash': 'Admin Dash',
      'gov_fleet': 'Gov Fleet',
      'ai_assistant': 'AI Assistant',
      'search_dest': 'Search destinations...',
      'eco_status': 'Eco-Shine Station Live',
      'piazza_solar': 'Piazza Station: 85% Solar Power',
      'view_status': 'View Status',
      'hello': 'Hello',
      'welcome_msg': 'Navigating the Heart of the Sidama Region.',
      'navigate': 'Navigate',
      'station_status': 'Station Status: Piazza Hub',
    },
    AppLanguage.amharic: {
      'app_title': 'ሲዳማ ዌይ ጎ',
      'home': 'መነሻ',
      'transit': 'ትራንዚት',
      'explore': 'አስስ',
      'ai_chat': 'AI ውይይት',
      'profile': 'መገለጫ',
      'smart_city_hub': 'ስማርት ሲቲ ማዕከል',
      'book_ride': 'ጉዞ ይዘዙ',
      'public_transit': 'የህዝብ ትራንስፖርት',
      'delivery': 'ማድረሻ',
      'eco_shine': 'ኢኮ-ሻይን',
      'tourism': 'ቱሪዝም',
      'healthcare': 'ጤና ጥበቃ',
      'admin_dash': 'አስተዳዳሪ ዳሽቦርድ',
      'gov_fleet': 'የመንግስት ተሽከርካሪዎች',
      'ai_assistant': 'AI ረዳት',
      'search_dest': 'መድረሻዎችን ይፈልጉ...',
      'eco_status': 'ኢኮ-ሻይን ጣቢያ ቀጥታ ስርጭት',
      'piazza_solar': 'ፒያሳ ጣቢያ: 85% የፀሐይ ኃይል',
      'view_status': 'ሁኔታውን ይመልከቱ',
      'hello': 'ሰላም',
      'welcome_msg': 'የሲዳማ ክልል እምብርት መፈለጊያ።',
      'navigate': 'አቅጣጫ አሳይ',
      'station_status': 'የጣቢያ ሁኔታ: ፒያሳ ማዕከል',
    },
    AppLanguage.sidaamuAfoo: {
      'app_title': 'Sidama Way Go',
      'home': 'Hawaas',
      'transit': 'Transit',
      'explore': 'Ha\'risi',
      'ai_chat': 'AI Chat',
      'profile': 'Profile',
      'smart_city_hub': 'Smart City Hub',
      'book_ride': 'Book Ride',
      'public_transit': 'Public Transit',
      'delivery': 'Delivery',
      'eco_shine': 'Eco-Shine',
      'tourism': 'Tourism',
      'healthcare': 'Healthcare',
      'admin_dash': 'Admin Dash',
      'gov_fleet': 'Gov Fleet',
      'ai_assistant': 'AI Assistant',
      'search_dest': 'Search destinations...',
      'eco_status': 'Eco-Shine Station Live',
      'piazza_solar': 'Piazza Station: 85% Solar Power',
      'view_status': 'View Status',
      'hello': 'Keere',
      'welcome_msg': 'Sidaamu Qoqqowi giddo doogo muli.',
      'navigate': 'Doogo',
      'station_status': 'Station Status: Piazza Hub',
    },
  };
}
