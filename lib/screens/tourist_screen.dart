import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'book_ride_screen.dart';

class TouristScreen extends StatelessWidget {
  const TouristScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TOURISM GUIDE')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAITripPlanner(),
            const SizedBox(height: 32),
            const Text('POPULAR ATTRACTIONS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 16),
            _buildAttractionsList(),
            const SizedBox(height: 32),
            const Text('TOURIST SERVICES', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildServiceIcon(Icons.hotel_rounded, 'Hotels'),
                _buildServiceIcon(Icons.restaurant_rounded, 'Food'),
                _buildServiceIcon(Icons.map_rounded, 'Routes'),
                _buildServiceIcon(Icons.support_agent_rounded, 'Support'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttractionsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tourism_sites').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

        final sites = snapshot.data?.docs ?? [];
        if (sites.isEmpty) return const Text('No attractions registered yet.', style: TextStyle(color: Colors.grey));

        return Column(
          children: sites.map((doc) {
            final s = doc.data() as Map<String, dynamic>;
            return _buildSpotCard(context, {
              'name': s['name'] ?? 'Site',
              'image': '📍',
              'desc': s['description'] ?? 'No description.',
              'tag': s['category'] ?? 'General',
              'imageUrl': s['imageUrl'] ?? '',
            });
          }).toList(),
        );
      },
    );
  }

  Widget _buildAITripPlanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(colors: [Color(0xFF2979FF), Color(0xFF00C853)]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.white),
              SizedBox(width: 8),
              Text('AI TRIP PLANNER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Plan your perfect stay in Hawassa using our smart AI agent.', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blue),
            child: const Text('START PLANNING'),
          ),
        ],
      ),
    );
  }

  Widget _buildSpotCard(BuildContext context, Map<String, String> s) {
    final hasImage = s['imageUrl']!.isNotEmpty;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          if (hasImage)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(s['imageUrl']!, height: 150, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(height: 150, color: Colors.grey, child: const Icon(Icons.broken_image))),
            ),
          ListTile(
            leading: hasImage ? null : Text(s['image']!, style: const TextStyle(fontSize: 32)),
            title: Text(s['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(s['desc']!),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(s['tag']!, style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Learn More'))),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookRideScreen())),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C853), foregroundColor: Colors.white),
                    child: const Text('Book Ride'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceIcon(IconData icon, String label) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(backgroundColor: Colors.white.withOpacity(0.05), child: Icon(icon, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}
