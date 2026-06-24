import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/glass_card.dart';
import 'crud_list_screen.dart';

class TaxiAdminDashboard extends StatefulWidget {
  const TaxiAdminDashboard({super.key});

  @override
  State<TaxiAdminDashboard> createState() => _TaxiAdminDashboardState();
}

class _TaxiAdminDashboardState extends State<TaxiAdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 10, vsync: this);
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
        title: const Text('Smart Taxi Control Center', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.yellowAccent,
          labelColor: Colors.yellowAccent,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Executive'),
            Tab(icon: Icon(Icons.map), text: 'Live Tracking'),
            Tab(icon: Icon(Icons.hail), text: 'Requests'),
            Tab(icon: Icon(Icons.local_taxi), text: 'Fleet'),
            Tab(icon: Icon(Icons.person), text: 'Drivers'),
            Tab(icon: Icon(Icons.place), text: 'Stations'),
            Tab(icon: Icon(Icons.payments), text: 'Fare Rules'),
            Tab(icon: Icon(Icons.reviews), text: 'Feedback'),
            Tab(icon: Icon(Icons.auto_awesome), text: 'AI Hub'),
            Tab(icon: Icon(Icons.campaign), text: 'Broadcast'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF212121), Color(0xFF424242)],
          ),
        ),
        child: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: [
              const _ExecutiveOverview(),
              const _LiveTrackingTab(),
              const _RequestsManagementTab(),
              const _FleetManagementTab(),
              const _DriverManagementTab(),
              const _StationManagementTab(),
              const _FareManagementTab(),
              const _CustomerFeedbackTab(),
              const _AITaxiAssistantTab(),
              const _BroadcastManagementTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExecutiveOverview extends StatelessWidget {
  const _ExecutiveOverview();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildKPIBoard(),
        const SizedBox(height: 24),
        const Text('Operational Efficiency', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildActivityChart(),
        const SizedBox(height: 24),
        const Text('Trip Distribution (By Station)', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildStationShareChart(),
      ],
    );
  }

  Widget _buildKPIBoard() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.4,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _kpiCard('Active Taxis', 'taxi_vehicles', Icons.local_taxi, Colors.yellowAccent, whereField: 'status', whereValue: 'Active'),
        _kpiCard('Ongoing Trips', 'taxi_requests', Icons.trending_up, Colors.greenAccent, whereField: 'status', whereValue: 'Trip Started'),
        _kpiCard('Requests Today', 'taxi_requests', Icons.hail, Colors.orangeAccent, valueOverride: '124'),
        _kpiCard('Daily Revenue', 'taxi_trips', Icons.account_balance_wallet, Colors.tealAccent, valueOverride: '4,280 ETB'),
      ],
    );
  }

  Widget _kpiCard(String label, String collection, IconData icon, Color color, {String? whereField, String? whereValue, String? valueOverride}) {
    Query query = FirebaseFirestore.instance.collection(collection);
    if (whereField != null) query = query.where(whereField, isEqualTo: whereValue);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        String val = valueOverride ?? (snapshot.hasData ? snapshot.data!.docs.length.toString() : '...');
        return GlassCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 4),
              Text(val, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10), textAlign: TextAlign.center),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityChart() {
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
              spots: const [FlSpot(0, 3), FlSpot(1, 1), FlSpot(2, 4), FlSpot(3, 2), FlSpot(4, 5), FlSpot(5, 3), FlSpot(6, 4)],
              isCurved: true,
              color: Colors.yellowAccent,
              barWidth: 4,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: Colors.yellowAccent.withOpacity(0.1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationShareChart() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(value: 40, title: 'Piassa', color: Colors.yellowAccent, radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            PieChartSectionData(value: 25, title: 'Menaharia', color: Colors.orangeAccent, radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            PieChartSectionData(value: 20, title: 'University', color: Colors.greenAccent, radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            PieChartSectionData(value: 15, title: 'Others', color: Colors.grey, radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _LiveTrackingTab extends StatelessWidget {
  const _LiveTrackingTab();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(7.0504, 38.4955), // Hawassa
            initialZoom: 13.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.sidamawaygo.app',
            ),
            const MarkerLayer(
              markers: [
                Marker(point: LatLng(7.0504, 38.4955), child: Icon(Icons.location_on, color: Colors.red, size: 40)),
                Marker(point: LatLng(7.0600, 38.4800), child: Icon(Icons.local_taxi, color: Colors.orange, size: 30)),
                Marker(point: LatLng(7.0400, 38.5000), child: Icon(Icons.local_taxi, color: Colors.orange, size: 30)),
                Marker(point: LatLng(7.0450, 38.4900), child: Icon(Icons.place, color: Colors.blue, size: 30)),
              ],
            ),
          ],
        ),
        Positioned(
          top: 16,
          right: 16,
          child: GlassCard(
            padding: const EdgeInsets.all(8),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LegendItem(color: Colors.orange, label: 'Active Taxi'),
                _LegendItem(color: Colors.blue, label: 'Station'),
                _LegendItem(color: Colors.red, label: 'Pickup'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 12),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
      ],
    );
  }
}

class _RequestsManagementTab extends StatelessWidget {
  const _RequestsManagementTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('taxi_requests').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final status = data['status'] ?? 'Pending';
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                child: ListTile(
                  title: Text('${data['pickup']} → ${data['destination']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('User: ${data['userName']} | Status: $status', style: const TextStyle(color: Colors.white70)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (status == 'Pending')
                        _actionBtn(context, 'ASSIGN', Colors.green, () => _showAssignDialog(context, docs[i])),
                      if (status == 'Driver Assigned')
                        _actionBtn(context, 'ARRIVED', Colors.blue, () => docs[i].reference.update({'status': 'Driver Arrived'})),
                      if (status == 'Driver Arrived')
                        _actionBtn(context, 'START', Colors.orange, () => docs[i].reference.update({'status': 'Trip Started'})),
                      if (status == 'Trip Started')
                        _actionBtn(context, 'FINISH', Colors.purple, () => _completeTrip(context, docs[i])),
                      const SizedBox(width: 8),
                      IconButton(icon: const Icon(Icons.cancel, color: Colors.redAccent, size: 20), onPressed: () => docs[i].reference.update({'status': 'Cancelled'})),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _actionBtn(BuildContext context, String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: const Size(60, 28)),
      child: Text(label, style: const TextStyle(fontSize: 8, color: Colors.white)),
    );
  }

  void _showAssignDialog(BuildContext context, DocumentSnapshot requestDoc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dispatch Taxi'),
        content: SizedBox(
          width: double.maxFinite,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('taxi_drivers').where('isActive', isEqualTo: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, i) {
                  final d = snapshot.data!.docs[i].data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(d['fullName'] ?? 'Unknown Driver'),
                    subtitle: Text('Taxi: ${d['assignedTaxi'] ?? 'None'}'),
                    onTap: () {
                      requestDoc.reference.update({
                        'status': 'Driver Assigned',
                        'driverId': snapshot.data!.docs[i].id,
                        'driverName': d['fullName'],
                      });
                      Navigator.pop(ctx);
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
    await requestDoc.reference.update({'status': 'Trip Completed'});
    // Archive to trips
    await FirebaseFirestore.instance.collection('taxi_trips').add({
      ...data,
      'status': 'Completed',
      'completedAt': FieldValue.serverTimestamp(),
    });
    // Record payment if needed
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trip marked as completed and archived.')));
  }
}

class _FleetManagementTab extends StatelessWidget {
  const _FleetManagementTab();
  @override
  Widget build(BuildContext context) {
    return _buildCRUD(context, 'taxi_vehicles', 'Taxis', ['plateNumber', 'taxiType', 'driverName', 'status', 'capacity']);
  }
}

class _DriverManagementTab extends StatelessWidget {
  const _DriverManagementTab();
  @override
  Widget build(BuildContext context) {
    return _buildCRUD(context, 'taxi_drivers', 'Drivers', ['fullName', 'phone', 'licenseNumber', 'rating', 'isActive']);
  }
}

class _StationManagementTab extends StatelessWidget {
  const _StationManagementTab();
  @override
  Widget build(BuildContext context) {
    return _buildCRUD(context, 'taxi_stations', 'Stations', ['name', 'capacity', 'location']);
  }
}

class _FareManagementTab extends StatelessWidget {
  const _FareManagementTab();
  @override
  Widget build(BuildContext context) {
    return _buildCRUD(context, 'taxi_fare_rules', 'Fare Rules', ['name', 'baseFare', 'distanceRate', 'timeRate']);
  }
}

class _CustomerFeedbackTab extends StatelessWidget {
  const _CustomerFeedbackTab();
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(tabs: [Tab(text: 'Ratings'), Tab(text: 'Complaints')]),
          Expanded(
            child: TabBarView(children: [
              _buildFeedbackList('taxi_ratings'),
              _buildFeedbackList('taxi_complaints'),
            ]),
          )
        ],
      ),
    );
  }

  Widget _buildFeedbackList(String collection) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, i) {
            final data = snapshot.data!.docs[i].data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassCard(
                child: ListTile(
                  title: Text(data['userName'] ?? 'Anonymous', style: const TextStyle(color: Colors.white)),
                  subtitle: Text(data['comment'] ?? data['description'] ?? '', style: const TextStyle(color: Colors.white70)),
                  trailing: Text(data['rating']?.toString() ?? data['status'] ?? '', style: const TextStyle(color: Colors.yellowAccent)),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _AITaxiAssistantTab extends StatelessWidget {
  const _AITaxiAssistantTab();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _aiInsight('Demand Forecast', 'Expect 45% surge in requests near University Station tomorrow morning (7-9 AM).', Icons.trending_up, Colors.orange),
        _aiInsight('Fleet Optimization', 'Current wait time at Piassa Station is 12 mins. Recommend moving 3 idle taxis from Menaharia.', Icons.bolt, Colors.yellow),
        _aiInsight('Revenue Prediction', 'Weekly revenue projected at 32,500 ETB (+12% from last week).', Icons.analytics, Colors.green),
        _aiInsight('Driver Performance', 'Driver Henok T. has the highest efficiency score this month. Ideal for long-distance city trips.', Icons.star, Colors.cyan),
      ],
    );
  }

  Widget _aiInsight(String title, String desc, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _BroadcastManagementTab extends StatefulWidget {
  const _BroadcastManagementTab();
  @override
  State<_BroadcastManagementTab> createState() => _BroadcastManagementTabState();
}

class _BroadcastManagementTabState extends State<_BroadcastManagementTab> {
  final _msgC = TextEditingController();
  String _type = 'Fleet Alert';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Text('Send Network Broadcast', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: _type,
            dropdownColor: const Color(0xFF212121),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Target Group', labelStyle: TextStyle(color: Colors.yellowAccent)),
            items: ['Fleet Alert', 'Driver Update', 'Emergency Notice', 'System Maintenance']
                .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => setState(() => _type = v!),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _msgC,
            maxLines: 5,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Message to all drivers',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.yellowAccent)),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('announcements').add({
                  'title': _type,
                  'message': _msgC.text,
                  'category': 'Taxi',
                  'timestamp': FieldValue.serverTimestamp(),
                  'isActive': true,
                });
                _msgC.clear();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Broadcast sent to all taxi nodes.')));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.yellowAccent, foregroundColor: Colors.black),
              child: const Text('SEND NOTIFICATION', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildCRUD(BuildContext context, String collection, String title, List<String> fields) {
  return Stack(
    children: [
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(collection).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, i) {
              final d = snapshot.data!.docs[i].data() as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  child: ListTile(
                    title: Text(d[fields[0]]?.toString() ?? 'N/A', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(d[fields[1]]?.toString() ?? '', style: const TextStyle(color: Colors.white70)),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CRUDListScreen(collection: collection, title: title, fields: fields))),
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
          backgroundColor: Colors.yellowAccent,
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CRUDListScreen(collection: collection, title: title, fields: fields))),
          child: const Icon(Icons.add, color: Colors.black),
        ),
      ),
    ],
  );
}
