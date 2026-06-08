import 'package:flutter/material.dart';

class SmartHawassaTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00C853), // Hawassa Green
        brightness: Brightness.dark,
        primary: const Color(0xFF00C853),
        secondary: const Color(0xFF2979FF),
        tertiary: const Color(0xFFFFAB00),
      ),
      scaffoldBackgroundColor: const Color(0xFF0C0F0C),
      cardTheme: CardThemeData(
        color: const Color(0xFF161B16),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
