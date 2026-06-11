import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('City Admin Dashboard'),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatOverview(),
            const SizedBox(height: 24),
            _buildRevenueChart(),
            const SizedBox(height: 24),
            _buildSectionTitle('Active Emergency Requests'),
            _buildEmergencyList(),
            const SizedBox(height: 24),
            _buildSectionTitle('Recent Ticket Sales'),
            _buildTicketList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatOverview() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        final userCount = snapshot.data?.docs.length ?? 0;
        return Row(
          children: [
            _statCard('Total Users', '$userCount', Colors.blue),
            const SizedBox(width: 12),
            _statCard('Active Taxis', '142', Colors.orange),
            const SizedBox(width: 12),
            _statCard('Revenue', '45.2k', Colors.green),
          ],
        );
      },
    );
  }

  Widget _statCard(String title, String val, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Daily Ticket Revenue', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: Colors.blue)]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 12, color: Colors.blue)]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 15, color: Colors.blue)]),
                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 10, color: Colors.blue)]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmergencyList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('emergency_requests').orderBy('timestamp', descending: true).limit(5).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();
        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map;
            return ListTile(
              leading: const Icon(Icons.warning, color: Colors.red),
              title: Text(data['type']),
              subtitle: Text(data['status']),
              trailing: TextButton(onPressed: () {}, child: const Text('RESPOND')),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildTicketList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tickets').orderBy('createdAt', descending: true).limit(5).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();
        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map;
            return ListTile(
              title: Text(data['passengerName']),
              subtitle: Text(data['route']),
              trailing: Text('${data['fare']} ETB'),
            );
          }).toList(),
        );
      },
    );
  }
}
