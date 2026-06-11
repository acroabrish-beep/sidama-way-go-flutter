import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  void _showEmergencyDialog(BuildContext context, String type, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm $type Request'),
        content: const Text('Are you sure you want to send an emergency request? help will be dispatched to your location.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendEmergencyRequest(context, type);
            },
            style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
            child: const Text('YES, DISPATCH HELP'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendEmergencyRequest(BuildContext context, String type) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      await FirebaseFirestore.instance.collection('emergency_requests').add({
        'type': type,
        'userId': user?.uid ?? 'anonymous',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
        'location': GeoPoint(position.latitude, position.longitude),
      });

      // Also save to emergency_locations for the map
      await FirebaseFirestore.instance.collection('emergency_locations').doc(user?.uid ?? 'anon_${DateTime.now().millisecondsSinceEpoch}').set({
        'type': 'emergency',
        'subType': type,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'userId': user?.uid ?? 'anonymous',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading

      String contact = '';
      switch (type) {
        case 'Ambulance': contact = '115'; break;
        case 'Police': contact = '011'; break;
        case 'Fire': contact = '939'; break;
        default: contact = 'Emergency Contact';
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Icon(Icons.check_circle, color: Colors.green, size: 64),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Emergency request sent! Help is on the way.', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Text('Emergency Hotline: $contact', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Assistance'),
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text('Tap a button below for immediate assistance', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  _emergencyCard(context, 'Ambulance', Icons.local_hospital, Colors.red),
                  _emergencyCard(context, 'Police', Icons.local_police, Colors.blue),
                  _emergencyCard(context, 'Fire', Icons.local_fire_department, Colors.orange),
                  _emergencyCard(context, 'Road Assist', Icons.car_crash, Colors.yellow[800]!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emergencyCard(BuildContext context, String title, IconData icon, Color color) {
    return Card(
      elevation: 4,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () => _showEmergencyDialog(context, title, color),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 48),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
