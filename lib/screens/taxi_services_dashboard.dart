import 'package:flutter/material.dart';
import '../widgets/dashboard_base.dart';
import '../widgets/glass_card.dart';
import 'crud_list_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaxiServicesDashboard extends StatelessWidget {
  const TaxiServicesDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardBase(
      title: 'Taxi Admin Dashboard',
      children: [
        _buildLiveStatus(),
        const SizedBox(height: 24),
        const Text(
          'Fleet Management',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        _buildFleetStats(),
        const SizedBox(height: 24),
        _buildActionGrid(context),
        const SizedBox(height: 24),
        const Text(
          'Recent Requests',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        _buildRequestList(),
      ],
    );
  }

  Widget _buildLiveStatus() {
    return GlassCard(
      color: Colors.orange,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Live Monitoring', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text('45 Taxis Online', style: TextStyle(color: Colors.white70)),
            ],
          ),
          Icon(Icons.gps_fixed, color: Colors.white, size: 40),
        ],
      ),
    );
  }

  Widget _buildFleetStats() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Total Taxis', '120', Icons.local_taxi, Colors.yellow)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Total Drivers', '145', Icons.person, Colors.cyan)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return GlassCard(
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildActionItem(context, 'Stations', Icons.place, 'stations', ['name', 'location', 'capacity']),
        _buildActionItem(context, 'Drivers', Icons.person, 'drivers', ['name', 'phone', 'license'], initialData: {'type': 'Taxi'}),
        _buildActionItem(context, 'Queue', Icons.list, 'queues', ['taxiId', 'station', 'position']),
        _buildActionItem(context, 'Registration', Icons.app_registration, 'vehicles', ['plateNumber', 'type', 'owner'], initialData: {'category': 'Taxi'}),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, String title, IconData icon, String collection, List<String> fields, {Map<String, dynamic>? initialData}) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CRUDListScreen(collection: collection, title: title, fields: fields, initialData: initialData))),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('taxi_requests')
          .where('status', isNotEqualTo: 'Completed')
          .orderBy('status')
          .orderBy('timestamp', descending: true)
          .limit(10).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text('Error loading requests', style: TextStyle(color: Colors.white)));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return const Center(child: Text('No active requests', style: TextStyle(color: Colors.white70)));

        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] ?? 'Pending';
            return GlassCard(
              padding: const EdgeInsets.all(8),
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.person, color: Colors.white)),
                title: Text(data['userName']?.toString() ?? 'Customer', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text('From: ${data['pickup']}\nTo: ${data['destination']}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (status == 'Pending')
                      ElevatedButton(
                        onPressed: () => _showAssignDriverDialog(context, doc),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 8)),
                        child: const Text('ASSIGN', style: TextStyle(fontSize: 10)),
                      ),
                    if (status == 'Accepted')
                      ElevatedButton(
                        onPressed: () => _completeTrip(context, doc),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 8)),
                        child: const Text('COMPLETE', style: TextStyle(fontSize: 10)),
                      ),
                    const SizedBox(width: 8),
                    Text(status.toUpperCase(), style: const TextStyle(color: Colors.orangeAccent, fontSize: 8, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showAssignDriverDialog(BuildContext context, DocumentSnapshot requestDoc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Driver'),
        content: SizedBox(
          width: double.maxFinite,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('drivers').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final drivers = snapshot.data!.docs;
              if (drivers.isEmpty) return const Text('No drivers available');

              return ListView.builder(
                shrinkWrap: true,
                itemCount: drivers.length,
                itemBuilder: (context, i) {
                  final d = drivers[i].data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(d['name'] ?? 'Driver'),
                    subtitle: Text(d['phone'] ?? ''),
                    onTap: () {
                      requestDoc.reference.update({
                        'status': 'Accepted',
                        'driverId': drivers[i].id,
                        'driverName': d['name'],
                        'driverPhone': d['phone'],
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Driver assigned!')));
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _completeTrip(BuildContext context, DocumentSnapshot requestDoc) async {
    final data = requestDoc.data() as Map<String, dynamic>;
    await requestDoc.reference.update({'status': 'Completed'});
    await FirebaseFirestore.instance.collection('taxi_payments').add({
      'requestId': requestDoc.id,
      'userId': data['userId'],
      'amount': data['fare'],
      'timestamp': FieldValue.serverTimestamp(),
    });
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trip marked as complete!')));
    }
  }
}
