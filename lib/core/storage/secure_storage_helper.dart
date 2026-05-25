import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  SecureStorageHelper._();
  static final SecureStorageHelper instance = SecureStorageHelper._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    lOptions: LinuxOptions(),
  );

  static const String _tokenKey = 'jwt_token';
  static const String _ownerKey = 'owner_profile';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveOwnerProfile(String profileJson) async {
    await _storage.write(key: _ownerKey, value: profileJson);
  }

  Future<String?> getOwnerProfile() async {
    return await _storage.read(key: _ownerKey);
  }

  Future<void> clearAuthData() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _ownerKey);
  }
}
