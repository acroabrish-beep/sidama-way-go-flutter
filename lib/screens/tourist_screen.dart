import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/language_provider.dart';
import 'tourism/tourism_home_screen.dart';

class TouristScreen extends StatelessWidget {
  const TouristScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This is the old screen, redirecting to the new TourismHomeScreen
    return const TourismHomeScreen();
  }
}
