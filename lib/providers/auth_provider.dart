import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _userModel;
  bool _isLoading = true;

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _userModel != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((User? user) async {
      if (user == null) {
        _userModel = null;
      } else {
        _userModel = await _authService.getUserData(user.uid);
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      // MOCK TEST BYPASS LOGIC
      final mockUser = _getMockUser(email, password);
      if (mockUser != null) {
        _userModel = mockUser;
        print('--- MOCK LOGIN SUCCESS ---');
        print('Mock User: ${mockUser.fullName} (${mockUser.role.name})');
        return;
      }

      final result = await _authService.signIn(email, password);
      if (result?.user != null) {
        // Manually fetch and set user model immediately to avoid race conditions
        _userModel = await _authService.getUserData(result!.user!.uid);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  UserModel? _getMockUser(String email, String password) {
    if (password != 'password123') return null;

    UserRole? role;
    String name = "";

    switch (email.toLowerCase()) {
      case 'admin@sidamawaygo.com':
        role = UserRole.super_admin;
        name = "Super Admin (Mock)";
        break;
      case 'newterminal@sidamawaygo.com':
        role = UserRole.new_terminal_admin;
        name = "New Terminal Admin (Mock)";
        break;
      case 'oldterminal@sidamawaygo.com':
        role = UserRole.old_terminal_admin;
        name = "Old Terminal Admin (Mock)";
        break;
      case 'taxi@sidamawaygo.com':
        role = UserRole.taxi_admin;
        name = "Taxi Admin (Mock)";
        break;
      case 'tourism@sidamawaygo.com':
        role = UserRole.tourism_admin;
        name = "Tourism Admin (Mock)";
        break;
      case 'hotel@sidamawaygo.com':
        role = UserRole.hotel_admin;
        name = "Hotel Admin (Mock)";
        break;
      case 'health@sidamawaygo.com':
        role = UserRole.health_admin;
        name = "Healthcare Admin (Mock)";
        break;
      case 'pharmacy@sidamawaygo.com':
        role = UserRole.pharmacy_admin;
        name = "Pharmacy Admin (Mock)";
        break;
      case 'emergency@sidamawaygo.com':
        role = UserRole.emergency_admin;
        name = "Emergency Admin (Mock)";
        break;
    }

    if (role != null) {
      return UserModel(
        uid: 'mock-uid-${role.name}',
        fullName: name,
        email: email,
        phone: '000-000-0000',
        role: role,
        department: role.name,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        isActive: true,
      );
    }
    return null;
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _userModel = null;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    if (_userModel != null) {
      _userModel = await _authService.getUserData(_userModel!.uid);
      notifyListeners();
    }
  }

  Future<void> registerUser({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    UserRole role = UserRole.citizen,
    String department = '',
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.registerUser(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        role: role,
        department: department,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
