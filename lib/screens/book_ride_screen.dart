import 'package:flutter/material.dart';

class BookRideScreen extends StatelessWidget {
  const BookRideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a Ride'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: const Center(child: Text('Ride Booking Screen')),
    );
  }
}
