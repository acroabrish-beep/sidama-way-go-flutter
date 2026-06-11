import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TerminalAdminDashboard extends StatelessWidget {
  final String terminalId;
  const TerminalAdminDashboard({super.key, required this.terminalId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${terminalId == 'old_terminal' ? 'Old' : 'New'} Terminal Admin'),
        backgroundColor: Colors.teal[900],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildActionCard(context, 'Manage Routes', Icons.route, () {}),
          _buildActionCard(context, 'Vehicle Logs', Icons.bus_alert, () {}),
          _buildActionCard(context, 'Passenger Reports', Icons.people, () {}),
          _buildActionCard(context, 'Revenue Analytics', Icons.monetization_on, () {}),
          const SizedBox(height: 32),
          const Text('Live Bookings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('tickets').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LinearProgressIndicator();
              return Column(
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map;
                  return ListTile(
                    title: Text(data['passengerName']),
                    subtitle: Text(data['route']),
                    trailing: Text('${data['seatNumber']}'),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
