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
  final double? heading;
  final double? speed;
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
    this.heading,
    this.speed,
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
      heading: (data['heading'] ?? 0.0).toDouble(),
      speed: (data['speed'] ?? 0.0).toDouble(),
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
      'heading': heading,
      'speed': speed,
      'currentZone': currentZone,
      'lastUpdate': lastUpdate != null ? Timestamp.fromDate(lastUpdate!) : FieldValue.serverTimestamp(),
    };
  }
}

class Taxi {
  final String id;
  final String taxiNumber;
  final String plateNumber;
  final String driverName;
  final String driverPhone;
  final String vehicleModel;
  final String vehicleColor;
  final String currentStation;
  final String? currentStationId;
  final String status; // Online, Offline, Busy, Maintenance
  final DateTime? updatedAt;

  Taxi({
    required this.id,
    required this.taxiNumber,
    required this.plateNumber,
    required this.driverName,
    required this.driverPhone,
    required this.vehicleModel,
    required this.vehicleColor,
    required this.currentStation,
    this.currentStationId,
    required this.status,
    this.updatedAt,
  });

  factory Taxi.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Taxi(
      id: doc.id,
      taxiNumber: data['taxiNumber'] ?? '',
      plateNumber: data['plateNumber'] ?? '',
      driverName: data['driverName'] ?? '',
      driverPhone: data['driverPhone'] ?? '',
      vehicleModel: data['vehicleModel'] ?? '',
      vehicleColor: data['vehicleColor'] ?? '',
      currentStation: data['currentStation'] ?? '',
      currentStationId: data['currentStationId'],
      status: data['status'] ?? 'Offline',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'taxiNumber': taxiNumber,
      'plateNumber': plateNumber,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'vehicleModel': vehicleModel,
      'vehicleColor': vehicleColor,
      'currentStation': currentStation,
      'currentStationId': currentStationId,
      'status': status,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
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
  final String? plateNumber;
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
    this.plateNumber,
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
      plateNumber: data['plateNumber'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'pickup': pickup,
      'pickupLocation': pickupLocation,
      'destination': destination,
      'destinationLocation': destinationLocation,
      'fare': fare,
      'status': status,
      'driverId': driverId,
      'driverName': driverName,
      'plateNumber': plateNumber,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}



class TaxiStation {
  final String id;
  final String name;
  final GeoPoint location;
  final int capacity;
  final int activeTaxiCount;
  final int waitingPassengers;
  final String status; // Active, Inactive, Full
  final DateTime? updatedAt;

  TaxiStation({
    required this.id,
    required this.name,
    required this.location,
    required this.capacity,
    this.activeTaxiCount = 0,
    this.waitingPassengers = 0,
    this.status = 'Active',
    this.updatedAt,
  });

  factory TaxiStation.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return TaxiStation(
      id: doc.id,
      name: data['name'] ?? '',
      location: data.containsKey('location') ? data['location'] as GeoPoint : const GeoPoint(7.0504, 38.4955),
      capacity: data['capacity'] ?? 0,
      activeTaxiCount: data['activeTaxiCount'] ?? 0,
      waitingPassengers: data['waitingPassengers'] ?? 0,
      status: data['status'] ?? 'Active',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'capacity': capacity,
      'activeTaxiCount': activeTaxiCount,
      'waitingPassengers': waitingPassengers,
      'status': status,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }
}

