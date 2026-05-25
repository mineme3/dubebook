import 'package:flutter/material.dart';
import '../models/user.dart';
import 'auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  Future<bool> checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await AuthService.getCurrentUser();
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await AuthService.login(email, password);
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return user != null;
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String role,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await AuthService.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        role: role,
        securityQuestion: securityQuestion,
        securityAnswer: securityAnswer,
      );
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String securityAnswer,
    required String newPassword,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await AuthService.resetPassword(
        email: email,
        securityAnswer: securityAnswer,
        newPassword: newPassword,
      );
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _currentUser = null;
    notifyListeners();
  }
}
