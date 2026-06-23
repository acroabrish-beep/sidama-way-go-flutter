import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String _message = '';

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
      setState(() => _message = 'Password reset link sent to your email.');
    } catch (e) {
      setState(() => _message = 'Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_reset, size: 64, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Enter your email to receive a password reset link.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            ),
            if (_message.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(_message, textAlign: TextAlign.center, style: TextStyle(color: _message.contains('Error') ? Colors.red : Colors.green)),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
                child: _isLoading ? const CircularProgressIndicator() : const Text('SEND RESET LINK'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
