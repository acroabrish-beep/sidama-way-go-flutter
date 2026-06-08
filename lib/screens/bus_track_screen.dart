import 'package:flutter/material.dart';

class BusTrackScreen extends StatefulWidget {
  const BusTrackScreen({super.key});
  @override
  State<BusTrackScreen> createState() => _BusTrackScreenState();
}

class _BusTrackScreenState extends State<BusTrackScreen> {
  final List<Map<String, dynamic>> routes = [
    {
      'name': 'Route 1 — Piassa → Stadium',
      'stops': ['Piassa', 'Adebabay', 'Post Office', 'Stadium'],
      'status': 'On Route',
      'eta': '5 min',
      'color': 0xFF2E7D32,
    },
    {
      'name': 'Route 2 — Menahariya → University',
      'stops': ['Menahariya', 'Market', 'Hospital', 'University'],
      'status': 'Arriving',
      'eta': '2 min',
      'color': 0xFF1565C0,
    },
    {
      'name': 'Route 3 — Bus Station → Lake',
      'stops': ['Bus Station', 'Tabor', 'Referral', 'Hawassa Lake'],
      'status': 'Delayed',
      'eta': '15 min',
      'color': 0xFFE65100,
    },
  ];

  int selectedRoute = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: const Text(
          'Bus Tracking',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1565C0),
            child: const Row(
              children: [
                Icon(Icons.location_on, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Hawassa City — Live Bus Tracking',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Active Routes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...routes.asMap().entries.map((entry) {
                  final i = entry.key;
                  final r = entry.value;
                  final isSelected = selectedRoute == i;
                  return GestureDetector(
                    onTap: () => setState(() => selectedRoute = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Color(r['color'] as int).withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Color(r['color'] as int)
                              : Colors.grey.shade200,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  r['name'] as String,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(r['color'] as int),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: r['status'] == 'Arriving'
                                      ? Colors.green
                                      : r['status'] == 'Delayed'
                                      ? Colors.red
                                      : Colors.blue,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  r['status'] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: (r['stops'] as List<String>)
                                .asMap()
                                .entries
                                .map((s) {
                                  final isLast =
                                      s.key == (r['stops'] as List).length - 1;
                                  return Row(
                                    children: [
                                      Column(
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: Color(r['color'] as int),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          Text(
                                            s.value,
                                            style: const TextStyle(
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (!isLast)
                                        Container(
                                          width: 30,
                                          height: 2,
                                          color: Color(
                                            r['color'] as int,
                                          ).withOpacity(0.3),
                                        ),
                                    ],
                                  );
                                })
                                .toList(),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'ETA: ${r['eta']}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
