import 'package:flutter/material.dart';
import 'app_strings.dart';

enum AppLanguage { english, amharic, sidaamuAfoo }

class LanguageProvider extends ChangeNotifier {
  String _currentLang = 'en';
  String get currentLang => _currentLang;

  void setLanguage(String lang) {
    _currentLang = lang;
    notifyListeners();
  }

  String t(String key) {
    return AppStrings.strings[_currentLang]?[key] ?? AppStrings.strings['en']![key] ?? key;
  }

  String translate(String key) => t(key);
}
