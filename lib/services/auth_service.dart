import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'audit_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserModel?> getUserData(String uid) async {
    try {
      print('Fetching profile for UID: $uid');
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        print('Profile found for $uid');
        return UserModel.fromMap(doc.data()!, uid);
      } else {
        print('No Firestore document found for UID: $uid in "users" collection.');
      }
    } catch (e) {
      print('Error getting user data for $uid: $e');
    }
    return null;
  }

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      final uid = result.user!.uid;
      print('--- LOGIN SUCCESS ---');
      print('User UID: $uid');
      print('Email: ${result.user!.email}');

      // Use set with merge: true to avoid "document not found" error during update
      await _db.collection('users').doc(uid).set({
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await AuditService.logAction('User Login', details: 'Email: ${result.user!.email}');

      return result;
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> registerUser({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    UserRole role = UserRole.citizen,
    String department = '',
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      UserModel newUser = UserModel(
        uid: result.user!.uid,
        fullName: fullName,
        email: email,
        phone: phone,
        role: role,
        department: department,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        walletBalance: 0.0,
        membershipNumber: 'SWG-${result.user!.uid.substring(0, 8).toUpperCase()}',
      );

      await _db.collection('users').doc(result.user!.uid).set(newUser.toMap());
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }
}
