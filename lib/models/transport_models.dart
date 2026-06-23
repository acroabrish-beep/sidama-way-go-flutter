import 'package:cloud_firestore/cloud_firestore.dart';

class RouteModel {
  final String id;
  final String name;
  final String origin;
  final String destination;
  final double distance;
  final String estimatedDuration;
  final bool isActive;

  RouteModel({
    required this.id,
    required this.name,
    required this.origin,
    required this.destination,
    required this.distance,
    required this.estimatedDuration,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'origin': origin,
      'destination': destination,
      'distance': distance,
      'estimatedDuration': estimatedDuration,
      'isActive': isActive,
    };
  }

  factory RouteModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return RouteModel(
      id: doc.id,
      name: data['name'] ?? '',
      origin: data['origin'] ?? '',
      destination: data['destination'] ?? '',
      distance: (data['distance'] ?? 0).toDouble(),
      estimatedDuration: data['estimatedDuration'] ?? '',
      isActive: data['isActive'] ?? true,
    );
  }
}

class VehicleModel {
  final String id;
  final String plateNumber;
  final String type;
  final String model;
  final int capacity;
  final String? currentRouteId;
  final String status; // Active, In Maintenance, Out of Service

  VehicleModel({
    required this.id,
    required this.plateNumber,
    required this.type,
    required this.model,
    required this.capacity,
    this.currentRouteId,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'plateNumber': plateNumber,
      'type': type,
      'model': model,
      'capacity': capacity,
      'currentRouteId': currentRouteId,
      'status': status,
    };
  }

  factory VehicleModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return VehicleModel(
      id: doc.id,
      plateNumber: data['plateNumber'] ?? '',
      type: data['type'] ?? '',
      model: data['model'] ?? '',
      capacity: data['capacity'] ?? 0,
      currentRouteId: data['currentRouteId'],
      status: data['status'] ?? 'Active',
    );
  }
}

class ScheduleModel {
  final String id;
  final String routeId;
  final String vehicleId;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double fare;

  ScheduleModel({
    required this.id,
    required this.routeId,
    required this.vehicleId,
    required this.departureTime,
    required this.arrivalTime,
    required this.fare,
  });

  Map<String, dynamic> toMap() {
    return {
      'routeId': routeId,
      'vehicleId': vehicleId,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'fare': fare,
    };
  }

  factory ScheduleModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return ScheduleModel(
      id: doc.id,
      routeId: data['routeId'] ?? '',
      vehicleId: data['vehicleId'] ?? '',
      departureTime: (data['departureTime'] as Timestamp).toDate(),
      arrivalTime: (data['arrivalTime'] as Timestamp).toDate(),
      fare: (data['fare'] ?? 0).toDouble(),
    );
  }
}
