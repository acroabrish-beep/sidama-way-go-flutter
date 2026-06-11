import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/smart_city_models.dart';

class SmartCityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Authentication & Roles
  Future<CityUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _db.collection('users').doc(user.uid).get();
    return CityUser.fromFirestore(doc);
  }

  // INTERCITY TERMINAL
  Stream<List<TerminalBus>> getBuses(String terminalId) {
    return _db.collection('buses')
      .where('terminalId', isEqualTo: terminalId)
      .where('status', isEqualTo: 'ready')
      .snapshots()
      .map((snap) => snap.docs.map((doc) => TerminalBus.fromFirestore(doc)).toList());
  }

  Future<void> bookBusTicket(BusTerminalTicket ticket) async {
    await _db.collection('tickets').add({
      'passengerName': ticket.passengerName,
      'userId': _auth.currentUser?.uid,
      'route': ticket.route,
      'busId': ticket.busId,
      'seatNumber': ticket.seatNumber,
      'fare': ticket.fare,
      'paymentStatus': 'paid',
      'travelDate': ticket.travelDate,
      'verificationCode': ticket.verificationCode,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update bus occupancy
    await _db.collection('buses').doc(ticket.busId).update({
      'occupiedSeats': FieldValue.arrayUnion([ticket.seatNumber])
    });
  }

  // EMERGENCY SERVICES
  Future<void> requestEmergency(String type, GeoPoint location) async {
    await _db.collection('emergency_requests').add({
      'userId': _auth.currentUser?.uid,
      'type': type,
      'location': location,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // TAXI QUEUE
  Future<void> joinTaxiQueue(String taxiId, String plateNumber) async {
    final queueSnap = await _db.collection('queues').orderBy('position', descending: true).limit(1).get();
    int lastPos = 0;
    if (queueSnap.docs.isNotEmpty) {
      lastPos = queueSnap.docs.first.data()['position'] ?? 0;
    }

    await _db.collection('queues').doc(taxiId).set({
      'plateNumber': plateNumber,
      'position': lastPos + 1,
      'joinedAt': FieldValue.serverTimestamp(),
      'status': 'waiting',
    });
  }

  // TOURISM
  Stream<List<TouristPlace>> getTouristPlaces() {
    return _db.collection('tourism_places').snapshots()
      .map((snap) => snap.docs.map((doc) => TouristPlace.fromFirestore(doc)).toList());
  }

  // ANNOUNCEMENTS
  Stream<List<Map<String, dynamic>>> getAnnouncements() {
    return _db.collection('announcements').orderBy('createdAt', descending: true).snapshots()
      .map((snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }
}
