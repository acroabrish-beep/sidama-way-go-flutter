import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/location_service.dart';

class MapProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();
  LatLng? _currentLocation;
  final Set<Marker> _markers = {};

  LatLng? get currentLocation => _currentLocation;
  Set<Marker> get markers => _markers;

  void setMapController(GoogleMapController controller) {
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

      // We can listen to all locations using the service's stream if needed
      _locationService.getAllCityLocations().listen((locations) {
         // Logic to update markers from city locations if needed
      });

    } catch (e) {
      debugPrint("Error initializing location: $e");
    }
  }

  void _updateUserMarker() {
    if (_currentLocation != null) {
      _markers.removeWhere((m) => m.markerId.value == 'user_location');
      _markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: _currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'My Location'),
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

        final markerId = MarkerId(doc.id);

        _markers.removeWhere((m) => m.markerId == markerId);
        _markers.add(
          Marker(
            markerId: markerId,
            position: LatLng(point.latitude, point.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(
              title: data['type'] ?? 'Vehicle',
              snippet: 'Driver: ${data['driverName'] ?? 'Unknown'}',
            ),
          ),
        );
      }
      notifyListeners();
    });
  }
}
