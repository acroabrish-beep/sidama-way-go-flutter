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
      final result = await _authService.signIn(email, password);
      if (result?.user != null) {
        _userModel = await _authService.getUserData(result!.user!.uid);
      }
      if (_userModel == null) {
        await _authService.signOut();
        throw StateError(
          'Your account is authenticated, but no active Sidama Way Go profile was found.',
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.registerUser(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
