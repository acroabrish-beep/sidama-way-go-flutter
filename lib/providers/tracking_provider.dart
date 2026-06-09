import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/vehicle.dart';

class TrackingProvider with ChangeNotifier {
  LatLng? _currentPosition = const LatLng(7.0504, 38.4955); // Hawassa Default
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isTracking = false;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _simulationTimer;

  LatLng? _navigationDestination;

  LatLng? get currentPosition => _currentPosition;
  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;
  bool get isTracking => _isTracking;
  LatLng? get navigationDestination => _navigationDestination;

  TrackingProvider() {
    _startSimulation();
  }

  Future<void> startTracking() async {
    if (_isTracking) return;
    _isTracking = true;

    // In a real app, we use Geolocator.
    // For simulation, we'll keep the static/animated current position.
    _updateMarkers();
    notifyListeners();
  }

  void _startSimulation() {
    // Simulated vehicles in Hawassa
    List<Map<String, dynamic>> simulatedVehicles = [
      {'id': 'v1', 'type': 'Minibus', 'pos': const LatLng(7.050, 38.485), 'speed': 0.0002},
      {'id': 'v2', 'type': 'Bajaj', 'pos': const LatLng(7.060, 38.470), 'speed': 0.0003},
      {'id': 'v3', 'type': 'Motor', 'pos': const LatLng(7.045, 38.495), 'speed': 0.0004},
    ];

    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      for (var v in simulatedVehicles) {
        LatLng oldPos = v['pos'];
        // Move slightly towards a random direction or fixed path
        double newLat = oldPos.latitude + (Random().nextDouble() - 0.5) * v['speed'];
        double newLng = oldPos.longitude + (Random().nextDouble() - 0.5) * v['speed'];
        v['pos'] = LatLng(newLat, newLng);

        _markers.removeWhere((m) => m.markerId.value == v['id']);
        _markers.add(
          Marker(
            markerId: MarkerId(v['id']),
            position: v['pos'],
            icon: BitmapDescriptor.defaultMarkerWithHue(
              v['type'] == 'Minibus' ? BitmapDescriptor.hueBlue :
              v['type'] == 'Bajaj' ? BitmapDescriptor.hueYellow : BitmapDescriptor.hueOrange
            ),
            infoWindow: InfoWindow(title: v['type'], snippet: 'Live Tracking'),
          ),
        );
      }
      notifyListeners();
    });
  }

  void navigateTo(LatLng dest) {
    _navigationDestination = dest;
    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: [_currentPosition!, dest],
        color: Colors.blue,
        width: 5,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    );
    notifyListeners();
  }

  void clearNavigation() {
    _navigationDestination = null;
    _polylines.clear();
    notifyListeners();
  }

  void _updateMarkers() {
    if (_currentPosition != null) {
      _markers.removeWhere((m) => m.markerId.value == 'user');
      _markers.add(
        Marker(
          markerId: const MarkerId('user'),
          position: _currentPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'You are here'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _simulationTimer?.cancel();
    super.dispose();
  }
}
