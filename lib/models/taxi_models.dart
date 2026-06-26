import 'package:cloud_firestore/cloud_firestore.dart';

enum DriverStatus { pending, approved, rejected, suspended }
enum TaxiStatus { online, offline, busy }

class TaxiDriver {
  final String id;
  final String fullName;
  final String phone;
  final String email;
  final String profilePhoto;
  final String nationalId;
  final String drivingLicense;
  final String vehiclePhoto;
  final String plateNumber;
  final String vehicleModel;
  final String vehicleColor;
  final String vehicleType;
  final String station;
  final String? stationId;
  final DriverStatus status;
  final TaxiStatus taxiStatus;
  final bool isOnline; // Explicitly requested field
  final double rating;
  final GeoPoint? location;
  final String? currentZone;
  final DateTime? lastUpdate;

  TaxiDriver({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.profilePhoto,
    required this.nationalId,
    required this.drivingLicense,
    required this.vehiclePhoto,
    required this.plateNumber,
    required this.vehicleModel,
    required this.vehicleColor,
    required this.vehicleType,
    required this.station,
    this.stationId,
    required this.status,
    required this.taxiStatus,
    this.isOnline = false,
    this.rating = 5.0,
    this.location,
    this.currentZone,
    this.lastUpdate,
  });

  factory TaxiDriver.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return TaxiDriver(
      id: doc.id,
      fullName: data['fullName'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      profilePhoto: data['profilePhoto'] ?? '',
      nationalId: data['nationalId'] ?? '',
      drivingLicense: data['drivingLicense'] ?? '',
      vehiclePhoto: data['vehiclePhoto'] ?? '',
      plateNumber: data['plateNumber'] ?? '',
      vehicleModel: data['vehicleModel'] ?? '',
      vehicleColor: data['vehicleColor'] ?? '',
      vehicleType: data['vehicleType'] ?? '',
      station: data['station'] ?? 'Unknown',
      stationId: data['stationId'],
      status: DriverStatus.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == (data['status'] as String? ?? '').toLowerCase(),
        orElse: () => DriverStatus.pending,
      ),
      taxiStatus: TaxiStatus.values.firstWhere((e) => e.toString().split('.').last == data['taxiStatus'], orElse: () => TaxiStatus.offline),
      isOnline: data['isOnline'] ?? false,
      rating: (data['rating'] ?? 5.0).toDouble(),
      location: data['location'] as GeoPoint?,
      currentZone: data['currentZone'],
      lastUpdate: (data['lastUpdate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'profilePhoto': profilePhoto,
      'nationalId': nationalId,
      'drivingLicense': drivingLicense,
      'vehiclePhoto': vehiclePhoto,
      'plateNumber': plateNumber,
      'vehicleModel': vehicleModel,
      'vehicleColor': vehicleColor,
      'vehicleType': vehicleType,
      'station': station,
      'stationId': stationId,
      'status': status.toString().split('.').last.toUpperCase(), // To match user request 'APPROVED'
      'taxiStatus': taxiStatus.toString().split('.').last,
      'isOnline': isOnline,
      'rating': rating,
      'location': location,
      'currentZone': currentZone,
      'lastUpdate': lastUpdate != null ? Timestamp.fromDate(lastUpdate!) : FieldValue.serverTimestamp(),
    };
  }
}

class RideRequest {
  final String id;
  final String userId;
  final String userName;
  final String pickup;
  final GeoPoint pickupLocation;
  final String destination;
  final GeoPoint destinationLocation;
  final double fare;
  final String status;
  final String? driverId;
  final String? driverName;
  final DateTime timestamp;

  RideRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.pickup,
    required this.pickupLocation,
    required this.destination,
    required this.destinationLocation,
    required this.fare,
    required this.status,
    this.driverId,
    this.driverName,
    required this.timestamp,
  });

  factory RideRequest.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return RideRequest(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      pickup: data['pickup'] ?? '',
      pickupLocation: data['pickupLocation'] as GeoPoint,
      destination: data['destination'] ?? '',
      destinationLocation: data['destinationLocation'] as GeoPoint,
      fare: (data['fare'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'Pending',
      driverId: data['driverId'],
      driverName: data['driverName'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}

class TaxiStation {
  final String id;
  final String name;
  final GeoPoint location;
  final int capacity;
  final int activeTaxis;

  TaxiStation({
    required this.id,
    required this.name,
    required this.location,
    required this.capacity,
    this.activeTaxis = 0,
  });

  factory TaxiStation.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return TaxiStation(
      id: doc.id,
      name: data['name'] ?? '',
      location: data['location'] as GeoPoint,
      capacity: data['capacity'] ?? 0,
      activeTaxis: data['activeTaxis'] ?? 0,
    );
  }
}
