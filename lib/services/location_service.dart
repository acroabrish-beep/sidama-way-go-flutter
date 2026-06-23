import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../models/city_os_models.dart';

class LocationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _updateTimer;

  /// Request permissions and get current location
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition();
  }

  /// Start live location tracking every 10 seconds (Phase 2 Requirement)
  void startLiveTracking(String type) {
    _positionStreamSubscription?.cancel();
    _updateTimer?.cancel();

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      // We still update on significant movement, but the timer ensures periodic updates
    });

    _updateTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      final pos = await Geolocator.getCurrentPosition();
      _updateLocationInFirebase(pos, type);
    });
  }

  void stopLiveTracking() {
    _positionStreamSubscription?.cancel();
    _updateTimer?.cancel();
  }

  Future<void> _updateLocationInFirebase(Position position, String type) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final data = {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'speed': position.speed,
        'heading': position.heading,
        'lastUpdated': FieldValue.serverTimestamp(),
        'userId': user.uid,
        'type': type,
      };

      if (type == 'taxi') {
        await _db.collection(CityOSCollection.driverLocations).doc(user.uid).set(data, SetOptions(merge: true));
      } else if (type == 'bus') {
        await _db.collection('bus_locations').doc(user.uid).set(data, SetOptions(merge: true));
      }

      // Update in a general location log for smart city map
      await _db.collection('locations').doc(user.uid).set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error updating location in Firebase: $e");
    }
  }

  Stream<List<Map<String, dynamic>>> getLiveLocations(String type) {
    return _db.collection('locations')
        .where('type', isEqualTo: type)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<Map<String, dynamic>>> getAllCityLocations() {
    return _db.collection('locations').snapshots().map((snapshot) =>
      snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList());
  }

  Future<void> saveStaticLocation(String collection, String id, Map<String, dynamic> data) async {
    await _db.collection(collection).doc(id).set({
      ...data,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
