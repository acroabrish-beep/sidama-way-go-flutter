import 'package:flutter/material.dart';

class FoodScreen extends StatelessWidget {
  const FoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food'),
        backgroundColor: const Color(0xFFAD1457),
      ),
      body: const Center(child: Text('Food Screen')),
    );
  }
}
