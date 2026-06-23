import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CityOSCollection {
  static const String users = 'users';
  static const String routes = 'routes';
  static const String vehicles = 'vehicles';
  static const String drivers = 'drivers';
  static const String schedules = 'schedules';
  static const String ticketPrices = 'ticket_prices';
  static const String tickets = 'tickets';
  static const String payments = 'payments';
  static const String taxiStations = 'taxi_stations';
  static const String taxis = 'taxis';
  static const String taxiTrips = 'taxi_trips';
  static const String driverLocations = 'driver_locations';
  static const String tourismSites = 'tourism_sites';
  static const String hotels = 'hotels';
  static const String hotelBookings = 'hotel_bookings';
  static const String hospitals = 'hospitals';
  static const String pharmacies = 'pharmacies';
  static const String foodVendors = 'food_vendors';
  static const String foodOrders = 'food_orders';
  static const String ecoShineLocations = 'eco_shine_locations';
  static const String announcements = 'announcements';
  static const String emergencyRequests = 'emergency_requests';
  static const String notifications = 'notifications';
  static const String analytics = 'analytics';
}

class TicketModel {
  final String ticketId;
  final String userId;
  final String routeId;
  final String vehicleId;
  final String seatNumber;
  final String paymentStatus;
  final Timestamp timestamp;
  final bool isUsed;

  TicketModel({
    required this.ticketId,
    required this.userId,
    required this.routeId,
    required this.vehicleId,
    required this.seatNumber,
    required this.paymentStatus,
    required this.timestamp,
    this.isUsed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'ticketId': ticketId,
      'userId': userId,
      'routeId': routeId,
      'vehicleId': vehicleId,
      'seatNumber': seatNumber,
      'paymentStatus': paymentStatus,
      'timestamp': timestamp,
      'isUsed': isUsed,
    };
  }

  factory TicketModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return TicketModel(
      ticketId: data['ticketId'] ?? '',
      userId: data['userId'] ?? '',
      routeId: data['routeId'] ?? '',
      vehicleId: data['vehicleId'] ?? '',
      seatNumber: data['seatNumber'] ?? '',
      paymentStatus: data['paymentStatus'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      isUsed: data['isUsed'] ?? false,
    );
  }
}

class DriverLocationModel {
  final String driverId;
  final double latitude;
  final double longitude;
  final double speed;
  final double heading;
  final Timestamp lastUpdated;

  DriverLocationModel({
    required this.driverId,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.heading,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'heading': heading,
      'lastUpdated': lastUpdated,
    };
  }
}
