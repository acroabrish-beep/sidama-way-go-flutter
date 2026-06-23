import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? referenceId,
  }) async {
    await _db.collection('user_notifications').add({
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'referenceId': referenceId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
