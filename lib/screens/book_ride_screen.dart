import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/smart_services.dart';

enum RideState { idle, searching, driverFound, tracking, completed }

class BookRideScreen extends StatefulWidget {
  final String? preselectedDestination;
  const BookRideScreen({super.key, this.preselectedDestination});

  @override
  State<BookRideScreen> createState() => _BookRideScreenState();
}

class _BookRideScreenState extends State<BookRideScreen> {
  RideState _state = RideState.idle;
  late TextEditingController _destController;
  String? _selectedDest;
  String? _aiRecommendation;

  @override
  void initState() {
    super.initState();
    _selectedDest = widget.preselectedDestination;
    _destController = TextEditingController(text: _selectedDest);
    _loadAIRecommendation();
  }

  @override
  void dispose() {
    _destController.dispose();
    super.dispose();
  }

  void _loadAIRecommendation() async {
    final rec = await SmartAIService.getRouteRecommendation('any');
    setState(() => _aiRecommendation = rec);
  }

  void _startSearch() {
    setState(() => _state = RideState.searching);
    Future.delayed(const Duration(seconds: 3), () {
      setState(() => _state = RideState.driverFound);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SMART RIDE')),
      body: Column(
        children: [
          if (_aiRecommendation != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_aiRecommendation!, style: const TextStyle(fontSize: 12))),
                ],
              ),
            ),
          Expanded(
            child: _state == RideState.idle ? _buildIdle() : _buildActive(),
          ),
        ],
      ),
    );
  }

  Widget _buildIdle() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('WHERE ARE YOU GOING?', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        TextField(
          controller: _destController,
          decoration: InputDecoration(
            hintText: 'Enter destination...',
            prefixIcon: const Icon(Icons.location_on, color: Colors.green),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          onChanged: (v) => setState(() => _selectedDest = v),
        ),
        const SizedBox(height: 32),
        const Text('AVAILABLE TAXI STATIONS', style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 12),
        _buildStationsStream(),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _selectedDest != null ? _startSearch : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('SEARCH FOR DRIVERS', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildStationsStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('stations').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Text('No stations available.');

        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = data['name'] ?? 'Station';
            return ListTile(
              leading: const Icon(Icons.local_taxi, color: Colors.orange),
              title: Text(name),
              subtitle: Text(data['location'] ?? 'Hawassa'),
              onTap: () => setState(() => _selectedDest = name),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildActive() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_state == RideState.searching) ...[
            const CircularProgressIndicator(color: Colors.green),
            const SizedBox(height: 24),
            const Text('AI is scanning for nearest vehicles...'),
          ] else ...[
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 24),
            const Text('Driver Found: Tadesse B.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text('Toyota Corolla • 3 mins away'),
          ],
        ],
      ),
    );
  }

  Widget _suggestItem(String title, String subtitle) {
    return ListTile(
      leading: const Icon(Icons.history_rounded, color: Colors.grey),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () => setState(() => _selectedDest = title),
    );
  }
}
