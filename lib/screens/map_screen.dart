import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  StreamSubscription<Position>? _locationStream;
  bool _isTracking = false;
  bool _isLoading = true;
  String _statusMsg = 'Getting your location...';

  static const LatLng _hawassa = LatLng(7.0504, 38.4955);
  final Set<Marker> _markers = {};
  LatLng _center = _hawassa;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _locationStream?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    setState(() { _isLoading = true; _statusMsg = 'Requesting permission...'; });

    final permission = await Permission.location.request();
    if (!permission.isGranted) {
      setState(() { _isLoading = false; _statusMsg = 'Location permission denied'; });
      return;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('GPS Disabled'),
            content: const Text('Please enable location services to use tracking.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                onPressed: () { Navigator.pop(context); Geolocator.openLocationSettings(); },
                child: const Text('Enable GPS'),
              ),
            ],
          ),
        );
      }
      setState(() { _isLoading = false; _statusMsg = 'GPS disabled — using Hawassa default'; });
      return;
    }

    setState(() { _statusMsg = 'Getting GPS position...'; });
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _updatePosition(pos);
    } catch (e) {
      setState(() { _isLoading = false; _statusMsg = 'Location error — using Hawassa default'; });
    }
  }

  void _updatePosition(Position pos) {
    final latlng = LatLng(pos.latitude, pos.longitude);
    setState(() {
      _currentPosition = pos;
      _center = latlng;
      _isLoading = false;
      _statusMsg = 'Location found';
      _markers.clear();
      _markers.add(Marker(
        markerId: const MarkerId('my_location'),
        position: latlng,
        infoWindow: const InfoWindow(title: 'My Current Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    });
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latlng, 15));
  }

  Future<void> _saveToFirestore(Position pos) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
      await FirebaseFirestore.instance.collection('users_locations').add({
        'userId': userId,
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'accuracy': pos.accuracy,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Firestore save error: $e');
    }
  }

  void _startTracking() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
    _locationStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (pos) {
        _updatePosition(pos);
        _saveToFirestore(pos);
        setState(() { _statusMsg = 'Live tracking active'; });
      },
      onError: (e) => setState(() { _statusMsg = 'Tracking error: $e'; }),
    );
    setState(() { _isTracking = true; });
  }

  void _stopTracking() {
    _locationStream?.cancel();
    setState(() { _isTracking = false; _statusMsg = 'Tracking stopped'; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text('Live GPS Tracking', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (c) => _mapController = c,
            initialCameraPosition: CameraPosition(target: _center, zoom: 14),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF2E7D32)),
                        SizedBox(height: 16),
                        Text('Getting location...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(_isTracking ? Icons.location_on : Icons.location_off,
                          color: _isTracking ? Colors.green : Colors.grey, size: 18),
                      const SizedBox(width: 6),
                      Text(_statusMsg, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                    ]),
                    if (_currentPosition != null) ...[
                      const SizedBox(height: 6),
                      Text('Latitude: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      Text('Longitude: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      Text('Accuracy: ±${_currentPosition!.accuracy.toStringAsFixed(1)} m',
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: _isTracking
                ? ElevatedButton.icon(
                    onPressed: _stopTracking,
                    icon: const Icon(Icons.stop_circle),
                    label: const Text('Stop Tracking'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: _startTracking,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Start Live Tracking'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
