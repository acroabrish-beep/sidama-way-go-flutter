import 'package:flutter/material.dart';

class EcoShineScreen extends StatelessWidget {
  const EcoShineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stations = [
      {'name': 'Piazza Station', 'queue': 2},
      {'name': 'University Hub', 'queue': 5},
      {'name': 'Haile Resort Point', 'queue': 0},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eco-Shine Solar Wash'),
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Map Placeholder with Station Markers
          Container(
            height: 250,
            width: double.infinity,
            color: Colors.teal.shade50,
            child: Stack(
              children: [
                const Center(child: Icon(Icons.map, size: 100, color: Colors.teal)),
                _marker(50, 100, 'Station A'),
                _marker(150, 200, 'Station B'),
                _marker(200, 50, 'Station C'),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _FeatureIcon(Icons.wb_sunny, 'Solar Powered'),
                    _FeatureIcon(Icons.recycling, 'Water Recycling'),
                    _FeatureIcon(Icons.usb, 'Free USB'),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Nearby Stations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...stations.map((s) => Card(
                  child: ListTile(
                    title: Text(s['name'] as String),
                    subtitle: Text('Current Queue: ${s['queue']} people'),
                    trailing: ElevatedButton(
                      onPressed: () => _showBookingDialog(context, s['name'] as String),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00695C), foregroundColor: Colors.white),
                      child: const Text('Book Slot'),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _marker(double top, double left, String label) {
    return Positioned(
      top: top, left: left,
      child: const Column(
        children: [
          Icon(Icons.location_on, color: Color(0xFF00695C), size: 30),
        ],
      ),
    );
  }

  void _showBookingDialog(BuildContext context, String station) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Book at $station'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Time Slot'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: ['09:00', '10:30', '14:00', '16:30'].map((t) => ActionChip(label: Text(t), onPressed: () {})).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking Confirmed!'), backgroundColor: Colors.green));
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _FeatureIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureIcon(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.teal.shade100, shape: BoxShape.circle),
          child: Icon(icon, color: const Color(0xFF00695C)),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
