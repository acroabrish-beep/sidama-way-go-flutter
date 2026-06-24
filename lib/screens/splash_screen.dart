import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'super_admin_dashboard.dart';
import 'old_terminal_dashboard.dart';
import 'new_terminal_dashboard.dart';
import 'taxi_services_dashboard.dart';
import 'tourism_dashboard.dart';
import 'hotel_dashboard.dart';
import 'hospital_dashboard.dart';
import 'pharmacy_dashboard.dart';
import 'emergency_dashboard.dart';
import '../utils/language_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.userModel == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
    } else {
      _navigateToRoleDashboard(authProvider.userModel!);
    }
  }

  void _navigateToRoleDashboard(UserModel user) {
    Widget nextScreen;
    switch (user.role) {
      case UserRole.super_admin:
        nextScreen = const SuperAdminDashboard();
        break;
      case UserRole.old_terminal_admin:
        nextScreen = const OldTerminalDashboard();
        break;
      case UserRole.new_terminal_admin:
        nextScreen = const NewTerminalDashboard();
        break;
      case UserRole.taxi_admin:
        nextScreen = const TaxiServicesDashboard();
        break;
      case UserRole.tourism_admin:
        nextScreen = const TourismDashboard();
        break;
      case UserRole.hotel_admin:
        nextScreen = const HotelDashboard();
        break;
      case UserRole.health_admin:
        nextScreen = const HospitalDashboard();
        break;
      case UserRole.pharmacy_admin:
        nextScreen = const PharmacyDashboard();
        break;
      case UserRole.emergency_admin:
        nextScreen = const EmergencyDashboard();
        break;
      case UserRole.citizen:
      default:
        nextScreen = const HomeScreen();
        break;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => nextScreen),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    )
                  ],
                ),
                child: Image.asset(
                  'assets/images/app_logo.png',
                  height: 140,
                  width: 140,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.location_city, size: 80, color: Color(0xFF2E7D32));
                  },
                ),
              ),
              const SizedBox(height: 40),
              Text(
                lang.t('app_title'),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                lang.t('platform_name'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  lang.t('tagline'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    letterSpacing: 1.2,
                    color: Colors.white70,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              const SizedBox(height: 60),
              const SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  color: Colors.white,
                  backgroundColor: Colors.white24,
                  minHeight: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
