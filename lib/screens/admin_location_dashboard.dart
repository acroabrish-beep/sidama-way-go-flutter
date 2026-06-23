import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(7.0504, 38.4955),
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.sidama.sidama_way_go',
              ),
              MarkerLayer(markers: locationProv.markers),
            ],
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
    // Note: markers are simple Marker objects from flutter_map now.
    // We simplified this to just show basic stats to avoid Marker API differences.
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Live Activity', style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            _summaryItem(Icons.location_on, 'Active Markers', prov.markers.length, Colors.blue),
            const Text('Total tracked entities', style: TextStyle(fontSize: 10, color: Colors.grey)),
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
