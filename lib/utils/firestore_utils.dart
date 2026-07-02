import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUtils {
  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      // Try parsing common formats
      return DateTime.tryParse(value);
    }
    return null;
  }

  static DateTime parseDateTimeOrDefault(dynamic value, {DateTime? defaultValue}) {
    return parseDateTime(value) ?? defaultValue ?? DateTime.now();
  }
}
