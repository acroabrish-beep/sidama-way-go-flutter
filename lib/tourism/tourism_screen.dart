import 'package:flutter/material.dart';

class TourismScreen extends StatelessWidget {
  const TourismScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final attractions = [
      {
        'name': 'Hawassa Lake',
        'desc': 'Famous for boat rides and stunning sunsets.',
        'image': '🌊',
        'category': 'Lake'
      },
      {
        'name': 'Amora Gedel',
        'desc': 'Nature park with monkeys and fish market.',
        'image': '🐒',
        'category': 'Park'
      },
      {
        'name': 'Tabor Mountain',
        'desc': 'Hiking trails with panoramic city views.',
        'image': '⛰️',
        'category': 'Nature'
      },
      {
        'name': 'Haile Resort',
        'desc': 'Luxury stay and international dining.',
        'image': '🏨',
        'category': 'Hotel'
      },
      {
        'name': 'Gudumale',
        'desc': 'Cultural heritage center of Sidama.',
        'image': '🎭',
        'category': 'Culture'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hawassa Tourism'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: attractions.length,
        itemBuilder: (context, index) {
          final item = attractions[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Text(item['image']!, style: const TextStyle(fontSize: 40)),
              title: Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text(item['desc']!),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(item['category']!, style: TextStyle(color: Colors.green[900], fontSize: 12)),
                  ),
                ],
              ),
              trailing: const Icon(Icons.navigation, color: Colors.blue),
              onTap: () {
                // Navigation logic to the attraction
              },
            ),
          );
        },
      ),
    );
  }
}
