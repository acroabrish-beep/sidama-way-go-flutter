import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Generic CRUD
  Future<void> addDocument(String collection, Map<String, dynamic> data) {
    return _db.collection(collection).add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) {
    return _db.collection(collection).doc(docId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteDocument(String collection, String docId) {
    return _db.collection(collection).doc(docId).delete();
  }

  Stream<QuerySnapshot> getCollectionStream(String collection, {Query Function(Query)? queryBuilder}) {
    Query query = _db.collection(collection);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return query.snapshots();
  }

  // Specific for Old Terminal
  Stream<QuerySnapshot> getOldTerminalRoutes() => getCollectionStream('old_terminal_routes');
  Stream<QuerySnapshot> getOldTerminalVehicles() => getCollectionStream('old_terminal_vehicles');
  Stream<QuerySnapshot> getOldTerminalDrivers() => getCollectionStream('old_terminal_drivers');

  // Specific for New Terminal
  Stream<QuerySnapshot> getNewTerminalRoutes() => getCollectionStream('new_terminal_routes');

  // Announcements
  Future<void> createAnnouncement(Map<String, dynamic> data) {
    return addDocument('announcements', data);
  }

  Future<int> getCollectionCount(String collectionName) async {
    final snapshot = await _db.collection(collectionName).count().get();
    return snapshot.count ?? 0;
  }

  Future<double> getTotalRevenue() async {
    double total = 0;
    final busBookings = await _db.collection('bookings').get();
    for (var doc in busBookings.docs) {
      total += (doc.data()['fare'] ?? 0).toDouble();
    }
    final taxiBookings = await _db.collection('taxi_bookings').get();
    for (var doc in taxiBookings.docs) {
      total += (doc.data()['fare'] ?? 0).toDouble();
    }
    return total;
  }

  Future<void> ensureInitialData() async {
    // Check if we have any users or routes, if not, could seed here.
    // For now, just a stub as requested.
  }

  Future<void> checkAndSeedTaxi() async {
    try {
      final snapshot = await _db.collection('stations').limit(1).get();
      if (snapshot.docs.isEmpty) {
        final List<Map<String, dynamic>> initialStations = [
          {'name': 'Menaharia Station', 'location': 'Main Road', 'capacity': 50},
          {'name': 'Piassa Station', 'location': 'City Center', 'capacity': 30},
          {'name': 'Tabor Station', 'location': 'Tabor Mountain area', 'capacity': 20},
        ];
        final batch = _db.batch();
        for (var s in initialStations) {
          final docRef = _db.collection('stations').doc();
          batch.set(docRef, {...s, 'createdAt': FieldValue.serverTimestamp()});
        }
        await batch.commit();
      }
    } catch (e) {
      print('Error seeding taxi data: $e');
    }
  }

  Future<void> checkAndSeedTransport() async {
    try {
      final snapshot = await _db.collection('routes').limit(1).get();
      if (snapshot.docs.isEmpty) {
        final List<Map<String, dynamic>> initialRoutes = [
          {'route': 'Hawassa → Shashamane', 'origin': 'Hawassa', 'destination': 'Shashamane', 'fare': 80, 'terminal': 'Hawassa Old Terminal'},
          {'route': 'Hawassa → Addis Ababa', 'origin': 'Hawassa', 'destination': 'Addis Ababa', 'fare': 280, 'terminal': 'Hawassa New Terminal'},
        ];
        final batch = _db.batch();
        for (var r in initialRoutes) {
          final docRef = _db.collection('routes').doc();
          batch.set(docRef, {...r, 'createdAt': FieldValue.serverTimestamp()});
        }
        await batch.commit();
      }
    } catch (e) {
      print('Error seeding transport data: $e');
    }
  }
}
