import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  final String id;
  final String type;
  final String plateNumber;
  final String driverName;
  final GeoPoint location;
  final String status;
  final String? phone;

  Vehicle({
    required this.id,
    required this.type,
    required this.plateNumber,
    required this.driverName,
    required this.location,
    required this.status,
    this.phone,
  });

  factory Vehicle.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Vehicle(
      id: doc.id,
      type: data['type'] ?? '',
      plateNumber: data['plateNumber'] ?? '',
      driverName: data['driverName'] ?? '',
      location: data['location'] ?? const GeoPoint(0, 0),
      status: data['status'] ?? 'offline',
      phone: data['phone'],
    );
  }
}
