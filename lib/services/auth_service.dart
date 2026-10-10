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
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, uid);
      }
    } catch (e) {
      print('Error getting user data for $uid: $e');
    }
    return null;
  }

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = result.user!.uid;

      await _db.collection('users').doc(uid).set({
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await AuditService.logAction(
        'User Login',
        details: 'Email: ${result.user!.email}',
      );

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
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Self-registration is always a citizen account.
      // Privileged roles must be provisioned by an authorized administrator.
      final uid = result.user!.uid;
      final newUser = UserModel(
        uid: uid,
        fullName: fullName,
        email: email,
        phone: phone,
        role: UserRole.citizen,
        department: '',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        walletBalance: 0.0,
        membershipNumber: 'SWG-${uid.substring(0, 8).toUpperCase()}',
      );

      await _db.collection('users').doc(uid).set(newUser.toMap());
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }
}
