import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/map_provider.dart';

class SmartMapScreen extends StatefulWidget {
  const SmartMapScreen({super.key});

  @override
  State<SmartMapScreen> createState() => _SmartMapScreenState();
}

class _SmartMapScreenState extends State<SmartMapScreen> {
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
          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: mapProv.currentLocation!,
              zoom: 14.0,
            ),
            markers: mapProv.markers,
            onMapCreated: (controller) => mapProv.setMapController(controller),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
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
