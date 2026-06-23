import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  superAdmin,
  terminalAdmin,
  taxiAdmin,
  tourismAdmin,
  hotelAdmin,
  healthcareAdmin,
  emergencyAdmin,
  businessAdmin,
  user
}

class AdminProfile {
  final String uid;
  final String email;
  final UserRole role;
  final String? assignedServiceId; // e.g., "old_terminal", "hospital_001"
  final String name;

  AdminProfile({
    required this.uid,
    required this.email,
    required this.role,
    this.assignedServiceId,
    required this.name,
  });

  factory AdminProfile.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AdminProfile(
      uid: doc.id,
      email: data['email'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString() == data['role'],
        orElse: () => UserRole.user,
      ),
      assignedServiceId: data['assignedServiceId'],
      name: data['name'] ?? '',
    );
  }
}

class CityAnalytics {
  final double totalRevenue;
  final int activeUsers;
  final int activeVehicles;
  final int emergencyRequestsToday;
  final Map<String, dynamic> servicePerformance; // Map of service names to scores

  CityAnalytics({
    required this.totalRevenue,
    required this.activeUsers,
    required this.activeVehicles,
    required this.emergencyRequestsToday,
    required this.servicePerformance,
  });
}
