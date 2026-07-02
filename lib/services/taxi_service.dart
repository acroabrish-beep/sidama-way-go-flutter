import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/taxi_models.dart';
import 'notification_service.dart';

class TaxiService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Seeding Taxi Stations
  Future<void> seedStations() async {
    final snapshot = await _db.collection('taxi_stations').limit(1).get();
    if (snapshot.docs.isEmpty) {
      final stations = [
        {'name': 'Menaharia', 'lat': 7.0621, 'lng': 38.4772, 'capacity': 50},
        {'name': 'Piassa', 'lat': 7.0504, 'lng': 38.4955, 'capacity': 40},
        {'name': 'Menbo', 'lat': 7.0550, 'lng': 38.4800, 'capacity': 30},
        {'name': 'University', 'lat': 7.0450, 'lng': 38.4900, 'capacity': 30},
        {'name': 'Tabor', 'lat': 7.0423, 'lng': 38.5085, 'capacity': 35},
        {'name': 'Hawela Tula', 'lat': 7.0315, 'lng': 38.5210, 'capacity': 25},
        {'name': 'Alamura', 'lat': 7.0150, 'lng': 38.4820, 'capacity': 20},
        {'name': 'Misrak', 'lat': 7.0600, 'lng': 38.5000, 'capacity': 30},
        {'name': 'Gudumale', 'lat': 7.0580, 'lng': 38.4850, 'capacity': 35},
        {'name': 'Haik Dar', 'lat': 7.0650, 'lng': 38.4750, 'capacity': 40},
        {'name': 'Addis Ketema', 'lat': 7.0700, 'lng': 38.4650, 'capacity': 30},
      ];
      for (var s in stations) {
        await _db.collection('taxi_stations').add({
          'name': s['name'],
          'location': GeoPoint(s['lat'] as double, s['lng'] as double),
          'capacity': s['capacity'],
          'activeTaxiCount': 0,
          'waitingPassengers': 0,
          'status': 'Active',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  // Driver Registration
  Future<void> registerDriver(TaxiDriver driver) async {
    await _db.collection('drivers').doc(driver.id).set(driver.toMap());
  }

  // Get Driver details (Stream)
  Stream<TaxiDriver?> getDriver(String driverId) {
    return _db.collection('drivers').doc(driverId).snapshots().map((doc) {
      if (doc.exists) return TaxiDriver.fromFirestore(doc);
      return null;
    });
  }

  // Get Driver by User ID
  Future<TaxiDriver?> getDriverByUserId(String userId) async {
    final snap = await _db.collection('drivers').where('userId', isEqualTo: userId).limit(1).get();
    if (snap.docs.isNotEmpty) return TaxiDriver.fromFirestore(snap.docs.first);
    return null;
  }

  // Update Driver
  Future<void> updateDriver(TaxiDriver driver) async {
    await _db.collection('drivers').doc(driver.id).update(driver.toMap());
  }

  // Approve Driver
  Future<void> approveDriver(String driverId) async {
    await _db.collection('drivers').doc(driverId).update({'status': 'APPROVED'});
  }

  // Reject Driver
  Future<void> rejectDriver(String driverId) async {
    await _db.collection('drivers').doc(driverId).update({'status': 'REJECTED'});
  }

  // Get All Taxi Stations
  Stream<List<TaxiStation>> getTaxiStations() {
    return _db.collection('taxi_stations').snapshots().map((snap) {
      return snap.docs.map((doc) => TaxiStation.fromFirestore(doc)).toList();
    });
  }

  // Get All Stations (Alias)
  Stream<List<TaxiStation>> getStations() => getTaxiStations();

  // Get Single Station
  Stream<TaxiStation?> getStation(String stationId) {
    return _db.collection('taxi_stations').doc(stationId).snapshots().map((doc) {
      if (doc.exists) return TaxiStation.fromFirestore(doc);
      return null;
    });
  }

  // Active Driver Count for a Station
  Stream<int> getActiveDriverCount(String stationId) {
    return _db.collection('drivers')
        .where('stationId', isEqualTo: stationId)
        .snapshots()
        .map((snap) {
          return snap.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return (data['status'] == 'APPROVED' || data['status'] == 'approved') && data['isOnline'] == true;
          }).length;
        });
  }

  // Passenger: Find nearby approved online drivers
  Stream<List<TaxiDriver>> getNearbyDrivers(GeoPoint userLoc) {
    return _db.collection('drivers')
        .where('status', isEqualTo: 'APPROVED')
        .snapshots()
        .map((snap) {
          final drivers = snap.docs
              .map((doc) => TaxiDriver.fromFirestore(doc))
              .where((d) => d.isOnline)
              .toList();
          drivers.sort((a, b) {
            if (a.location == null || b.location == null) return 0;
            double distA = Geolocator.distanceBetween(userLoc.latitude, userLoc.longitude, a.location!.latitude, a.location!.longitude);
            double distB = Geolocator.distanceBetween(userLoc.latitude, userLoc.longitude, b.location!.latitude, b.location!.longitude);
            return distA.compareTo(distB);
          });
          return drivers;
        });
  }

  // Ride Requests
  Future<String> requestSmartTaxi(RideRequest request, String stationId) async {
    final driversSnap = await _db.collection('drivers').where('stationId', isEqualTo: stationId).get();
    final eligibleDrivers = driversSnap.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return (data['status'] == 'APPROVED' || data['status'] == 'approved') && data['isOnline'] == true && data['taxiStatus'] == 'online';
    }).toList();

    if (eligibleDrivers.isEmpty) throw 'No active drivers available at this station.';

    DocumentSnapshot? nearestDriverDoc;
    double minDistance = double.infinity;

    for (var doc in eligibleDrivers) {
      final loc = doc.data()['location'] as GeoPoint?;
      if (loc != null) {
        double dist = Geolocator.distanceBetween(request.pickupLocation.latitude, request.pickupLocation.longitude, loc.latitude, loc.longitude);
        if (dist < minDistance) {
          minDistance = dist;
          nearestDriverDoc = doc;
        }
      }
    }

    if (nearestDriverDoc == null) throw 'Could not locate any drivers.';
    final driverData = nearestDriverDoc.data() as Map<String, dynamic>;
    final driverId = nearestDriverDoc.id;
    final driverName = driverData['fullName'] ?? 'Driver';

    final docRef = await _db.collection('ride_requests').add({
      ...request.toMap(),
      'status': 'Accepted',
      'driverId': driverId,
      'driverName': driverName,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await updateDriverStatus(driverId, TaxiStatus.busy);
    await NotificationService.sendNotification(
      userId: driverId,
      title: 'New Ride Request',
      message: 'You have been assigned a new ride from ${request.pickup}.',
      type: 'ride_assigned',
      referenceId: docRef.id,
    );
    return docRef.id;
  }

  // Create Ride Request
  Future<String> createRideRequest(RideRequest request) async {
    final docRef = await _db.collection('ride_requests').add(request.toMap());
    return docRef.id;
  }

  // Accept Ride
  Future<void> acceptRide(String requestId, String driverId, String driverName) async {
    final driverDoc = await _db.collection('drivers').doc(driverId).get();
    final plateNumber = driverDoc.exists ? (driverDoc.get('plateNumber') ?? '') : '';

    final rideDoc = await _db.collection('ride_requests').doc(requestId).get();
    if (!rideDoc.exists) return;
    final userId = rideDoc.get('userId');

    await _db.runTransaction((transaction) async {
      DocumentReference rideRef = _db.collection('ride_requests').doc(requestId);
      transaction.update(rideRef, {
        'status': 'Accepted',
        'driverId': driverId,
        'driverName': driverName,
        'plateNumber': plateNumber,
      });
      await _updateDriverStatusInTransaction(transaction, driverId, TaxiStatus.busy);
    });

    await NotificationService.sendNotification(
      userId: userId,
      title: 'Taxi Arriving!',
      message: '$driverName has accepted your request and is on the way.',
      type: 'taxi_accepted',
      referenceId: requestId,
    );
  }

  // Cancel Ride
  Future<void> cancelRide(String requestId) async {
    await _db.collection('ride_requests').doc(requestId).update({'status': 'Cancelled'});
  }

  // Complete Ride
  Future<void> completeRide(String requestId, String driverId) async {
    await _db.runTransaction((transaction) async {
      transaction.update(_db.collection('ride_requests').doc(requestId), {'status': 'Completed'});
      await _updateDriverStatusInTransaction(transaction, driverId, TaxiStatus.online);
    });
  }

  // Update Driver Status
  Future<void> updateDriverStatus(String driverId, TaxiStatus status) async {
    await _db.runTransaction((transaction) async {
      await _updateDriverStatusInTransaction(transaction, driverId, status);
    });
  }

  Future<void> _updateDriverStatusInTransaction(Transaction transaction, String driverId, TaxiStatus status) async {
    bool isOnline = status == TaxiStatus.online;
    String statusStr = status.toString().split('.').last;

    DocumentReference driverRef = _db.collection('drivers').doc(driverId);
    DocumentSnapshot driverDoc = await transaction.get(driverRef);

    if (driverDoc.exists) {
      bool wasOnline = driverDoc.get('isOnline') ?? false;
      String? oldStationId = driverDoc.get('stationId');

      transaction.update(driverRef, {
        'taxiStatus': statusStr,
        'isOnline': isOnline,
        'lastUpdate': FieldValue.serverTimestamp(),
      });

      if (wasOnline && !isOnline && oldStationId != null) {
        DocumentReference stationRef = _db.collection('taxi_stations').doc(oldStationId);
        transaction.update(stationRef, {'activeTaxiCount': FieldValue.increment(-1), 'updatedAt': FieldValue.serverTimestamp()});
      } else if (!wasOnline && isOnline && oldStationId != null) {
        DocumentReference stationRef = _db.collection('taxi_stations').doc(oldStationId);
        transaction.update(stationRef, {'activeTaxiCount': FieldValue.increment(1), 'updatedAt': FieldValue.serverTimestamp()});
      }
    }
  }

  // Update Live Location and Station
  Future<void> updateDriverLocation(String driverId, Position position, String zone) async {
    final driverRef = _db.collection('drivers').doc(driverId);
    final driverDoc = await driverRef.get();
    String? currentStationId = driverDoc.exists ? driverDoc.get('stationId') : null;

    final stationsSnap = await _db.collection('taxi_stations').where('status', isEqualTo: 'Active').get();
    String? detectedStationId;
    String? detectedStationName;
    double minDistance = 500;

    for (var doc in stationsSnap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (!data.containsKey('location')) continue;
      GeoPoint loc = data['location'];
      double distance = Geolocator.distanceBetween(position.latitude, position.longitude, loc.latitude, loc.longitude);
      if (distance < minDistance) {
        minDistance = distance;
        detectedStationId = doc.id;
        detectedStationName = data['name'] ?? 'Station';
      }
    }

    if (detectedStationId != null && detectedStationId != currentStationId) {
      await moveTaxiBetweenStations(driverId, currentStationId, detectedStationId, detectedStationName!);
    }

    await driverRef.update({
      'location': GeoPoint(position.latitude, position.longitude),
      'heading': position.heading,
      'speed': position.speed,
      'currentZone': zone,
      'lastUpdate': FieldValue.serverTimestamp(),
    });
  }

  // Move Taxi Between Stations
  Future<void> moveTaxiBetweenStations(String driverId, String? oldStationId, String newStationId, String newStationName) async {
    await _db.runTransaction((transaction) async {
      DocumentReference driverRef = _db.collection('drivers').doc(driverId);
      DocumentSnapshot driverDoc = await transaction.get(driverRef);

      if (driverDoc.exists) {
        bool isOnline = driverDoc.get('isOnline') ?? false;

        if (isOnline) {
          if (oldStationId != null) {
            DocumentReference oldStationRef = _db.collection('taxi_stations').doc(oldStationId);
            transaction.update(oldStationRef, {'activeTaxiCount': FieldValue.increment(-1), 'updatedAt': FieldValue.serverTimestamp()});
          }
          DocumentReference newStationRef = _db.collection('taxi_stations').doc(newStationId);
          transaction.update(newStationRef, {'activeTaxiCount': FieldValue.increment(1), 'updatedAt': FieldValue.serverTimestamp()});
        }

        transaction.update(driverRef, {
          'stationId': newStationId,
          'station': newStationName,
          'lastUpdate': FieldValue.serverTimestamp()
        });
      }
    });
  }

  // Taxi Registration (Admin)
  Future<void> registerTaxi(Taxi taxi) async {
    await _db.collection('taxis').doc(taxi.id).set(taxi.toMap());
  }

  // Assign Taxi to Station
  Future<void> assignTaxiToStation(String driverId, String stationId) async {
    final stationDoc = await _db.collection('taxi_stations').doc(stationId).get();
    if (stationDoc.exists) {
      await moveTaxiBetweenStations(driverId, null, stationId, stationDoc.get('name'));
    }
  }

  // Get Taxis/Drivers filtered
  Stream<List<TaxiDriver>> getAllDrivers() => _db.collection('drivers').snapshots().map((s) => s.docs.map((d) => TaxiDriver.fromFirestore(d)).toList());
  Stream<List<TaxiDriver>> getOnlineDrivers() => _db.collection('drivers').where('isOnline', isEqualTo: true).snapshots().map((s) => s.docs.map((d) => TaxiDriver.fromFirestore(d)).toList());
  Stream<List<TaxiDriver>> getBusyDrivers() => _db.collection('drivers').where('taxiStatus', isEqualTo: 'busy').snapshots().map((s) => s.docs.map((d) => TaxiDriver.fromFirestore(d)).toList());
  Stream<List<TaxiDriver>> getOfflineDrivers() => _db.collection('drivers').where('isOnline', isEqualTo: false).snapshots().map((s) => s.docs.map((d) => TaxiDriver.fromFirestore(d)).toList());

  // Stats
  Stream<Map<String, int>> getAdminStats() => getAllDrivers().map((drivers) => {'online': drivers.where((d) => d.isOnline).length, 'offline': drivers.where((d) => !d.isOnline).length, 'busy': drivers.where((d) => d.taxiStatus == TaxiStatus.busy).length});
  Stream<Map<String, dynamic>> getDashboardStatistics() => getAdminStats().map((s) => s as Map<String, dynamic>);

  // More methods
  Future<void> saveStation(TaxiStation station) async => station.id.isEmpty ? await _db.collection('taxi_stations').add(station.toMap()) : await _db.collection('taxi_stations').doc(station.id).set(station.toMap());
  Future<void> deleteStation(String id) async => await _db.collection('taxi_stations').doc(id).delete();
  Stream<RideRequest?> watchRide(String id) => _db.collection('ride_requests').doc(id).snapshots().map((d) => d.exists ? RideRequest.fromFirestore(d) : null);

  Stream<List<RideRequest>> getNearbyRideRequests(String zone) {
    // To avoid composite index on status + timestamp, we filter in memory
    return _db.collection('ride_requests')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs
            .map((d) => RideRequest.fromFirestore(d))
            .where((r) => r.status == 'Pending')
            .toList());
  }
  Future<void> sendSOS(String id, String name, GeoPoint loc) async => await _db.collection('emergency_alerts').add({'type': 'Taxi SOS', 'driverId': id, 'driverName': name, 'location': loc, 'timestamp': FieldValue.serverTimestamp(), 'status': 'Active'});

  // Fix null stationId for existing drivers
  Future<void> fixMissingStationIds() async {
    final snap = await _db.collection('drivers').where('stationId', isNull: true).get();
    final stationsSnap = await _db.collection('taxi_stations').get();
    final stationsMap = {for (var doc in stationsSnap.docs) (doc.data() as Map)['name'] as String? ?? 'Unknown': doc.id};
    for (var doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final name = data['station'] as String? ?? 'Piassa';
      final id = stationsMap[name] ?? (stationsMap.isNotEmpty ? stationsMap.values.first : 'general');
      final status = data['status'] as String? ?? 'pending';
      await doc.reference.update({'stationId': id, if (status == 'approved') 'status': 'APPROVED'});
    }
  }

  // Static Zones
  static const List<Map<String, dynamic>> hawassaZones = [
    {'name': 'Piassa', 'lat': 7.0504, 'lng': 38.4955},
    {'name': 'Menaharia', 'lat': 7.0621, 'lng': 38.4772},
    {'name': 'Tabor', 'lat': 7.0423, 'lng': 38.5085},
    {'name': 'Haik Dar', 'lat': 7.0588, 'lng': 38.4851},
    {'name': 'Addis Ketema', 'lat': 7.0712, 'lng': 38.4655},
    {'name': 'Hawela Tula', 'lat': 7.0315, 'lng': 38.5210},
    {'name': 'Alamura', 'lat': 7.0150, 'lng': 38.4820},
    {'name': 'Menbo', 'lat': 7.0550, 'lng': 38.4800},
    {'name': 'University', 'lat': 7.0450, 'lng': 38.4900},
  ];

  static String detectZone(double lat, double lng) {
    String closest = 'Hawassa';
    double min = double.infinity;
    for (var z in hawassaZones) {
      double d = Geolocator.distanceBetween(lat, lng, z['lat'], z['lng']);
      if (d < min) { min = d; closest = z['name']; }
    }
    return closest;
  }
}
