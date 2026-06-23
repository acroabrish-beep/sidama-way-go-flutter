import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'super_admin_dashboard.dart';
import 'old_terminal_dashboard.dart';
import 'new_terminal_dashboard.dart';
import 'taxi_services_dashboard.dart';
import 'tourism_dashboard.dart';
import 'hotel_dashboard.dart';
import 'hospital_dashboard.dart';
import 'pharmacy_dashboard.dart';
import 'emergency_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _error = '';

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (authProvider.userModel != null) {
        _navigateToRoleDashboard(authProvider.userModel!);
      } else {
        final currentUid = FirebaseAuth.instance.currentUser?.uid ?? "Unknown";
        setState(() {
          _error = 'User profile not found in Firestore for UID: $currentUid. Please ensure a document exists in the "users" collection with this ID.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Login failed. ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_city,
                size: 80,
                color: Color(0xFF2E7D32),
              ),
              const SizedBox(height: 24),
              const Text(
                'SIDAMA WAY GO',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              const Text(
                'Smart City Digital Platform',
                style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_error.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(_error, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'LOGIN',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                child: const Text('Forgot Password?'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                    child: const Text('Register as Citizen'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
