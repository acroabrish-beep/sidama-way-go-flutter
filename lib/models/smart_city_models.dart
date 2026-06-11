import 'package:cloud_firestore/cloud_firestore.dart';

class CityUser {
  final String id;
  final String fullName;
  final String phone;
  final String email;
  final String role; // 'passenger', 'driver', 'admin', 'terminal_admin', 'transport_admin'
  final DateTime createdAt;

  CityUser({required this.id, required this.fullName, required this.phone, required this.email, required this.role, required this.createdAt});

  factory CityUser.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return CityUser(
      id: doc.id,
      fullName: data['fullName'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'passenger',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class TerminalBus {
  final String id;
  final String terminalId; // 'old' or 'new'
  final String plateNumber;
  final String driverName;
  final String routeId;
  final int totalSeats;
  final List<int> occupiedSeats;
  final String status; // 'ready', 'on_route', 'maintenance'

  TerminalBus({required this.id, required this.terminalId, required this.plateNumber, required this.driverName, required this.routeId, required this.totalSeats, required this.occupiedSeats, required this.status});

  factory TerminalBus.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return TerminalBus(
      id: doc.id,
      terminalId: data['terminalId'] ?? '',
      plateNumber: data['plateNumber'] ?? '',
      driverName: data['driverName'] ?? '',
      routeId: data['routeId'] ?? '',
      totalSeats: data['totalSeats'] ?? 45,
      occupiedSeats: List<int>.from(data['occupiedSeats'] ?? []),
      status: data['status'] ?? 'ready',
    );
  }
}

class BusTerminalTicket {
  final String id;
  final String passengerName;
  final String userId;
  final String route;
  final String busId;
  final int seatNumber;
  final double fare;
  final String paymentStatus; // 'paid', 'pending'
  final DateTime travelDate;
  final String verificationCode;

  BusTerminalTicket({required this.id, required this.passengerName, required this.userId, required this.route, required this.busId, required this.seatNumber, required this.fare, required this.paymentStatus, required this.travelDate, required this.verificationCode});

  factory BusTerminalTicket.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return BusTerminalTicket(
      id: doc.id,
      passengerName: data['passengerName'] ?? '',
      userId: data['userId'] ?? '',
      route: data['route'] ?? '',
      busId: data['busId'] ?? '',
      seatNumber: data['seatNumber'] ?? 0,
      fare: (data['fare'] ?? 0).toDouble(),
      paymentStatus: data['paymentStatus'] ?? 'pending',
      travelDate: (data['travelDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      verificationCode: data['verificationCode'] ?? '',
    );
  }
}

class EmergencyRequest {
  final String id;
  final String userId;
  final String type; // 'ambulance', 'police', 'fire', 'road'
  final GeoPoint location;
  final String status; // 'pending', 'responding', 'completed'
  final DateTime timestamp;

  EmergencyRequest({required this.id, required this.userId, required this.type, required this.location, required this.status, required this.timestamp});

  factory EmergencyRequest.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return EmergencyRequest(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      location: data['location'] ?? const GeoPoint(7.0504, 38.4955),
      status: data['status'] ?? 'pending',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class TouristPlace {
  final String id;
  final String name;
  final String description;
  final String history;
  final GeoPoint location;
  final List<String> photos;
  final String? videoUrl;
  final String contact;
  final String openingHours;

  TouristPlace({required this.id, required this.name, required this.description, required this.history, required this.location, required this.photos, this.videoUrl, required this.contact, required this.openingHours});

  factory TouristPlace.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return TouristPlace(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      history: data['history'] ?? '',
      location: data['location'] ?? const GeoPoint(7.0504, 38.4955),
      photos: List<String>.from(data['photos'] ?? []),
      videoUrl: data['videoUrl'],
      contact: data['contact'] ?? '',
      openingHours: data['openingHours'] ?? '',
    );
  }
}
