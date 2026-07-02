import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/taxi_models.dart';
import '../services/taxi_service.dart';
import '../utils/firestore_utils.dart';

class TaxiAdminDashboard extends StatefulWidget {
  const TaxiAdminDashboard({super.key});

  @override
  State<TaxiAdminDashboard> createState() => _TaxiAdminDashboardState();
}

class _TaxiAdminDashboardState extends State<TaxiAdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TaxiService _taxiService = TaxiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _taxiService.seedStations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Smart City Dispatch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            Text('Hawassa Taxi Station Management', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        backgroundColor: const Color(0xFF1A237E),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => setState(() {})),
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.orangeAccent,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Stations'),
            Tab(text: 'Taxis'),
            Tab(text: 'Live Map'),
            Tab(text: 'Requests'),
            Tab(text: 'Alerts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _OverviewTab(),
          const _StationsTab(),
          const _TaxisTab(),
          const _LiveMapTab(),
          const _RequestsTab(),
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
      color: const Color(0xFFF8F9FA),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildStatsCards(),
          const SizedBox(height: 30),
          const Text('Station Performance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
          const SizedBox(height: 15),
          _buildPerformanceChart(),
          const SizedBox(height: 30),
          const Text('Today\'s Trends', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
          const SizedBox(height: 15),
          _buildTrendsList(),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('taxi_stations').snapshots(),
      builder: (context, stationSnap) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('drivers').snapshots(),
          builder: (context, driverSnap) {
            final stations = stationSnap.data?.docs.length ?? 0;
            final drivers = driverSnap.data?.docs ?? [];
            final online = drivers.where((d) => (d.data() as Map)['isOnline'] == true).length;
            final busy = drivers.where((d) => (d.data() as Map)['taxiStatus'] == 'busy').length;
            final offline = drivers.length - online;

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              childAspectRatio: 1.5,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              children: [
                _statCard('Total Stations', stations.toString(), Icons.place, Colors.blue),
                _statCard('Online Taxis', online.toString(), Icons.local_taxi, Colors.green),
                _statCard('Busy Taxis', busy.toString(), Icons.timer, Colors.orange),
                _statCard('Offline Taxis', offline.toString(), Icons.no_sim, Colors.grey),
                _statCard('Waiting Passengers', '24', Icons.people, Colors.purple),
                _statCard('Completed Trips', '142', Icons.check_circle, Colors.teal),
                _statStatCard('Today\'s Revenue', '18,450 ETB', Icons.payments, Colors.indigo),
              ],
            );
          },
        );
      },
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: color.withOpacity(0.2))),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _statStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      color: color,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceChart() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.black12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: [
                BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: Colors.blue, width: 15)]),
                BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10, color: Colors.blue, width: 15)]),
                BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 14, color: Colors.blue, width: 15)]),
                BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 15, color: Colors.blue, width: 15)]),
                BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 13, color: Colors.blue, width: 15)]),
                BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 18, color: Colors.blue, width: 15)]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrendsList() {
    return Column(
      children: [
        _trendItem('Menaharia', 'High Demand', Colors.red),
        _trendItem('Piassa', 'Normal Flow', Colors.green),
        _trendItem('University', 'Idle Taxis', Colors.orange),
      ],
    );
  }

  Widget _trendItem(String station, String status, Color color) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), radius: 10, child: Container(decoration: BoxDecoration(shape: BoxShape.circle, color: color))),
      title: Text(station, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(status),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

class _StationsTab extends StatefulWidget {
  const _StationsTab();

  @override
  State<_StationsTab> createState() => _StationsTabState();
}

class _StationsTabState extends State<_StationsTab> {
  final TaxiService _taxiService = TaxiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<List<TaxiStation>>(
        stream: _taxiService.getTaxiStations(),
        builder: (context, stationSnapshot) {
          if (stationSnapshot.hasError) return Center(child: Text('Error: ${stationSnapshot.error}'));
          if (!stationSnapshot.hasData) return const Center(child: CircularProgressIndicator());

          return StreamBuilder<List<TaxiDriver>>(
            stream: _taxiService.getAllDrivers(),
            builder: (context, driverSnapshot) {
              if (!driverSnapshot.hasData) return const Center(child: CircularProgressIndicator());

              final stations = stationSnapshot.data!;
              final allDrivers = driverSnapshot.data!;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 20,
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F3F4)),
                    columns: const [
                      DataColumn(label: Text('STATION')),
                      DataColumn(label: Text('CAPACITY')),
                      DataColumn(label: Text('ONLINE')),
                      DataColumn(label: Text('BUSY')),
                      DataColumn(label: Text('WAITING PASS.')),
                      DataColumn(label: Text('STATUS')),
                      DataColumn(label: Text('ACTIONS')),
                    ],
                    rows: stations.map((s) {
                      final stationDrivers = allDrivers.where((d) => d.stationId == s.id).toList();
                      final onlineCount = stationDrivers.where((d) => d.isOnline).length;
                      final busyCount = stationDrivers.where((d) => d.taxiStatus == TaxiStatus.busy).length;

                      return DataRow(cells: [
                        DataCell(Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(s.capacity.toString())),
                        DataCell(Text(onlineCount.toString(), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                        DataCell(Text(busyCount.toString(), style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))),
                        DataCell(Text(s.waitingPassengers.toString())),
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: Text(s.status.toUpperCase(), style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                        )),
                        DataCell(Row(
                          children: [
                            IconButton(icon: const Icon(Icons.edit, size: 18, color: Colors.blue), onPressed: () {}),
                            IconButton(icon: const Icon(Icons.move_up, size: 18, color: Colors.orange), onPressed: () {}),
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStationDialog(context),
        label: const Text('Add Station'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showAddStationDialog(BuildContext context) {
    final nameC = TextEditingController();
    final capC = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Register New Station'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Station Name')),
            const SizedBox(height: 10),
            TextField(controller: capC, decoration: const InputDecoration(labelText: 'Capacity'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              _taxiService.saveStation(TaxiStation(
                id: '',
                name: nameC.text,
                capacity: int.parse(capC.text),
                location: const GeoPoint(7.0504, 38.4955),
              ));
              Navigator.pop(context);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
}

class _TaxisTab extends StatelessWidget {
  const _TaxisTab();

  @override
  Widget build(BuildContext context) {
    final TaxiService taxiService = TaxiService();
    return Scaffold(
      body: StreamBuilder<List<TaxiDriver>>(
        stream: taxiService.getAllDrivers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final taxis = snapshot.data!;
          return ListView.separated(
            itemCount: taxis.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final t = taxis[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(t.taxiStatus).withOpacity(0.1),
                  child: Icon(Icons.local_taxi, color: _getStatusColor(t.taxiStatus)),
                ),
                title: Text(t.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${t.plateNumber} • ${t.station}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(t.taxiStatus.toString().split('.').last.toUpperCase(),
                      style: TextStyle(color: _getStatusColor(t.taxiStatus), fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(width: 10),
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'move', child: Text('Move Station')),
                        const PopupMenuItem(value: 'status', child: Text('Change Status')),
                        const PopupMenuItem(value: 'delete', child: Text('Remove')),
                      ],
                      onSelected: (val) {
                        if (val == 'move') _showMoveTaxiDialog(context, t);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRegisterTaxiDialog(context),
        label: const Text('Register Taxi'),
        icon: const Icon(Icons.add_road),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
    );
  }

  Color _getStatusColor(TaxiStatus status) {
    switch (status) {
      case TaxiStatus.online: return Colors.green;
      case TaxiStatus.busy: return Colors.orange;
      case TaxiStatus.offline: return Colors.grey;
    }
  }

  void _showMoveTaxiDialog(BuildContext context, TaxiDriver driver) {
    final TaxiService taxiService = TaxiService();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Move ${driver.fullName}'),
        content: StreamBuilder<List<TaxiStation>>(
          stream: taxiService.getTaxiStations(),
          builder: (context, snap) {
            if (!snap.hasData) return const CircularProgressIndicator();
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: snap.data!.map((s) => ListTile(
                title: Text(s.name),
                onTap: () {
                  taxiService.moveTaxiBetweenStations(driver.id, driver.stationId, s.id, s.name);
                  Navigator.pop(context);
                },
              )).toList(),
            );
          },
        ),
      ),
    );
  }

  void _showRegisterTaxiDialog(BuildContext context) {
    final taxiNumberC = TextEditingController();
    final plateNumberC = TextEditingController();
    final driverNameC = TextEditingController();
    final driverPhoneC = TextEditingController();
    final vehicleModelC = TextEditingController();
    final vehicleColorC = TextEditingController();
    String selectedStatus = 'Offline';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Register New Taxi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: taxiNumberC, decoration: const InputDecoration(labelText: 'Taxi Number')),
              TextField(controller: plateNumberC, decoration: const InputDecoration(labelText: 'Plate Number')),
              TextField(controller: driverNameC, decoration: const InputDecoration(labelText: 'Driver Name')),
              TextField(controller: driverPhoneC, decoration: const InputDecoration(labelText: 'Phone')),
              TextField(controller: vehicleModelC, decoration: const InputDecoration(labelText: 'Vehicle Model')),
              TextField(controller: vehicleColorC, decoration: const InputDecoration(labelText: 'Vehicle Color')),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(labelText: 'Initial Status'),
                items: ['Online', 'Offline', 'Busy', 'Maintenance']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => selectedStatus = v!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              final TaxiService taxiService = TaxiService();
              taxiService.registerTaxi(Taxi(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                taxiNumber: taxiNumberC.text,
                plateNumber: plateNumberC.text,
                driverName: driverNameC.text,
                driverPhone: driverPhoneC.text,
                vehicleModel: vehicleModelC.text,
                vehicleColor: vehicleColorC.text,
                currentStation: '',
                status: selectedStatus,
              ));
              Navigator.pop(context);
            },
            child: const Text('REGISTER'),
          ),
        ],
      ),
    );
  }
}

class _LiveMapTab extends StatelessWidget {
  const _LiveMapTab();

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(initialCenter: LatLng(7.0504, 38.4955), initialZoom: 13.5),
      children: [
        TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('taxi_stations').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const MarkerLayer(markers: []);
            return MarkerLayer(
              markers: snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                if (!data.containsKey('location')) return const Marker(point: LatLng(0,0), child: SizedBox());
                final loc = data['location'] as GeoPoint;
                return Marker(
                  point: LatLng(loc.latitude, loc.longitude),
                  width: 120, height: 60,
                  child: Column(
                    children: [
                      const Icon(Icons.place, color: Colors.blue, size: 30),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(5)),
                        child: Text(data['name'] ?? 'Station', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('drivers').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const MarkerLayer(markers: []);
            return MarkerLayer(
              markers: snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final loc = data['location'] as GeoPoint?;
                if (loc == null) return const Marker(point: LatLng(0,0), child: SizedBox());
                final status = data['taxiStatus'] ?? 'offline';
                final isOnline = data['isOnline'] ?? false;

                Color color = Colors.grey;
                if (isOnline) {
                  color = status == 'online' ? Colors.green : Colors.orange;
                }

                return Marker(
                  point: LatLng(loc.latitude, loc.longitude),
                  child: Transform.rotate(
                    angle: (data['heading'] ?? 0.0) * (3.14159 / 180),
                    child: Icon(Icons.navigation, color: color, size: 24),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _RequestsTab extends StatelessWidget {
  const _RequestsTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('ride_requests').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final requests = snapshot.data!.docs;
        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, i) {
            final r = requests[i].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: ListTile(
                title: Text('${r['pickup']} → ${r['destination']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Passenger: ${r['userName']} • Fare: ${r['fare']} ETB'),
                trailing: Text(r['status'], style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
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
        final alerts = snapshot.data!.docs;
        return ListView.builder(
          itemCount: alerts.length,
          itemBuilder: (context, i) {
            final a = alerts[i].data() as Map<String, dynamic>;
            return Card(
              color: Colors.red[50],
              margin: const EdgeInsets.all(10),
              child: ListTile(
                leading: const Icon(Icons.emergency, color: Colors.red),
                title: Text('SOS from ${a['driverName']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                subtitle: Text('Time: ${a['timestamp'] != null ? (FirestoreUtils.parseDateTime(a['timestamp'])?.toString() ?? 'Just now') : 'Just now'}'),
                trailing: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), child: const Text('DISPATCH HELP')),
              ),
            );
          },
        );
      },
    );
  }
}
