import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  super_admin,
  old_terminal_admin,
  new_terminal_admin,
  taxi_admin,
  tourism_admin,
  hotel_admin,
  health_admin,
  pharmacy_admin,
  emergency_admin,
  citizen
}

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final UserRole role;
  final String department;
  final DateTime createdAt;
  final DateTime lastLogin;
  final bool isActive;
  final double walletBalance;
  final String membershipNumber;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.department,
    required this.createdAt,
    required this.lastLogin,
    this.isActive = true,
    this.walletBalance = 0.0,
    this.membershipNumber = '',
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.citizen,
      ),
      department: map['department'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (map['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      walletBalance: (map['walletBalance'] ?? 0.0).toDouble(),
      membershipNumber: map['membershipNumber'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role.name,
      'department': department,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
      'isActive': isActive,
      'walletBalance': walletBalance,
      'membershipNumber': membershipNumber,
    };
  }
}
