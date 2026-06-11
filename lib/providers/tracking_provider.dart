import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackingProvider with ChangeNotifier {
  LatLng? _currentPosition = const LatLng(7.0504, 38.4955); // Hawassa Default
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isTracking = false;
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
    _updateUserMarker();
    notifyListeners();
  }

  void _startSimulation() {
    // List of simulated vehicles
    List<Map<String, dynamic>> simulatedVehicles = [
      {
        'id': 'bus_1',
        'type': 'Minibus',
        'pos': const LatLng(7.052, 38.485),
        'speed': 0.0001,
        'color': BitmapDescriptor.hueBlue,
        'path': [const LatLng(7.052, 38.485), const LatLng(7.060, 38.490), const LatLng(7.070, 38.495)]
      },
      {
        'id': 'bajaj_1',
        'type': 'Bajaj',
        'pos': const LatLng(7.060, 38.472),
        'speed': 0.00015,
        'color': BitmapDescriptor.hueYellow,
        'path': [const LatLng(7.060, 38.472), const LatLng(7.055, 38.475), const LatLng(7.050, 38.480)]
      },
      {
        'id': 'motor_1',
        'type': 'Motorbike',
        'pos': const LatLng(7.045, 38.498),
        'speed': 0.0002,
        'color': BitmapDescriptor.hueOrange,
        'path': [const LatLng(7.045, 38.498), const LatLng(7.040, 38.490), const LatLng(7.035, 38.485)]
      },
    ];

    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      final random = Random();
      for (var vehicle in simulatedVehicles) {
        LatLng oldPos = vehicle['pos'];
        // Random slight movement to simulate driving within Hawassa
        double newLat = oldPos.latitude + (random.nextDouble() - 0.5) * vehicle['speed'];
        double newLng = oldPos.longitude + (random.nextDouble() - 0.5) * vehicle['speed'];
        vehicle['pos'] = LatLng(newLat, newLng);

        _markers.removeWhere((m) => m.markerId.value == vehicle['id']);
        _markers.add(
          Marker(
            markerId: MarkerId(vehicle['id']),
            position: vehicle['pos'],
            icon: BitmapDescriptor.defaultMarkerWithHue(vehicle['color']),
            infoWindow: InfoWindow(title: vehicle['type'], snippet: 'Status: On Route'),
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

  void _updateUserMarker() {
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
    _simulationTimer?.cancel();
    super.dispose();
  }
}
