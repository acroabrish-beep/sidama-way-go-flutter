import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/tracking_provider.dart';
import 'providers/ai_assistant_provider.dart';
import 'screens/splash_screen.dart';

import 'providers/language_provider.dart';

import 'providers/city_platform_provider.dart';

import 'providers/extended_platform_provider.dart';
import 'providers/mobility_provider.dart';
import 'providers/smart_city_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TrackingProvider()),
        ChangeNotifierProvider(create: (_) => AiAssistantProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => MobilityProvider()),
        ChangeNotifierProvider(create: (_) => SmartCityProvider()),
        ChangeNotifierProvider(create: (_) => CityPlatformProvider()),
        ChangeNotifierProvider(create: (_) => ExtendedPlatformProvider()),
      ],
      child: const SmartMobilityApp(),
    ),
  );
}

class SmartMobilityApp extends StatelessWidget {
  const SmartMobilityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart City Mobility Hawassa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        primaryColor: const Color(0xFF2E7D32),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32), brightness: Brightness.dark),
      ),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
