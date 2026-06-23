import 'package:flutter/material.dart';

import '../utils/language_provider.dart';
import 'package:provider/provider.dart';

class PublicTransportScreen extends StatelessWidget {
  const PublicTransportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final routes = [
      {'route': 'Piazza - Industrial Park', 'bus': 'Line 4', 'eta': '4 mins'},
      {'route': 'Alamura - Central Market', 'bus': 'Line 12', 'eta': '12 mins'},
      {'route': 'University - Hawassa Lake', 'bus': 'Line 8', 'eta': 'Arriving Now'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('public_transit')),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: lang.translate('search_dest'),
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: routes.length,
              itemBuilder: (context, index) {
                final r = routes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.directions_bus)),
                    title: Text(r['route']!),
                    subtitle: Text(r['bus']!),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('ETA', style: TextStyle(fontSize: 10)),
                        Text(r['eta']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
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
}
