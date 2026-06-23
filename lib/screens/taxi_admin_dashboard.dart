import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/firestore_service.dart';

class TaxiAdminDashboard extends StatefulWidget {
  const TaxiAdminDashboard({super.key});

  @override
  State<TaxiAdminDashboard> createState() => _TaxiAdminDashboardState();
}

class _TaxiAdminDashboardState extends State<TaxiAdminDashboard> {
  final FirestoreService _fs = FirestoreService();
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _fs.checkAndSeedTaxi();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Taxi Administration"),
          backgroundColor: const Color(0xFFE65100),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: "Stations"),
              Tab(text: "Drivers"),
              Tab(text: "Vehicles"),
              Tab(text: "Analytics"),
              Tab(text: "AI Assistant"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildStationsTab(),
            _buildDriversTab(),
            _buildVehiclesTab(),
            _buildAnalyticsTab(),
            _buildAIAssistantTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddStationDialog,
          backgroundColor: const Color(0xFFE65100),
          child: const Icon(Icons.add_location_alt),
        ),
      ),
    );
  }

  Widget _buildStationsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _fs.getCollectionStream('taxi_stations'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final d = docs[i].data() as Map<String, dynamic>;
            return ListTile(
              leading: const Icon(Icons.local_taxi, color: Colors.orange),
              title: Text(d['name']),
              subtitle: Text("Active Queues: ${d['activeQueues'] ?? 0}"),
              trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _fs.deleteDocument('taxi_stations', docs[i].id)),
            );
          },
        );
      },
    );
  }

  Widget _buildDriversTab() {
    return const Center(child: Text("Taxi Drivers Management"));
  }

  Widget _buildVehiclesTab() {
    return const Center(child: Text("Taxi Vehicles Registry"));
  }

  Widget _buildAnalyticsTab() {
    return const Center(child: Text("Taxi Demand Analytics"));
  }

  Widget _buildAIAssistantTab() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(24.0),
          child: Icon(Icons.smart_toy, size: 80, color: Colors.orange),
        ),
        const Text("Taxi Service AI", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Insight: Tabor area showing 30% higher demand than available taxis. Recommend moving 5 vehicles from Piazza station to Tabor station."),
            ),
          ),
        ),
        ElevatedButton(onPressed: () => _flutterTts.speak("Tabor area demand is high. Move five taxis from Piazza to Tabor."), child: const Text("Announce to Dispatchers"))
      ],
    );
  }

  void _showAddStationDialog() {
    final nameC = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Taxi Station"),
        content: TextField(controller: nameC, decoration: const InputDecoration(labelText: "Station Name")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: () {
            _fs.addDocument('taxi_stations', {'name': nameC.text, 'activeQueues': 0});
            Navigator.pop(context);
          }, child: const Text("Add")),
        ],
      ),
    );
  }
}
