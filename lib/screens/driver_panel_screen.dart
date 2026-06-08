import 'package:flutter/material.dart';

class DriverPanelScreen extends StatefulWidget {
  const DriverPanelScreen({super.key});

  @override
  State<DriverPanelScreen> createState() => _DriverPanelScreenState();
}

class _DriverPanelScreenState extends State<DriverPanelScreen> {
  bool _isOnline = true;

  final List<Map<String, dynamic>> _requests = [
    {'name': 'Abebe B.', 'pickup': 'Piassa', 'dest': 'Stadium', 'fare': '40 ETB'},
    {'name': 'Mulugeta T.', 'pickup': 'Menahariya', 'dest': 'University', 'fare': '120 ETB'},
    {'name': 'Sara K.', 'pickup': 'Hawassa Lake', 'dest': 'Piazza', 'fare': '80 ETB'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Driver Panel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFE65100),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_isOnline ? 'You are Online' : 'You are Offline',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _isOnline ? Colors.green : Colors.red)),
                    const Text('Available for requests', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                Switch(
                  value: _isOnline,
                  onChanged: (v) => setState(() => _isOnline = v),
                  activeColor: Colors.green,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _statCard('8', 'Trips', Colors.blue),
                const SizedBox(width: 12),
                _statCard('480', 'Earnings', Colors.green),
                const SizedBox(width: 12),
                _statCard('4.8', 'Rating', Colors.orange),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(alignment: Alignment.centerLeft, child: Text('Incoming Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _requests.length,
              itemBuilder: (context, i) {
                final r = _requests[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(child: Icon(Icons.person)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('${r['pickup']} → ${r['dest']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                            Text(r['fare'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(onPressed: () {}, child: const Text('Decline', style: TextStyle(color: Colors.red))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                child: const Text('Accept', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
