import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/dashboard_base.dart';
import '../widgets/glass_card.dart';
import 'user_management_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SuperAdminDashboard extends StatelessWidget {
  const SuperAdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardBase(
      title: 'Super Admin Dashboard',
      children: [
        const Text(
          'City Overview',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        _buildStatGrid(),
        const SizedBox(height: 24),
        const Text(
          'Revenue Analytics',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        _buildRevenueChart(),
        const SizedBox(height: 24),
        const Text(
          'Active Emergency Requests',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        _buildEmergencyList(),
      ],
    );
  }

  Widget _buildStatGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _statCardStream('Total Users', 'users', Icons.people, Colors.blue),
        _statCardStream('Taxi Requests', 'taxi_requests', Icons.local_taxi, Colors.orange),
        _statCardStream('Bus Bookings', 'bookings', Icons.directions_bus, Colors.green),
        _statCardStream('Active SOS', 'sos_requests', Icons.emergency, Colors.red),
        _statCardStream('Tourism Sites', 'tourism_sites', Icons.landscape, Colors.teal),
        _revenueCard(),
      ],
    );
  }

  Widget _statCardStream(String label, String collection, IconData icon, Color color) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        String value = snapshot.hasData ? snapshot.data!.docs.length.toString() : '...';
        return _buildStatCard(label, value, icon, color);
      },
    );
  }

  Widget _revenueCard() {
    return FutureBuilder<double>(
      future: _calculateGlobalRevenue(),
      builder: (context, snapshot) {
        double total = snapshot.data ?? 0;
        return _buildStatCard('Total Revenue', '${total.toInt()} ETB', Icons.account_balance_wallet, Colors.greenAccent);
      }
    );
  }

  Future<double> _calculateGlobalRevenue() async {
    double total = 0;

    final b = await FirebaseFirestore.instance.collection('bookings').get();
    for (var d in b.docs) total += (d['fare'] ?? 0).toDouble();

    final t = await FirebaseFirestore.instance.collection('taxi_payments').get();
    for (var d in t.docs) total += (d['amount'] ?? 0).toDouble();

    final h = await FirebaseFirestore.instance.collection('hotel_reservations').get();
    for (var d in h.docs) total += (d['totalPrice'] ?? 0).toDouble();

    final f = await FirebaseFirestore.instance.collection('food_orders').get();
    for (var d in f.docs) total += (d['totalPrice'] ?? 0).toDouble();

    return total;
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    return FutureBuilder<List<FlSpot>>(
      future: _getWeeklyRevenueData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return GlassCard(
          height: 250,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: snapshot.data!,
                  isCurved: true,
                  color: Colors.greenAccent,
                  barWidth: 4,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: true, color: Colors.greenAccent.withOpacity(0.2)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<FlSpot>> _getWeeklyRevenueData() async {
    final List<FlSpot> spots = [];
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));

      double dailyTotal = 0;
      final b = await FirebaseFirestore.instance.collection('bookings')
          .where('createdAt', isGreaterThanOrEqualTo: start)
          .where('createdAt', isLessThan: end).get();
      for (var d in b.docs) dailyTotal += (d['fare'] ?? 0).toDouble();

      spots.add(FlSpot((6 - i).toDouble(), dailyTotal / 1000)); // Normalized for chart
    }
    return spots;
  }

  Widget _buildEmergencyList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('emergency_requests').orderBy('timestamp', descending: true).limit(5).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return GlassCard(
              padding: const EdgeInsets.all(8),
              child: ListTile(
                leading: const Icon(Icons.warning, color: Colors.red),
                title: Text(data['type'] ?? 'Emergency', style: const TextStyle(color: Colors.white)),
                subtitle: Text(data['location_name'] ?? 'Unknown Location', style: const TextStyle(color: Colors.white70)),
                trailing: const Icon(Icons.chevron_right, color: Colors.white),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
