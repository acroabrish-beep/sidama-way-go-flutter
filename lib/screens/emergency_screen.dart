import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as custom_auth;

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  String? _activeRequestId;

  void _showEmergencyDialog(BuildContext context, String type, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm $type Request'),
        content: const Text('Are you sure you want to send an emergency request? Help will be dispatched to your location.'),
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
      final user = Provider.of<custom_auth.AuthProvider>(context, listen: false).userModel;
      final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));

      final docRef = await FirebaseFirestore.instance.collection('sos_requests').add({
        'type': type,
        'userId': user?.uid ?? 'anonymous',
        'userName': user?.fullName ?? 'Anonymous',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
        'location': GeoPoint(position.latitude, position.longitude),
        'location_name': 'GPS Captured',
        'description': 'Emergency $type requested via SOS button.',
        'priority': 'critical',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading
      setState(() {
        _activeRequestId = docRef.id;
      });
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_activeRequestId != null) {
      return _ActiveEmergencyScreen(
        requestId: _activeRequestId!,
        onClose: () => setState(() => _activeRequestId = null),
      );
    }
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

class _ActiveEmergencyScreen extends StatelessWidget {
  final String requestId;
  final VoidCallback onClose;
  const _ActiveEmergencyScreen({required this.requestId, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC62828),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('sos_requests').doc(requestId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.white));
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final status = data['status'] ?? 'pending';

          if (status == 'resolved') {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 80),
                  const SizedBox(height: 24),
                  const Text('Resolved!', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Emergency services have confirmed the resolution.', style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: onClose,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red),
                    child: const Text('BACK TO HOME'),
                  )
                ],
              ),
            );
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emergency, color: Colors.white, size: 80),
                  const SizedBox(height: 32),
                  const Text(
                    'HELP IS ON THE WAY',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text('Type: ${data['type']}', style: const TextStyle(color: Colors.white70, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Status: ${status.toUpperCase()}', style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 48),
                  const LinearProgressIndicator(color: Colors.white, backgroundColor: Colors.white24),
                  const SizedBox(height: 48),
                  const Text(
                    'Emergency services have been notified and are responding to your GPS location.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: onClose,
                    child: const Text('MINIMIZE', style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
