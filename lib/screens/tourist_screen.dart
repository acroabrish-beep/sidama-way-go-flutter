import 'package:flutter/material.dart';
import 'book_ride_screen.dart';

class TouristScreen extends StatelessWidget {
  const TouristScreen({super.key});

  final List<Map<String, String>> _spots = const [
    {
      'name': 'Hawassa Lake & Amora Gedel',
      'emoji': '🐦',
      'desc': 'Beautiful birds, monkeys, fresh fish market',
      'info': 'Amora Gedel is a popular lakeside park where you can enjoy the breeze, watch diverse bird species, and see friendly monkeys. It is famous for its fish market.'
    },
    {
      'name': 'Gudumale Cultural Center',
      'emoji': '🎭',
      'desc': 'Fichee-Chambalaala UNESCO heritage site',
      'info': 'Gudumale is the sacred site where the Sidama people celebrate Fichee-Chambalaala, the New Year festival, which is inscribed on the UNESCO list of Intangible Cultural Heritage.'
    },
    {
      'name': 'Tabor Mountain',
      'emoji': '⛰️',
      'desc': 'Scenic hiking trails and city views',
      'info': 'Tabor Mountain offers a panoramic view of Hawassa city and the lake. It is a great spot for hiking, morning exercise, and watching the sunset.'
    },
    {
      'name': 'Millennium Park',
      'emoji': '🌳',
      'desc': 'Beautiful gardens and recreational area',
      'info': 'A relatively new and well-maintained park in the heart of the city, offering lush greenery, flowers, and a peaceful environment for relaxation.'
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
        itemCount: _spots.length,
        itemBuilder: (context, i) {
          final s = _spots[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: Text(s['emoji']!, style: const TextStyle(fontSize: 32)),
                  title: Text(s['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(s['desc']!),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(s['name']!),
                                content: Text(s['info']!),
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
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const BookRideScreen()));
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
                          child: const Text('Book Ride'),
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
