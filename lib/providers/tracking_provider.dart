import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/vehicle.dart';

class TrackingProvider with ChangeNotifier {
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isTracking = false;
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<QuerySnapshot>? _vehicleSubscription;

  LatLng? get currentPosition => _currentPosition;
  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;
  bool get isTracking => _isTracking;

  Future<void> startTracking() async {
    if (_isTracking) return;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    _isTracking = true;
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _updateUserLocationInFirestore(position);
      _updateMarkers();
      notifyListeners();
    });

    _listenToVehicles();
  }

  void _updateUserLocationInFirestore(Position position) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'lastLocation': GeoPoint(position.latitude, position.longitude),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  void _listenToVehicles() {
    _vehicleSubscription = FirebaseFirestore.instance
        .collection('vehicles')
        .where('status', isEqualTo: 'online')
        .snapshots()
        .listen((snapshot) {
      _markers.removeWhere((m) => m.markerId.value.startsWith('v_'));
      for (var doc in snapshot.docs) {
        final vehicle = Vehicle.fromFirestore(doc);
        _markers.add(
          Marker(
            markerId: MarkerId('v_${vehicle.id}'),
            position: LatLng(vehicle.location.latitude, vehicle.location.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            infoWindow: InfoWindow(
              title: '${vehicle.type} - ${vehicle.plateNumber}',
              snippet: 'Driver: ${vehicle.driverName}',
            ),
          ),
        );
      }
      notifyListeners();
    });
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
    _vehicleSubscription?.cancel();
    super.dispose();
  }
}
