import 'package:cloud_firestore/cloud_firestore.dart';

class BusTerminal {
  final String id;
  final String name; // "Old Terminal" or "New Terminal"
  final String location;

  BusTerminal({required this.id, required this.name, required this.location});

  factory BusTerminal.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return BusTerminal(
      id: doc.id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
    );
  }
}

class BusRoute {
  final String id;
  final String terminalId;
  final String start;
  final String destination;
  final double fare;
  final List<String> schedule;

  BusRoute({
    required this.id,
    required this.terminalId,
    required this.start,
    required this.destination,
    required this.fare,
    required this.schedule,
  });

  factory BusRoute.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return BusRoute(
      id: doc.id,
      terminalId: data['terminalId'] ?? '',
      start: data['start'] ?? '',
      destination: data['destination'] ?? '',
      fare: (data['fare'] ?? 0).toDouble(),
      schedule: List<String>.from(data['schedule'] ?? []),
    );
  }
}

class Ticket {
  final String id;
  final String passengerName;
  final String userId;
  final String busId;
  final String routeId;
  final int seatNumber;
  final String route;
  final DateTime date;
  final String paymentStatus;
  final String qrData;
  final bool isScanned;

  Ticket({
    required this.id,
    required this.passengerName,
    required this.userId,
    required this.busId,
    required this.routeId,
    required this.seatNumber,
    required this.route,
    required this.date,
    required this.paymentStatus,
    required this.qrData,
    this.isScanned = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'passengerName': passengerName,
      'userId': userId,
      'busId': busId,
      'routeId': routeId,
      'seatNumber': seatNumber,
      'route': route,
      'date': date,
      'paymentStatus': paymentStatus,
      'qrData': qrData,
      'isScanned': isScanned,
    };
  }

  factory Ticket.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Ticket(
      id: doc.id,
      passengerName: data['passengerName'] ?? '',
      userId: data['userId'] ?? '',
      busId: data['busId'] ?? '',
      routeId: data['routeId'] ?? '',
      seatNumber: data['seatNumber'] ?? 0,
      route: data['route'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      paymentStatus: data['paymentStatus'] ?? '',
      qrData: data['qrData'] ?? '',
      isScanned: data['isScanned'] ?? false,
    );
  }
}

class TaxiRoute {
  final String id;
  final String from;
  final String to;
  final double fare;

  TaxiRoute({required this.id, required this.from, required this.to, required this.fare});

  factory TaxiRoute.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return TaxiRoute(
      id: doc.id,
      from: data['from'] ?? '',
      to: data['to'] ?? '',
      fare: (data['fare'] ?? 0).toDouble(),
    );
  }
}

class TaxiQueue {
  final String taxiId;
  final String plateNumber;
  final int position;
  final DateTime joinedAt;

  TaxiQueue({required this.taxiId, required this.plateNumber, required this.position, required this.joinedAt});

  factory TaxiQueue.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return TaxiQueue(
      taxiId: doc.id,
      plateNumber: data['plateNumber'] ?? '',
      position: data['position'] ?? 0,
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
    );
  }
}
