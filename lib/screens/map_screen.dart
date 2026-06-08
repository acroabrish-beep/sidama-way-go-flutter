import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final landmarks = [
      {'name': 'Hawassa Lake', 'dist': '1.2 km'},
      {'name': 'Piazza', 'dist': '0.5 km'},
      {'name': 'Stadium', 'dist': '2.1 km'},
      {'name': 'University', 'dist': '3.5 km'},
      {'name': 'Bus Station', 'dist': '1.8 km'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hawassa Map', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Placeholder Map UI
          Container(
            color: Colors.blue.shade50,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 100, color: Colors.green.withOpacity(0.2)),
                  const Text('Interactive Map Placeholder', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          // Current Location Indicator
          const Center(child: Icon(Icons.location_on, size: 40, color: Colors.blue)),

          // Landmarks List
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 150,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: landmarks.length,
                itemBuilder: (context, i) {
                  final l = landmarks[i];
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 12),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(l['dist']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            const Spacer(),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: EdgeInsets.zero),
                                child: const Text('Navigate', style: TextStyle(color: Colors.white, fontSize: 12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
