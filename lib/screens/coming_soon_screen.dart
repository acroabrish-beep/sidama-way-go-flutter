import 'package:flutter/material.dart';

class ComingSoonScreen extends StatelessWidget {
  final String title;
  const ComingSoonScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            Text(
              "🚧 $title Dashboard",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "Coming Soon",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                "We are working hard to bring you detailed analytics and management tools for this module.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
              ),
              child: const Text("BACK"),
            ),
          ],
        ),
      ),
    );
  }
}
