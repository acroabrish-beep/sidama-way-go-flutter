import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';

class SmartCityMapScreen extends StatefulWidget {
  const SmartCityMapScreen({super.key});

  @override
  State<SmartCityMapScreen> createState() => _SmartCityMapScreenState();
}

class _SmartCityMapScreenState extends State<SmartCityMapScreen> {
  GoogleMapController? _mapController;

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
        title: const Text('Smart City Live Map'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: locationProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      locationProv.currentPosition?.latitude ?? 7.0504,
                      locationProv.currentPosition?.longitude ?? 38.4955,
                    ),
                    zoom: 14,
                  ),
                  markers: locationProv.markers,
                  myLocationEnabled: true,
                  onMapCreated: (controller) => _mapController = controller,
                ),
                Positioned(
                  top: 20,
                  left: 20,
                  right: 20,
                  child: _buildMapLegend(),
                ),
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: _buildNearbySearch(locationProv),
                ),
              ],
            ),
    );
  }

  Widget _buildMapLegend() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _legendItem(Icons.person_pin_circle, 'Me', Colors.blue),
              _legendItem(Icons.local_taxi, 'Taxi', Colors.yellow[700]!),
              _legendItem(Icons.directions_bus, 'Bus', Colors.blue[900]!),
              _legendItem(Icons.hotel, 'Hotel', Colors.green),
              _legendItem(Icons.local_pharmacy, 'Pharmacy', Colors.pink),
              _legendItem(Icons.local_hospital, 'Hospital', Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendItem(IconData icon, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildNearbySearch(LocationProvider prov) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 10),
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search Nearby...',
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.my_location, color: Color(0xFF2E7D32)),
              onPressed: () {
                if (prov.currentPosition != null) {
                  _mapController?.animateCamera(CameraUpdate.newLatLng(
                    LatLng(prov.currentPosition!.latitude, prov.currentPosition!.longitude),
                  ));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
