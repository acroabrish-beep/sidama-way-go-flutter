import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';

class AdminLocationDashboard extends StatefulWidget {
  const AdminLocationDashboard({super.key});

  @override
  State<AdminLocationDashboard> createState() => _AdminLocationDashboardState();
}

class _AdminLocationDashboardState extends State<AdminLocationDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().listenToCityLive();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationProv = context.watch<LocationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('City Admin - Live Location'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(7.0504, 38.4955),
              zoom: 14,
            ),
            markers: locationProv.markers,
          ),
          Positioned(
            top: 20,
            left: 20,
            child: _buildSummaryCard(locationProv),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(LocationProvider prov) {
    int activeUsers = prov.markers.where((m) => m.markerId.value == 'user').length;
    int taxis = prov.markers.where((m) => m.infoWindow.title?.toLowerCase() == 'taxi').length;
    int buses = prov.markers.where((m) => m.infoWindow.title?.toLowerCase() == 'bus').length;
    int emergencies = prov.markers.where((m) => m.markerId.value.contains('emergency')).length;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Live Activity', style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            _summaryItem(Icons.person, 'Users', activeUsers, Colors.blue),
            _summaryItem(Icons.local_taxi, 'Taxis', taxis, Colors.yellow[700]!),
            _summaryItem(Icons.directions_bus, 'Buses', buses, Colors.blue[900]!),
            _summaryItem(Icons.warning, 'SOS', emergencies, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(IconData icon, String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontSize: 12)),
          Text('$count', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
