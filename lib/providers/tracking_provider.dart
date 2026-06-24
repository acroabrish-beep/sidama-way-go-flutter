import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TrackingProvider with ChangeNotifier {
  final LatLng? _currentPosition = const LatLng(7.0504, 38.4955); // Hawassa Default
  final List<Marker> _markers = [];
  final List<Polyline> _polylines = [];
  bool _isTracking = false;
  Timer? _simulationTimer;

  LatLng? _navigationDestination;

  LatLng? get currentPosition => _currentPosition;
  List<Marker> get markers => _markers;
  List<Polyline> get polylines => _polylines;
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
        'color': Colors.blue,
      },
      {
        'id': 'bajaj_1',
        'type': 'Bajaj',
        'pos': const LatLng(7.060, 38.472),
        'speed': 0.00015,
        'color': Colors.orange,
      },
      {
        'id': 'motor_1',
        'type': 'Motorbike',
        'pos': const LatLng(7.045, 38.498),
        'speed': 0.0002,
        'color': Colors.red,
      },
    ];

    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      final random = Random();
      _markers.clear();
      _updateUserMarker();

      for (var vehicle in simulatedVehicles) {
        LatLng oldPos = vehicle['pos'];
        double newLat = oldPos.latitude + (random.nextDouble() - 0.5) * vehicle['speed'];
        double newLng = oldPos.longitude + (random.nextDouble() - 0.5) * vehicle['speed'];
        vehicle['pos'] = LatLng(newLat, newLng);

        _markers.add(
          Marker(
            point: vehicle['pos'],
            width: 40,
            height: 40,
            child: Icon(
              vehicle['type'] == 'Minibus' ? Icons.directions_bus : Icons.local_taxi,
              color: vehicle['color'],
              size: 30,
            ),
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
        points: [_currentPosition!, dest],
        color: Colors.blue,
        strokeWidth: 4,
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
      _markers.add(
        Marker(
          point: _currentPosition!,
          width: 40,
          height: 40,
          child: const Icon(Icons.person_pin_circle, color: Colors.green, size: 40),
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
