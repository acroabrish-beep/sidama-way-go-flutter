import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/city_os_models.dart';

class AnalyticsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getCityOverview() async {
    final userCount = await _getCount(CityOSCollection.users);
    final taxiCount = await _getCount(CityOSCollection.taxis);
    final emergencyCount = await _getCount(CityOSCollection.emergencyRequests);
    final ticketCount = await _getCount(CityOSCollection.tickets);

    double revenue = 0;
    final ticketDocs = await _db.collection(CityOSCollection.tickets).get();
    for (var d in ticketDocs.docs) {
      revenue += (d.data()['fare'] ?? 0).toDouble();
    }

    return {
      'users': userCount,
      'taxis': taxiCount,
      'emergencies': emergencyCount,
      'tickets': ticketCount,
      'revenue': revenue,
    };
  }

  Future<int> _getCount(String collection) async {
    final snap = await _db.collection(collection).count().get();
    return snap.count ?? 0;
  }

  Stream<Map<String, dynamic>> cityStatsStream() {
    // For production, we aggregate real data. In high-scale, use Cloud Functions to update the 'analytics/city_stats' doc.
    return _db.collection('analytics').doc('city_stats').snapshots().map((doc) {
      if (doc.exists) return doc.data()!;
      return {
        'users': 0,
        'taxis': 0,
        'emergencies': 0,
        'tickets': 0,
        'revenue': 0.0,
      };
    });
  }
}
