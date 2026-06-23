import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/language_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.t('settings')),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              langProvider.t('select_language'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          RadioListTile<String>(
            title: const Text('English'),
            value: 'en',
            groupValue: langProvider.currentLang,
            onChanged: (val) {
              if (val != null) langProvider.setLanguage(val);
            },
            secondary: const Icon(Icons.language),
          ),
          RadioListTile<String>(
            title: const Text('አማርኛ (Amharic)'),
            value: 'am',
            groupValue: langProvider.currentLang,
            onChanged: (val) {
              if (val != null) langProvider.setLanguage(val);
            },
            secondary: const Icon(Icons.translate),
          ),
          RadioListTile<String>(
            title: const Text('Sidaamu Afoo'),
            value: 'sid',
            groupValue: langProvider.currentLang,
            onChanged: (val) {
              if (val != null) langProvider.setLanguage(val);
            },
            secondary: const Icon(Icons.history_edu),
          ),
        ],
      ),
    );
  }
}
