import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mobility_models.dart';

class MobilityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Intercity Bus Methods
  Future<List<BusRoute>> getBusRoutes(String terminalId) async {
    var snapshot = await _db
        .collection('bus_routes')
        .where('terminalId', isEqualTo: terminalId)
        .get();
    return snapshot.docs.map((doc) => BusRoute.fromFirestore(doc)).toList();
  }

  Future<String> bookTicket(Ticket ticket) async {
    var docRef = await _db.collection('tickets').add(ticket.toMap());
    return docRef.id;
  }

  Stream<List<Ticket>> getUserTickets(String userId) {
    return _db
        .collection('tickets')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Ticket.fromFirestore(doc)).toList());
  }

  // Taxi Methods
  Future<List<TaxiRoute>> getTaxiRoutes() async {
    var snapshot = await _db.collection('taxi_routes').get();
    return snapshot.docs.map((doc) => TaxiRoute.fromFirestore(doc)).toList();
  }

  Stream<List<TaxiQueue>> getTaxiQueue() {
    return _db
        .collection('queues')
        .orderBy('position')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => TaxiQueue.fromFirestore(doc)).toList());
  }

  Future<void> joinTaxiQueue(String taxiId, String plateNumber) async {
    var snapshot = await _db.collection('queues').get();
    int nextPosition = snapshot.docs.length + 1;
    await _db.collection('queues').doc(taxiId).set({
      'plateNumber': plateNumber,
      'position': nextPosition,
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }

  // Admin Methods
  Future<void> verifyTicket(String ticketId) async {
    await _db.collection('tickets').doc(ticketId).update({'isScanned': true});
  }

  Stream<Map<String, dynamic>> getCityStats() {
    return _db.collection('city_stats').doc('current').snapshots().map((doc) => doc.data() ?? {});
  }
}
