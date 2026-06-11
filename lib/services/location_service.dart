import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<Position>? _positionStreamSubscription;

  /// Request permissions and get current location
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  /// Start live location tracking and save to Firebase
  void startLiveTracking(String type) {
    _positionStreamSubscription?.cancel();

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((Position position) {
      _updateLocationInFirebase(position, type);
    });
  }

  void stopLiveTracking() {
    _positionStreamSubscription?.cancel();
  }

  Future<void> _updateLocationInFirebase(Position position, String type) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final data = {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': FieldValue.serverTimestamp(),
      'userId': user.uid,
      'type': type, // 'user', 'taxi', 'bus'
    };

    // Update in general locations
    await _db.collection('locations').doc(user.uid).set(data, SetOptions(merge: true));

    // Update in specific collections based on type
    if (type == 'taxi') {
      await _db.collection('driver_locations').doc(user.uid).set(data, SetOptions(merge: true));
    } else if (type == 'bus') {
      await _db.collection('bus_locations').doc(user.uid).set(data, SetOptions(merge: true));
    }
  }

  /// Get live streams for different categories
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

  /// Save static locations (Hotels, Hospitals, etc.)
  Future<void> saveStaticLocation(String collection, String id, Map<String, dynamic> data) async {
    await _db.collection(collection).doc(id).set({
      ...data,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
