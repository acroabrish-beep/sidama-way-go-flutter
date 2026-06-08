import 'package:cloud_firestore/cloud_firestore.dart';

class SmartUser {
  final String id;
  final String fullName;
  final String phone;
  final String email;
  final String role; // 'passenger', 'driver', 'admin', 'officer'
  final String? profilePhoto;

  SmartUser({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.role,
    this.profilePhoto,
  });

  factory SmartUser.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return SmartUser(
      id: doc.id,
      fullName: data['fullName'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'passenger',
      profilePhoto: data['profilePhoto'],
    );
  }
}

class SmartVehicle {
  final String id;
  final String plateNumber;
  final String type; // 'bus', 'minibus', 'taxi', 'bajaj'
  final GeoPoint liveLocation;
  final String status; // 'active', 'inactive', 'emergency'
  final double currentSpeed;

  SmartVehicle({
    required this.id,
    required this.plateNumber,
    required this.type,
    required this.liveLocation,
    required this.status,
    required this.currentSpeed,
  });

  factory SmartVehicle.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return SmartVehicle(
      id: doc.id,
      plateNumber: data['plateNumber'] ?? '',
      type: data['type'] ?? '',
      liveLocation: data['liveLocation'] ?? const GeoPoint(7.0504, 38.4955),
      status: data['status'] ?? 'active',
      currentSpeed: (data['currentSpeed'] ?? 0).toDouble(),
    );
  }
}

class SmartTrip {
  final String id;
  final String passengerId;
  final String? driverId;
  final String routeId;
  final String status; // 'pending', 'started', 'completed', 'cancelled'
  final DateTime startTime;
  final double fare;

  SmartTrip({
    required this.id,
    required this.passengerId,
    this.driverId,
    required this.routeId,
    required this.status,
    required this.startTime,
    required this.fare,
  });
}
