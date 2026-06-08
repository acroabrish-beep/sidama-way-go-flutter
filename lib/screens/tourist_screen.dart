import 'package:flutter/material.dart';
import 'book_ride_screen.dart';

class TouristScreen extends StatelessWidget {
  const TouristScreen({super.key});

  final List<Map<String, String>> spots = const [
    {
      'name': 'Hawassa Lake & Amora Gedel',
      'icon': '🐦',
      'desc': 'Beautiful birds, monkeys, fresh fish market',
      'full': 'A stunning lakeside area perfect for bird watching and enjoying fresh tilapia directly from the lake. You can also spot monkeys in the nearby trees.'
    },
    {
      'name': 'Gudumale Cultural Center',
      'icon': '🎭',
      'desc': 'Fichee-Chambalaala UNESCO heritage site',
      'full': 'The sacred ground for the Sidama New Year celebration. It represents the deep cultural heritage of the Sidama people.'
    },
    {
      'name': 'Tabor Mountain',
      'icon': '⛰️',
      'desc': 'Scenic hiking trails and city views',
      'full': 'Hike to the top for a breathtaking panoramic view of Hawassa city and the lake. Popular for both morning exercise and sunset viewing.'
    },
    {
      'name': 'Millennium Park',
      'icon': '🌳',
      'desc': 'Beautiful gardens and recreational area',
      'full': 'A peaceful green space in the city center, ideal for picnics, walks, and relaxing amidst diverse plant species.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hawassa Tourist Guide', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2E7D32),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: spots.length,
        itemBuilder: (context, i) {
          final s = spots[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: Text(s['icon']!, style: const TextStyle(fontSize: 32)),
                  title: Text(s['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text(s['desc']!),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(s['name']!),
                                content: Text(s['full']!),
                                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                              ),
                            );
                          },
                          child: const Text('Learn More'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => BookRideScreen(initialDestination: s['name'])),
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
                          child: const Text('Book Ride Here'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
