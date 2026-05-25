import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/models/owner.dart';
import '../../../core/storage/secure_storage_helper.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<({String token, Owner owner})> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    final data = response.data as Map<String, dynamic>;
    final token = data['token'] as String;
    final ownerData = data['owner'] as Map<String, dynamic>;

    // Store auth data securely
    await SecureStorageHelper.instance.saveToken(token);
    await SecureStorageHelper.instance
        .saveOwnerProfile(jsonEncode(ownerData));

    return (
      token: token,
      owner: Owner.fromJson(ownerData),
    );
  }

  Future<({String token, String ownerId})> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String shopName,
    String? telegramChatId,
  }) async {
    final response = await _dio.post(
      '/auth/register',
      data: {
        'fullName': fullName,
        'phone': phone,
        'email': email,
        'password': password,
        'shopName': shopName,
        'telegramChatId': telegramChatId,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final ownerId = data['ownerId'] as String;

    // After registration, auto-login to get token
    final loginResult = await login(email: email, password: password);
    return (token: loginResult.token, ownerId: ownerId);
  }

  Future<String> refreshToken(String currentToken) async {
    final response = await _dio.post(
      '/auth/refresh',
      data: {'token': currentToken},
    );

    final data = response.data as Map<String, dynamic>;
    final newToken = data['token'] as String;
    await SecureStorageHelper.instance.saveToken(newToken);
    return newToken;
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {
      // Best-effort — even if server call fails, clear local data
    }
    await SecureStorageHelper.instance.clearAuthData();
  }

  /// Check if a valid token exists in secure storage
  Future<Owner?> checkAuth() async {
    final token = await SecureStorageHelper.instance.getToken();
    if (token == null) return null;

    final profileJson = await SecureStorageHelper.instance.getOwnerProfile();
    if (profileJson == null) return null;

    try {
      return Owner.fromJson(jsonDecode(profileJson) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
