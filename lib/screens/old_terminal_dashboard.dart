import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/glass_card.dart';
import 'crud_list_screen.dart';

class OldTerminalDashboard extends StatefulWidget {
  const OldTerminalDashboard({super.key});

  @override
  State<OldTerminalDashboard> createState() => _OldTerminalDashboardState();
}

class _OldTerminalDashboardState extends State<OldTerminalDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String terminalName = 'Hawassa Old Terminal';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Old Terminal Management', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.orangeAccent,
          labelColor: Colors.orangeAccent,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.departure_board), text: 'Departures'),
            Tab(icon: Icon(Icons.route), text: 'Routes'),
            Tab(icon: Icon(Icons.bus_alert), text: 'Vehicles'),
            Tab(icon: Icon(Icons.person), text: 'Drivers'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.report_problem), text: 'Complaints'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF263238), Color(0xFF455A64)],
          ),
        ),
        child: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildDepartureBoardTab(),
              _buildRouteTab(),
              _buildVehicleTab(),
              _buildDriverTab(),
              _buildAnalyticsTab(),
              _buildComplaintsTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSummaryCards(),
        const SizedBox(height: 24),
        const Text('Today\'s Revenue Trend', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildRevenueChart(),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _statCard('Total Vehicles', 'vehicles', Icons.directions_bus, Colors.blueAccent),
        _statCard('Active Drivers', 'drivers', Icons.person, Colors.greenAccent),
        _statCard('Today\'s Passengers', 'bookings', Icons.people, Colors.orangeAccent, valueOverride: '842'),
        _statCard('Daily Revenue', 'bookings', Icons.account_balance_wallet, Colors.tealAccent, valueOverride: '12,450 ETB'),
      ],
    );
  }

  Widget _statCard(String label, String collection, IconData icon, Color color, {String? valueOverride}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).where('terminal', isEqualTo: terminalName).snapshots(),
      builder: (context, snapshot) {
        String val = valueOverride ?? (snapshot.hasData ? snapshot.data!.docs.length.toString() : '...');
        return GlassCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 4),
              Text(val, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10), textAlign: TextAlign.center),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRevenueChart() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 2), FlSpot(1, 1.5), FlSpot(2, 3), FlSpot(3, 2.5),
                FlSpot(4, 4), FlSpot(5, 3.5), FlSpot(6, 5),
              ],
              isCurved: true,
              color: Colors.orangeAccent,
              barWidth: 4,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: Colors.orangeAccent.withOpacity(0.1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartureBoardTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('schedules')
          .where('terminal', isEqualTo: terminalName)
          .orderBy('departureTime')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                child: ListTile(
                  leading: const Icon(Icons.access_time, color: Colors.orangeAccent),
                  title: Text('${data['destination']} - ${data['departureTime']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('Bus: ${data['busNumber']} | Driver: ${data['driverName']}', style: const TextStyle(color: Colors.white70)),
                  trailing: Chip(
                    label: Text(data['status'] ?? 'Scheduled', style: const TextStyle(fontSize: 10)),
                    backgroundColor: _getStatusColor(data['status']),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'on time': return Colors.green;
      case 'delayed': return Colors.red;
      case 'boarding': return Colors.blue;
      default: return Colors.grey;
    }
  }

  Widget _buildRouteTab() {
    return _buildCRUDView('terminal_routes', 'Routes', ['route', 'origin', 'destination', 'fare'], Icons.add_road);
  }

  Widget _buildVehicleTab() {
    return _buildCRUDView('vehicles', 'Vehicles', ['plateNumber', 'type', 'capacity', 'inspectionStatus'], Icons.directions_bus);
  }

  Widget _buildDriverTab() {
    return _buildCRUDView('drivers', 'Drivers', ['name', 'phone', 'licenseNumber', 'performanceScore'], Icons.person_add);
  }

  Widget _buildCRUDView(String collection, String title, List<String> fields, IconData icon) {
    return Stack(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection(collection).where('terminal', isEqualTo: terminalName).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final docs = snapshot.data!.docs;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, i) {
                final data = docs[i].data() as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    child: ListTile(
                      title: Text(data[fields.first]?.toString() ?? 'Unnamed', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text(data[fields[1]]?.toString() ?? '', style: const TextStyle(color: Colors.white70)),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CRUDListScreen(collection: collection, title: title, fields: fields, initialData: {'terminal': terminalName}))),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: Colors.orangeAccent,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CRUDListScreen(collection: collection, title: title, fields: fields, initialData: {'terminal': terminalName}))),
            child: Icon(icon, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Passenger Trends (Weekly)', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildBarChart(),
        const SizedBox(height: 24),
        _buildAnalyticsRow('Peak Travel Time', '08:00 AM - 10:00 AM'),
        _buildAnalyticsRow('Most Popular Route', 'Hawassa - Addis Ababa'),
        _buildAnalyticsRow('Average Bus Occupancy', '82%'),
      ],
    );
  }

  Widget _buildBarChart() {
    return GlassCard(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(show: false),
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: Colors.blueAccent)]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10, color: Colors.blueAccent)]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 14, color: Colors.blueAccent)]),
            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 15, color: Colors.blueAccent)]),
            BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 13, color: Colors.blueAccent)]),
            BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 10, color: Colors.blueAccent)]),
            BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 8, color: Colors.blueAccent)]),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildComplaintsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('complaints')
          .where('terminal', isEqualTo: terminalName)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                child: ListTile(
                  title: Text(data['subject'] ?? 'No Subject', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(data['description'] ?? '', style: const TextStyle(color: Colors.white70), maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: Icon(Icons.circle, color: data['status'] == 'Resolved' ? Colors.green : Colors.red, size: 12),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
