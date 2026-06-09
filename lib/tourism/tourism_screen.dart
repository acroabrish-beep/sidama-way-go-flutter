import 'package:flutter/material.dart';
import '../maps/realtime_map_screen.dart';

class TourismScreen extends StatelessWidget {
  const TourismScreen({super.key});

  final List<Map<String, dynamic>> attractions = const [
    {
      'name': 'Hawassa Lake',
      'desc': 'Famous for beautiful boat rides, stunning sunsets, and lakeside fish markets.',
      'image': '🌊',
      'category': 'Nature',
      'hours': 'Open 24/7',
      'culture': 'A central hub for local relaxation and the primary source of fresh tilapia.',
      'contact': '+251 46 220 XXXX',
      'lat': 7.060,
      'lng': 38.470,
    },
    {
      'name': 'Amora Gedel',
      'desc': 'A lush natural park filled with friendly monkeys, diverse bird species, and local fresh fish culture.',
      'image': '🐒',
      'category': 'Park',
      'hours': '6:00 AM - 6:00 PM',
      'culture': 'Known as the "Lover\'s Cave", it is a sacred community space with deep history.',
      'contact': 'Local Park Authority',
      'lat': 7.065,
      'lng': 38.475,
    },
    {
      'name': 'Tabor Mountain',
      'desc': 'The best panoramic viewpoint in the city. Ideal for morning hiking trails and scenic city photography.',
      'image': '⛰️',
      'category': 'Adventure',
      'hours': 'Sunrise - Sunset',
      'culture': 'A popular spot for traditional celebrations and city-wide views.',
      'contact': 'Tourism Office',
      'lat': 7.040,
      'lng': 38.510,
    },
    {
      'name': 'Haile Resort',
      'desc': 'Luxury lakeside resort offering international dining, swimming, and high-end accommodation.',
      'image': '🏨',
      'category': 'Hotel',
      'hours': 'Open 24/7',
      'culture': 'Owned by Olympic legend Haile Gebrselassie, representing modern Ethiopian hospitality.',
      'contact': '+251 46 220 5000',
      'lat': 7.055,
      'lng': 38.465,
    },
    {
      'name': 'Gudumale',
      'desc': 'The traditional cultural center of Sidama, where heritage and community meet.',
      'image': '🎭',
      'category': 'Culture',
      'hours': '8:00 AM - 5:00 PM',
      'culture': 'Host to the Fichee-Chambalaala New Year celebration, a UNESCO heritage site.',
      'contact': 'Sidama Cultural Bureau',
      'lat': 7.050,
      'lng': 38.480,
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                  Text(item['desc']!, maxLines: 2, overflow: TextOverflow.ellipsis),
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
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showDetail(context, item),
            ),
          );
        },
      ),
    );
  }

  void _showDetail(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(item['image'], style: const TextStyle(fontSize: 60)),
                  ),
                  const SizedBox(height: 16),
                  Text(item['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(item['category'], style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.w600)),
                  const Divider(height: 32),
                  const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(item['desc']),
                  const SizedBox(height: 16),
                  const Text('Cultural Significance', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(item['culture']),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(item['hours'], style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(item['contact'], style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Future: In a real app, use a proper router or global key to switch tabs.
                        // For now, we push the screen or show snackbar.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Routing to Map...')),
                        );
                      },
                      icon: const Icon(Icons.map),
                      label: const Text('View on Map'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[800],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
