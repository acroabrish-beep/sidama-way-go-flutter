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
      ];
      for (var s in stations) {
        await _db.collection('taxi_stations').add({
          'name': s['name'],
          'location': GeoPoint(s['lat'] as double, s['lng'] as double),
          'capacity': s['capacity'],
          'activeTaxis': 0,
        });
      }
    }
  }

  // Driver Registration
  Future<void> registerDriver(TaxiDriver driver) async {
    await _db.collection('drivers').doc(driver.id).set(driver.toMap());
  }

  // Get Driver details
  Stream<TaxiDriver?> getDriver(String driverId) {
    return _db.collection('drivers').doc(driverId).snapshots().map((doc) {
      if (doc.exists) return TaxiDriver.fromFirestore(doc);
      return null;
    });
  }

  // Update Driver Status
  Future<void> updateDriverStatus(String driverId, TaxiStatus status) async {
    bool isOnline = status == TaxiStatus.online;
    await _db.collection('drivers').doc(driverId).update({
      'taxiStatus': status.toString().split('.').last,
      'isOnline': isOnline,
      'lastUpdate': FieldValue.serverTimestamp(),
    });
  }

  // Update Live Location and Station
  Future<void> updateDriverLocation(String driverId, Position position, String zone) async {
    // Find station ID for the detected zone
    final stationSnap = await _db.collection('taxi_stations').where('name', isEqualTo: zone).limit(1).get();
    String? stationId;
    if (stationSnap.docs.isNotEmpty) {
      stationId = stationSnap.docs.first.id;
    }

    await _db.collection('drivers').doc(driverId).update({
      'location': GeoPoint(position.latitude, position.longitude),
      'currentZone': zone,
      'station': zone, // Map zone to station
      if (stationId != null) 'stationId': stationId,
      'lastUpdate': FieldValue.serverTimestamp(),
    });
  }

  // Fix null stationId for existing drivers
  Future<void> fixMissingStationIds() async {
    final snap = await _db.collection('drivers').where('stationId', isNull: true).get();
    final stationsSnap = await _db.collection('taxi_stations').get();
    final stationsMap = {for (var doc in stationsSnap.docs) doc['name'] as String: doc.id};

    for (var doc in snap.docs) {
      final stationName = doc['station'] as String? ?? 'Piassa';
      final stationId = stationsMap[stationName] ?? (stationsMap.isNotEmpty ? stationsMap.values.first : 'general');
      final currentStatus = doc['status'] as String? ?? 'pending';

      await doc.reference.update({
        'stationId': stationId,
        if (currentStatus == 'approved') 'status': 'APPROVED',
      });
    }
  }

  // Get All Taxi Stations
  Stream<List<TaxiStation>> getTaxiStations() {
    return _db.collection('taxi_stations').snapshots().map((snap) {
      return snap.docs.map((doc) => TaxiStation.fromFirestore(doc)).toList();
    });
  }

  // Active Driver Count for a Station
  Stream<int> getActiveDriverCount(String stationId) {
    return _db.collection('drivers')
        .where('stationId', isEqualTo: stationId)
        .snapshots()
        .map((snap) {
          // Filter in Dart to avoid index requirement
          return snap.docs.where((doc) {
            final data = doc.data();
            return data['status'] == 'APPROVED' && data['isOnline'] == true;
          }).length;
        });
  }

  // Passenger: Find nearby approved online drivers
  Stream<List<TaxiDriver>> getNearbyDrivers(GeoPoint userLoc) {
    return _db.collection('drivers')
        .where('status', isEqualTo: 'APPROVED')
        .where('isOnline', isEqualTo: true)
        .snapshots()
        .map((snap) {
          final drivers = snap.docs.map((doc) => TaxiDriver.fromFirestore(doc)).toList();
          // Sort by distance
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
    // 1. Find nearest driver in the selected station
    // Simplified query to avoid index requirement
    final driversSnap = await _db.collection('drivers')
        .where('stationId', isEqualTo: stationId)
        .get();

    // Filter in Dart
    final eligibleDrivers = driversSnap.docs.where((doc) {
      final data = doc.data();
      return data['status'] == 'APPROVED' &&
             data['isOnline'] == true &&
             data['taxiStatus'] == 'online';
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

    final driverId = nearestDriverDoc.id;
    final driverName = nearestDriverDoc['fullName'];

    // 2. Create ride_request document
    final docRef = await _db.collection('ride_requests').add({
      'userId': request.userId,
      'userName': request.userName,
      'pickup': request.pickup,
      'pickupLocation': request.pickupLocation,
      'destination': request.destination,
      'destinationLocation': request.destinationLocation,
      'fare': request.fare,
      'status': 'Accepted', // Automatically assigned
      'driverId': driverId,
      'driverName': driverName,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 3. Update driver status to busy
    await updateDriverStatus(driverId, TaxiStatus.busy);

    // 4. Notify driver (Logic usually goes here or via cloud functions)
    await NotificationService.sendNotification(
      userId: driverId,
      title: 'New Ride Request',
      message: 'You have been assigned a new ride from ${request.pickup}.',
      type: 'ride_assigned',
      referenceId: docRef.id,
    );

    return docRef.id;
  }

  Stream<List<RideRequest>> getNearbyRideRequests(String zone) {
    return _db.collection('ride_requests')
        .where('status', isEqualTo: 'Pending')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => RideRequest.fromFirestore(doc)).toList());
  }

  Future<void> acceptRide(String requestId, String driverId, String driverName) async {
    final doc = await _db.collection('ride_requests').doc(requestId).get();
    final data = doc.data() as Map<String, dynamic>;
    final userId = data['userId'];

    await _db.collection('ride_requests').doc(requestId).update({
      'status': 'Accepted',
      'driverId': driverId,
      'driverName': driverName,
    });

    // Send notification to user
    await NotificationService.sendNotification(
      userId: userId,
      title: 'Taxi Arriving!',
      message: '$driverName has accepted your request and is on the way.',
      type: 'taxi_accepted',
      referenceId: requestId,
    );

    // Also update driver status to Busy
    await updateDriverStatus(driverId, TaxiStatus.busy);
  }

  // SOS
  Future<void> sendSOS(String driverId, String driverName, GeoPoint location) async {
    await _db.collection('emergency_alerts').add({
      'type': 'Taxi SOS',
      'driverId': driverId,
      'driverName': driverName,
      'location': location,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'Active',
    });
  }

  // Zones in Hawassa
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
    String closestZone = 'Hawassa';
    double minDistance = double.infinity;

    for (var zone in hawassaZones) {
      double distance = Geolocator.distanceBetween(lat, lng, zone['lat'], zone['lng']);
      if (distance < minDistance) {
        minDistance = distance;
        closestZone = zone['name'];
      }
    }
    return closestZone;
  }
}
