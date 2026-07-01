import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/owner.dart';
import '../../features/auth/repositories/auth_repository.dart';
import 'api_client_provider.dart';

/// Represents the current authentication state
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final Owner? owner;
  final String? error;

  const AuthState({
    required this.status,
    this.owner,
    this.error,
  });

  const AuthState.unknown()
      : status = AuthStatus.unknown,
        owner = null,
        error = null;

  const AuthState.authenticated(this.owner)
      : status = AuthStatus.authenticated,
        error = null;

  const AuthState.unauthenticated([this.error])
      : status = AuthStatus.unauthenticated,
        owner = null;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.unknown;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState.unknown()) {
    checkAuth();
  }

  Future<void> checkAuth() async {
    try {
      final owner = await _repo.checkAuth();
      if (owner != null) {
        state = AuthState.authenticated(owner);
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (_) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<bool> login({
    String? email,
    String? username,
    required String password,
  }) async {
    try {
      state = const AuthState.unknown(); // loading
      final result = await _repo.login(
        email: email,
        username: username,
        password: password,
      );
      state = AuthState.authenticated(result.owner);
      return true;
    } catch (e) {
      state = AuthState.unauthenticated(_extractErrorMessage(e, 'Login failed'));
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String shopName,
    String role = 'SHOP_OWNER',
  }) async {
    try {
      state = const AuthState.unknown(); // loading
      await _repo.register(
        username: username,
        fullName: fullName,
        phone: phone,
        email: email,
        password: password,
        shopName: shopName,
        role: role,
      );
      // After register + auto-login, check auth to load owner
      await checkAuth();
      return true;
    } catch (e) {
      state = AuthState.unauthenticated(_extractErrorMessage(e, 'Registration failed'));
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState.unauthenticated();
  }

  Future<bool> updateProfile({
    required String fullName,
    required String phone,
    required String email,
  }) async {
    try {
      final updated = await _repo.updateProfile(
        fullName: fullName,
        phone: phone,
        email: email,
      );
      state = AuthState.authenticated(updated);
      return true;
    } catch (e) {
      state = AuthState.authenticated(state.owner); // keep state but don't crash
      rethrow;
    }
  }

  /// Extracts a user-friendly error message from Dio or generic exceptions.
  String _extractErrorMessage(Object e, String fallback) {
    // Print the full error to the debug console for developers to diagnose
    print('Dubebook Auth Error: $e');
    if (e is DioException) {
      if (e.error != null) {
        print('Dubebook Auth Nested Error: ${e.error}');
      }
      // Try to get the server's error message from the response body
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('detail')) {
          return data['detail'].toString();
        }
        if (data.containsKey('error')) {
          return data['error'] as String;
        }
      }
      // Handle common Dio error types
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. Please check your network.';
        case DioExceptionType.connectionError:
          return 'Cannot reach server: ${e.error ?? e.message}';
        default:
          if (e.error != null && e.error.toString().contains('SocketException')) {
            return 'Network unreachable: Make sure phone is on the same WiFi network and firewall is open.';
          }
          return '$fallback: ${e.message ?? e.toString()}';
      }
    }
    return '$fallback: ${e.toString()}';
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});
