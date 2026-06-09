import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/tracking_provider.dart';
import '../widgets/map_placeholder.dart';

class RealtimeMapScreen extends StatefulWidget {
  const RealtimeMapScreen({super.key});

  @override
  State<RealtimeMapScreen> createState() => _RealtimeMapScreenState();
}

class _RealtimeMapScreenState extends State<RealtimeMapScreen> {
  GoogleMapController? _controller;

  final List<Map<String, dynamic>> _locations = [
    {'name': 'Hawassa Lake', 'lat': 7.060, 'lng': 38.470},
    {'name': 'Piazza', 'lat': 7.050, 'lng': 38.485},
    {'name': 'Stadium', 'lat': 7.045, 'lng': 38.495},
    {'name': 'University', 'lat': 7.070, 'lng': 38.490},
    {'name': 'Bus Station', 'lat': 7.055, 'lng': 38.480},
  ];

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => Provider.of<TrackingProvider>(context, listen: false).clearNavigation(),
          ),
        ],
      ),
      body: Consumer<TrackingProvider>(
        builder: (context, tracking, child) {
          bool usePlaceholder = kIsWeb; // Force placeholder on web to avoid crash

          return Stack(
            children: [
              usePlaceholder
                  ? HawassaMapPlaceholder(
                      userLocation: tracking.currentPosition,
                      markers: tracking.markers,
                      destination: tracking.navigationDestination,
                    )
                  : (tracking.currentPosition == null
                      ? const Center(child: CircularProgressIndicator())
                      : GoogleMap(
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
                        )),

              // Location Cards at Bottom
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _locations.length,
                    itemBuilder: (context, index) {
                      final loc = _locations[index];
                      return Container(
                        width: 250,
                        margin: const EdgeInsets.only(right: 12),
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc['name'],
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                const Text('Hawassa, Sidama', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                const Spacer(),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          tracking.navigateTo(LatLng(loc['lat'], loc['lng']));
                                          if (_controller != null) {
                                            _controller!.animateCamera(
                                              CameraUpdate.newLatLng(LatLng(loc['lat'], loc['lng'])),
                                            );
                                          }
                                        },
                                        icon: const Icon(Icons.navigation, size: 16),
                                        label: const Text('Navigate'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green[800],
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
