import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/map_provider.dart';

class SmartMapScreen extends StatefulWidget {
  const SmartMapScreen({super.key});

  @override
  State<SmartMapScreen> createState() => _SmartMapScreenState();
}

class _SmartMapScreenState extends State<SmartMapScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mapProv = Provider.of<MapProvider>(context, listen: false);
      mapProv.initializeLocation();
      mapProv.listenToVehicles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hawassa Live Tracking'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Consumer<MapProvider>(
        builder: (context, mapProv, child) {
          if (mapProv.currentLocation == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: mapProv.currentLocation!,
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.sidama.sidama_way_go',
              ),
              MarkerLayer(markers: mapProv.markers.toList()),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Show bottom sheet for ride booking
        },
        label: const Text('Book Ride'),
        icon: const Icon(Icons.local_taxi),
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );
  }
}
