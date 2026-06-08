import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart City Admin'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Row(
              children: [
                Expanded(child: _StatCard(title: 'Active Vehicles', value: '142', color: Colors.blue)),
                SizedBox(width: 16),
                Expanded(child: _StatCard(title: 'Daily Passengers', value: '3,840', color: Colors.green)),
              ],
            ),
            const SizedBox(height: 16),
            const _HeatmapPlaceholder(),
            const SizedBox(height: 16),
            _ReportList(),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}

class _HeatmapPlaceholder extends StatelessWidget {
  const _HeatmapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(colors: [Colors.orange, Colors.red]),
        ),
        child: const Center(child: Text('Transport Demand Heatmap', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      ),
    );
  }
}

class _ReportList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Citizen Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.warning, color: Colors.orange),
          title: const Text('Pothole at Piazza'),
          subtitle: const Text('Reported 2 hours ago'),
          trailing: const Text('Pending'),
        ),
        ListTile(
          leading: const Icon(Icons.bus_alert, color: Colors.red),
          title: const Text('Bus #21 Breakdown'),
          subtitle: const Text('Reported 5 mins ago'),
          trailing: const Text('Action Taken'),
        ),
      ],
    );
  }
}
