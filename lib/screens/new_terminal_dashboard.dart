import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../widgets/glass_card.dart';
import 'crud_list_screen.dart';

class NewTerminalDashboard extends StatefulWidget {
  const NewTerminalDashboard({super.key});

  @override
  State<NewTerminalDashboard> createState() => _NewTerminalDashboardState();
}

class _NewTerminalDashboardState extends State<NewTerminalDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String terminalName = 'Hawassa New Terminal';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
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
        title: const Text('Smart Terminal Hub', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.cyanAccent,
          labelColor: Colors.cyanAccent,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Executive'),
            Tab(icon: Icon(Icons.qr_code_scanner), text: 'Tickets'),
            Tab(icon: Icon(Icons.gps_fixed), text: 'Tracking'),
            Tab(icon: Icon(Icons.route), text: 'Routes'),
            Tab(icon: Icon(Icons.people_alt), text: 'Passengers'),
            Tab(icon: Icon(Icons.auto_awesome), text: 'AI Insights'),
            Tab(icon: Icon(Icons.notifications_active), text: 'Alerts'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF001F3F), Color(0xFF0074D9)],
          ),
        ),
        child: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildExecutiveTab(),
              _buildTicketTab(),
              _buildTrackingTab(),
              _buildRouteTab(),
              _buildPassengerTab(),
              _buildAIInsightsTab(),
              _buildNotificationsTab(),
              _buildAnalyticsTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExecutiveTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildQuickStats(),
        const SizedBox(height: 24),
        const Text('System Health', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildHealthIndicators(),
        const SizedBox(height: 24),
        const Text('Live Vehicle Load', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildExecutiveChart(),
      ],
    );
  }

  Widget _buildQuickStats() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _statCard('Live Vehicles', 'vehicles', Icons.bolt, Colors.yellowAccent),
        _statCard('Active Trips', 'schedules', Icons.trending_up, Colors.greenAccent),
        _statCard('Passengers Today', 'bookings', Icons.person_pin, Colors.cyanAccent, valueOverride: '1.2k'),
        _statCard('QR Tickets Issued', 'bookings', Icons.qr_code, Colors.purpleAccent, valueOverride: '432'),
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

  Widget _buildHealthIndicators() {
    return Row(
      children: [
        _healthCard('Server', '99.9%', Colors.green),
        const SizedBox(width: 8),
        _healthCard('GPS Net', 'Active', Colors.green),
        const SizedBox(width: 8),
        _healthCard('Payments', 'Online', Colors.green),
      ],
    );
  }

  Widget _healthCard(String label, String status, Color color) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
            Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildExecutiveChart() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(value: 40, title: 'In Transit', color: Colors.cyanAccent, radius: 50),
            PieChartSectionData(value: 30, title: 'At Dock', color: Colors.greenAccent, radius: 50),
            PieChartSectionData(value: 15, title: 'Service', color: Colors.redAccent, radius: 50),
            PieChartSectionData(value: 15, title: 'Idle', color: Colors.grey, radius: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketTab() {
    return Stack(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('bookings')
              .where('terminal', isEqualTo: terminalName)
              .orderBy('createdAt', descending: true)
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
                      leading: const Icon(Icons.qr_code, color: Colors.cyanAccent),
                      title: Text(data['ticketId'] ?? 'No ID', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text('Passenger: ${data['passengerName']}', style: const TextStyle(color: Colors.white70)),
                      trailing: Icon(Icons.check_circle, color: data['status'] == 'verified' ? Colors.green : Colors.grey),
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
          child: FloatingActionButton.extended(
            backgroundColor: Colors.cyanAccent,
            onPressed: () => _openScanner(context),
            icon: const Icon(Icons.camera_alt, color: Colors.black),
            label: const Text('Validate QR', style: TextStyle(color: Colors.black)),
          ),
        ),
      ],
    );
  }

  void _openScanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Smart QR Validator')),
          body: MobileScanner(
            onDetect: (capture) async {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? code = barcode.rawValue;
                if (code != null) {
                  final query = await FirebaseFirestore.instance
                      .collection('bookings')
                      .where('ticketId', isEqualTo: code)
                      .limit(1)
                      .get();

                  if (query.docs.isNotEmpty) {
                    await query.docs.first.reference.update({'status': 'verified'});
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification Successful!'), backgroundColor: Colors.green));
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid QR!'), backgroundColor: Colors.red));
                    }
                  }
                  break;
                }
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTrackingTab() {
    return const Center(child: Text('Live Fleet Tracking Map Loading...', style: TextStyle(color: Colors.white70)));
  }

  Widget _buildRouteTab() {
    return _buildCRUDView('terminal_routes', 'Smart Routes', ['route', 'origin', 'destination', 'fare', 'optimizationStatus'], Icons.add_location_alt);
  }

  Widget _buildPassengerTab() {
    return _buildCRUDView('passengers', 'Passenger Registry', ['fullName', 'phone', 'loyaltyPoints', 'lastTravelDate'], Icons.person_add);
  }

  Widget _buildAIInsightsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _insightCard('Peak Demand Prediction', 'Expect 20% surge between 4 PM - 6 PM today.', Icons.trending_up, Colors.orange),
        _insightCard('Operational Tip', 'Route 4 shows low efficiency. Consider consolidation.', Icons.lightbulb, Colors.yellow),
        _insightCard('Revenue Forecast', 'Forecasted 150k ETB for this week based on bookings.', Icons.analytics, Colors.green),
      ],
    );
  }

  Widget _insightCard(String title, String desc, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return _buildCRUDView('notifications', 'Terminal Broadcasts', ['title', 'message', 'type', 'timestamp'], Icons.campaign);
  }

  Widget _buildAnalyticsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Daily Revenue (Digital)', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildLineChart(),
      ],
    );
  }

  Widget _buildLineChart() {
    return GlassCard(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [FlSpot(0, 3), FlSpot(1, 4), FlSpot(2, 2), FlSpot(3, 5), FlSpot(4, 3.5), FlSpot(5, 4.5), FlSpot(6, 4)],
              isCurved: true,
              color: Colors.cyanAccent,
              barWidth: 3,
            ),
          ],
        ),
      ),
    );
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
                        icon: const Icon(Icons.edit, color: Colors.cyanAccent),
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
            backgroundColor: Colors.cyanAccent,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CRUDListScreen(collection: collection, title: title, fields: fields, initialData: {'terminal': terminalName}))),
            child: Icon(icon, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
