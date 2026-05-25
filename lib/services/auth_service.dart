import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/customer.dart';
import '../database/database_helper.dart';
import 'mongodb_service.dart';

class AuthService {
  static const String _currentUserEmailKey = "current_user_email";
  static const String _currentUserRoleKey = "current_user_role";
  static const String _currentUserIdKey = "current_user_id";

  static String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // --- REGISTER SYSTEM ---
  static Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String role,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    final passwordHash = hashPassword(password);
    final user = User(
      fullName: fullName,
      email: email.toLowerCase().trim(),
      phone: phone,
      passwordHash: passwordHash,
      role: role,
      securityQuestion: securityQuestion,
      securityAnswer: securityAnswer.toLowerCase().trim(),
    );

    // Save to SQLite
    final id = await DatabaseHelper.instance.insertUser(user);

    // Synchronize to MongoDB online if active
    try {
      await MongoDbService.instance.insertUser(user.toMap());
    } catch (_) {}

    // If role is customer, register as a customer record
    if (role == 'customer') {
      final customer = Customer(
        name: fullName,
        email: email.toLowerCase().trim(),
        phone: phone,
        createdAt: DateTime.now(),
      );
      await DatabaseHelper.instance.insertCustomer(customer);
      try {
        await MongoDbService.instance.insertCustomer(customer.toMap());
      } catch (_) {}
    }

    return id > 0;
  }

  // --- LOGIN SYSTEM ---
  static Future<User?> login(String email, String password) async {
    final cleanEmail = email.toLowerCase().trim();
    final passwordHash = hashPassword(password);

    // 1. Try online verification with MongoDB
    try {
      final mongoUserDoc = await MongoDbService.instance.findUserByEmail(cleanEmail);
      if (mongoUserDoc != null) {
        final mongoUser = User.fromJson(mongoUserDoc);
        if (mongoUser.passwordHash == passwordHash) {
          // Sync to local SQLite db so they can log in offline next time
          await DatabaseHelper.instance.insertUser(mongoUser);
          final localUser = await DatabaseHelper.instance.getUserByEmail(cleanEmail);
          if (localUser != null) {
            await _saveSession(localUser.id!, localUser.email, localUser.role);
            return localUser;
          }
        }
      }
    } catch (_) {}

    // 2. Offline fallback to SQLite
    final localUser = await DatabaseHelper.instance.getUserByEmail(cleanEmail);
    if (localUser != null && localUser.passwordHash == passwordHash) {
      await _saveSession(localUser.id!, localUser.email, localUser.role);
      return localUser;
    }

    return null;
  }

  // --- FORGOT & RESET PASSWORD FLOW ---
  static Future<bool> resetPassword({
    required String email,
    required String securityAnswer,
    required String newPassword,
  }) async {
    final cleanEmail = email.toLowerCase().trim();
    final cleanAnswer = securityAnswer.toLowerCase().trim();
    final newHash = hashPassword(newPassword);

    // Check MongoDB first
    try {
      final mongoUserDoc = await MongoDbService.instance.findUserByEmail(cleanEmail);
      if (mongoUserDoc != null) {
        final mongoUser = User.fromJson(mongoUserDoc);
        if (mongoUser.securityAnswer == cleanAnswer) {
          await MongoDbService.instance.updateUserPassword(cleanEmail, newHash);
          // Sync locally
          final localUser = await DatabaseHelper.instance.getUserByEmail(cleanEmail);
          if (localUser != null) {
            await DatabaseHelper.instance.updateUserPassword(localUser.id!, newHash);
          }
          return true;
        }
      }
    } catch (_) {}

    // Check SQLite local DB
    final localUser = await DatabaseHelper.instance.getUserByEmail(cleanEmail);
    if (localUser != null && localUser.securityAnswer == cleanAnswer) {
      await DatabaseHelper.instance.updateUserPassword(localUser.id!, newHash);
      return true;
    }

    return false;
  }

  // --- SESSION MANAGERS ---
  static Future<void> _saveSession(int id, String email, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentUserIdKey, id);
    await prefs.setString(_currentUserEmailKey, email);
    await prefs.setString(_currentUserRoleKey, role);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserIdKey);
    await prefs.remove(_currentUserEmailKey);
    await prefs.remove(_currentUserRoleKey);
  }

  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_currentUserEmailKey);
    if (email == null) return null;
    return await DatabaseHelper.instance.getUserByEmail(email);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_currentUserEmailKey);
  }
}
