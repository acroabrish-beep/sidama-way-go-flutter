import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/tracking_provider.dart';

class RealtimeMapScreen extends StatefulWidget {
  const RealtimeMapScreen({super.key});

  @override
  State<RealtimeMapScreen> createState() => _RealtimeMapScreenState();
}

class _RealtimeMapScreenState extends State<RealtimeMapScreen> {
  GoogleMapController? _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TrackingProvider>(context, listen: false).startTracking();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hawassa Live Tracking'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: Consumer<TrackingProvider>(
        builder: (context, tracking, child) {
          if (tracking.currentPosition == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: tracking.currentPosition!,
                  zoom: 15,
                ),
                markers: tracking.markers,
                polylines: tracking.polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  _controller = controller;
                },
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Nearby Vehicles Active',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildVehicleTypeIcon(Icons.motorcycle, 'Motor'),
                            _buildVehicleTypeIcon(Icons.electric_rickshaw, 'Bajaj'),
                            _buildVehicleTypeIcon(Icons.directions_car, 'Taxi'),
                          ],
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Book Ride Logic
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[800],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: const Text('BOOK SMART RIDE'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVehicleTypeIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.green[800]),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
