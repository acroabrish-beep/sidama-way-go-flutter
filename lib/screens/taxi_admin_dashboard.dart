import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/glass_card.dart';
import '../models/taxi_models.dart';

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
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('City Taxi Administration', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1A237E),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Live Map'),
            Tab(text: 'Verifications'),
            Tab(text: 'Stations'),
            Tab(text: 'Complaints'),
            Tab(text: 'Alerts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _OverviewTab(),
          const _LiveMapTab(),
          const _VerificationTab(),
          const _StationTab(),
          const _ComplaintTab(),
          const _AlertsTab(),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatsGrid(),
          const SizedBox(height: 24),
          const Text('Revenue & Trip Trends', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildChart(),
          const SizedBox(height: 24),
          const Text('Top Performing Zones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          _buildZoneList(),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _statCard('Total Drivers', 'drivers', Icons.people, Colors.blue),
        _statCard('Active Taxis', 'drivers', Icons.local_taxi, Colors.green, whereField: 'taxiStatus', whereValue: 'online'),
        _statCard('Total Trips', 'rides', Icons.route, Colors.orange),
        _statCard('Daily Revenue', 'rides', Icons.payments, Colors.purple, valueOverride: '12,450 ETB'),
      ],
    );
  }

  Widget _statCard(String label, String collection, IconData icon, Color color, {String? whereField, dynamic whereValue, String? valueOverride}) {
    Query query = FirebaseFirestore.instance.collection(collection);
    if (whereField != null) query = query.where(whereField, isEqualTo: whereValue);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        String val = valueOverride ?? (snapshot.hasData ? snapshot.data!.docs.length.toString() : '...');
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: [const FlSpot(0, 3), const FlSpot(1, 4), const FlSpot(2, 3.5), const FlSpot(3, 5), const FlSpot(4, 4), const FlSpot(5, 6)],
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 4,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.1)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZoneList() {
    return Column(
      children: [
        _zoneItem('Piassa', '45%', Colors.blue),
        _zoneItem('Menaharia', '30%', Colors.orange),
        _zoneItem('Tabor', '15%', Colors.green),
        _zoneItem('Haik Dar', '10%', Colors.red),
      ],
    );
  }

  Widget _zoneItem(String name, String percentage, Color color) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), radius: 15, child: Icon(Icons.location_on, color: color, size: 16)),
      title: Text(name),
      trailing: Text(percentage, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class _LiveMapTab extends StatelessWidget {
  const _LiveMapTab();

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(initialCenter: LatLng(7.0504, 38.4955), initialZoom: 13.0),
      children: [
        TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('drivers')
              .where('status', isEqualTo: 'approved')
              .where('isOnline', isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const MarkerLayer(markers: []);
            final markers = snapshot.data!.docs.map((doc) {
              final d = doc.data() as Map<String, dynamic>;
              final loc = d['location'] as GeoPoint?;
              return Marker(
                point: LatLng(loc?.latitude ?? 0, loc?.longitude ?? 0),
                child: const Icon(Icons.local_taxi, color: Colors.orange, size: 24),
              );
            }).toList();
            return MarkerLayer(markers: markers);
          },
        ),
      ],
    );
  }
}

class _VerificationTab extends StatelessWidget {
  const _VerificationTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('drivers').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final drivers = snapshot.data!.docs;
        return ListView.builder(
          itemCount: drivers.length,
          itemBuilder: (context, i) {
            final d = drivers[i].data() as Map<String, dynamic>;
            final status = d['status'] ?? 'pending';
            return ListTile(
              title: Text(d['fullName'] ?? 'Driver'),
              subtitle: Text('Taxi: ${d['plateNumber']} | Status: ${status.toUpperCase()}'),
              trailing: status == 'pending'
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), onPressed: () => drivers[i].reference.update({'status': 'approved'})),
                      IconButton(icon: const Icon(Icons.cancel, color: Colors.red), onPressed: () => drivers[i].reference.update({'status': 'rejected'})),
                    ],
                  )
                : const Icon(Icons.verified, color: Colors.blue),
            );
          },
        );
      },
    );
  }
}

class _StationTab extends StatelessWidget {
  const _StationTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('taxi_stations').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final stations = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: stations.length,
            itemBuilder: (context, i) {
              final s = stations[i].data() as Map<String, dynamic>;
              final name = s['name'] ?? 'Station';
              return _StationAnalyticsCard(name: name, capacity: s['capacity'] ?? 0, docId: stations[i].id);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addStation(context),
        backgroundColor: const Color(0xFF1A237E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _addStation(BuildContext context) {
    final nameC = TextEditingController();
    final capC = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Taxi Station'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Station Name')),
            TextField(controller: capC, decoration: const InputDecoration(labelText: 'Capacity'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('taxi_stations').add({
                'name': nameC.text,
                'capacity': int.tryParse(capC.text) ?? 10,
                'activeTaxis': 0,
                'location': const GeoPoint(7.0504, 38.4955),
              });
              Navigator.pop(context);
            },
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }
}

class _StationAnalyticsCard extends StatelessWidget {
  final String name;
  final int capacity;
  final String docId;
  const _StationAnalyticsCard({required this.name, required this.capacity, required this.docId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('drivers')
          .where('station', isEqualTo: name)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final total = docs.length;
        final approved = docs.where((d) => d['status'] == 'approved').length;
        final online = docs.where((d) => d['status'] == 'approved' && d['isOnline'] == true).length;
        final busy = docs.where((d) => d['status'] == 'approved' && d['taxiStatus'] == 'busy').length;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => FirebaseFirestore.instance.collection('taxi_stations').doc(docId).delete()),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statItem('Total', total.toString(), Colors.blue),
                    _statItem('Approved', approved.toString(), Colors.green),
                    _statItem('Online', online.toString(), Colors.orange),
                    _statItem('Busy', busy.toString(), Colors.red),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: capacity > 0 ? online / capacity : 0,
                  backgroundColor: Colors.grey[200],
                  color: Colors.green,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Text('Capacity: $online / $capacity', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}

class _ComplaintTab extends StatelessWidget {
  const _ComplaintTab();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('complaints').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, i) {
            final c = snapshot.data!.docs[i].data() as Map<String, dynamic>;
            return ListTile(
              leading: const Icon(Icons.warning_amber, color: Colors.red),
              title: Text(c['type'] ?? 'Complaint'),
              subtitle: Text(c['description'] ?? ''),
              trailing: Text(c['status'] ?? 'Open', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            );
          },
        );
      },
    );
  }
}

class _AlertsTab extends StatelessWidget {
  const _AlertsTab();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('emergency_alerts').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, i) {
            final a = snapshot.data!.docs[i].data() as Map<String, dynamic>;
            return Card(
              color: Colors.red[50],
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: const Icon(Icons.emergency, color: Colors.red),
                title: Text('SOS: ${a['driverName']}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                subtitle: Text('Location: ${a['location']?.latitude}, ${a['location']?.longitude}'),
                trailing: ElevatedButton(onPressed: () {}, child: const Text('RESOLVE')),
              ),
            );
          },
        );
      },
    );
  }
}
