import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/location_service.dart';

class MapProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();
  LatLng? _currentLocation;
  final List<Marker> _markers = [];

  LatLng? get currentLocation => _currentLocation;
  List<Marker> get markers => _markers;

  void setMapController(dynamic controller) {
    // Controller can be used here if needed
  }

  Future<void> initializeLocation() async {
    try {
      Position? position = await _locationService.getCurrentLocation();
      if (position != null) {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _updateUserMarker();
        notifyListeners();
      }

      // Start live tracking from service
      _locationService.startLiveTracking('user');

    } catch (e) {
      debugPrint("Error initializing location: $e");
    }
  }

  void _updateUserMarker() {
    if (_currentLocation != null) {
      _markers.removeWhere((m) => m.key == const Key('user_location'));
      _markers.add(
        Marker(
          key: const Key('user_location'),
          point: _currentLocation!,
          width: 40,
          height: 40,
          child: const Icon(Icons.location_on, color: Colors.blue, size: 30),
        ),
      );
    }
  }

  void listenToVehicles() {
    FirebaseFirestore.instance.collection('vehicles').snapshots().listen((snapshot) {
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final GeoPoint? point = data['liveLocation'];
        if (point == null) continue;

        final markerKey = Key(doc.id);

        _markers.removeWhere((m) => m.key == markerKey);
        _markers.add(
          Marker(
            key: markerKey,
            point: LatLng(point.latitude, point.longitude),
            width: 40,
            height: 40,
            child: const Icon(Icons.directions_car, color: Colors.green, size: 30),
          ),
        );
      }
      notifyListeners();
    });
  }
}
