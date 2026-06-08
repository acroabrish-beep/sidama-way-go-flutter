import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleModel {
  final String id;
  final String type;
  final String driverName;
  final String plateNumber;
  final GeoPoint liveLocation;
  final bool isAvailable;

  VehicleModel({
    required this.id,
    required this.type,
    required this.driverName,
    required this.plateNumber,
    required this.liveLocation,
    required this.isAvailable,
  });

  factory VehicleModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return VehicleModel(
      id: doc.id,
      type: data['type'] ?? '',
      driverName: data['driverName'] ?? '',
      plateNumber: data['plateNumber'] ?? '',
      liveLocation: data['liveLocation'] ?? const GeoPoint(0, 0),
      isAvailable: data['isAvailable'] ?? false,
    );
  }
}

class TouristSpot {
  final String id;
  final String name;
  final String description;
  final String category;
  final GeoPoint location;
  final String? imageUrl;

  TouristSpot({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.location,
    this.imageUrl,
  });
}

class HospitalModel {
  final String id;
  final String name;
  final String type;
  final GeoPoint location;
  final String phone;

  HospitalModel({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.phone,
  });
}
