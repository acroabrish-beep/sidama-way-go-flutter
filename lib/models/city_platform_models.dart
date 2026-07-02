import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/firestore_utils.dart';

class CityUser {
  final String id;
  final String fullName;
  final String phone;
  final String email;
  final String role; // passenger, driver, terminal_admin, city_admin, healthcare_admin, pharmacy_admin
  final String? profilePhoto;

  CityUser({required this.id, required this.fullName, required this.phone, required this.email, required this.role, this.profilePhoto});

  factory CityUser.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return CityUser(
      id: doc.id,
      fullName: data['fullName'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'passenger',
      profilePhoto: data['profilePhoto'],
    );
  }
}

class BusTerminal {
  final String id;
  final String name;
  final String locationName;

  BusTerminal({required this.id, required this.name, required this.locationName});
}

class IntercityRoute {
  final String id;
  final String terminalId;
  final String destination;
  final double fare;
  final List<String> schedule;
  final List<int> availableSeats;

  IntercityRoute({required this.id, required this.terminalId, required this.destination, required this.fare, required this.schedule, required this.availableSeats});

  factory IntercityRoute.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return IntercityRoute(
      id: doc.id,
      terminalId: data['terminalId'] ?? '',
      destination: data['destination'] ?? '',
      fare: (data['fare'] ?? 0).toDouble(),
      schedule: List<String>.from(data['schedule'] ?? []),
      availableSeats: List<int>.from(data['availableSeats'] ?? []),
    );
  }
}

class Ticket {
  final String id;
  final String passengerName;
  final String route;
  final String terminal;
  final int seatNumber;
  final double fare;
  final String paymentStatus;
  final DateTime date;
  final String verificationCode;

  Ticket({required this.id, required this.passengerName, required this.route, required this.terminal, required this.seatNumber, required this.fare, required this.paymentStatus, required this.date, required this.verificationCode});

  factory Ticket.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Ticket(
      id: doc.id,
      passengerName: data['passengerName'] ?? '',
      route: data['route'] ?? '',
      terminal: data['terminal'] ?? '',
      seatNumber: data['seatNumber'] ?? 0,
      fare: (data['fare'] ?? 0).toDouble(),
      paymentStatus: data['paymentStatus'] ?? 'pending',
      date: FirestoreUtils.parseDateTimeOrDefault(data['date']),
      verificationCode: data['verificationCode'] ?? '',
    );
  }
}

class EmergencyAlert {
  final String id;
  final String type; // police, ambulance, fire, road
  final String userId;
  final GeoPoint location;
  final String status;
  final DateTime timestamp;

  EmergencyAlert({required this.id, required this.type, required this.userId, required this.location, required this.status, required this.timestamp});
}

class Hospital {
  final String id;
  final String name;
  final String address;
  final String phone;
  final GeoPoint location;
  final List<String> services;

  Hospital({required this.id, required this.name, required this.address, required this.phone, required this.location, required this.services});

  factory Hospital.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Hospital(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      location: data['location'] ?? const GeoPoint(0,0),
      services: List<String>.from(data['services'] ?? []),
    );
  }
}

class Pharmacy {
  final String id;
  final String name;
  final String address;
  final String phone;
  final GeoPoint location;

  Pharmacy({required this.id, required this.name, required this.address, required this.phone, required this.location});

  factory Pharmacy.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Pharmacy(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      location: data['location'] ?? const GeoPoint(0,0),
    );
  }
}

class Announcement {
  final String id;
  final String title;
  final String content;
  final String category;
  final String? imageUrl;
  final DateTime createdAt;

  Announcement({required this.id, required this.title, required this.content, required this.category, this.imageUrl, required this.createdAt});

  factory Announcement.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Announcement(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      category: data['category'] ?? 'General',
      imageUrl: data['imageUrl'],
      createdAt: FirestoreUtils.parseDateTimeOrDefault(data['createdAt']),
    );
  }
}
