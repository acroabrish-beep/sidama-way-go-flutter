import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navToHome();
  }

  void _navToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E0A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, size: 80, color: Color(0xFF4CAF50)),
            const SizedBox(height: 24),
            const Text(
              'SMART MOBILITY',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                color: Colors.white,
              ),
            ),
            const Text(
              'ETHIOPIA AI',
              style: TextStyle(
                fontSize: 14,
                letterSpacing: 2,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 150,
              child: LinearProgressIndicator(
                color: Color(0xFF4CAF50),
                backgroundColor: Colors.white12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
