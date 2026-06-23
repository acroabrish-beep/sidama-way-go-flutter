import 'firestore_service.dart';

class BootService {
  static Future<void> initializeCity() async {
    final fs = FirestoreService();
    await fs.ensureInitialData();
  }
}
