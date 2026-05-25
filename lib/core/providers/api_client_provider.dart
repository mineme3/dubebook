import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../network/api_client.dart';
import '../../features/auth/repositories/auth_repository.dart';
import '../../features/customers/repositories/customer_repository.dart';
import '../../features/credits/repositories/credit_item_repository.dart';
import '../../features/payments/repositories/payment_repository.dart';

/// Callback to trigger when auth errors (401) occur.
/// Set by the router/app layer to redirect to login.
typedef AuthErrorCallback = void Function();

/// Holds the global auth error callback, set during app initialization.
AuthErrorCallback? globalAuthErrorCallback;

/// Core Dio instance with base URL and JWT interceptor
final dioProvider = Provider<Dio>((ref) {
  String baseUrl = 'http://localhost:8080';
  try {
    baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
  } catch (_) {
    // Falls back if dotenv is not initialized yet
  }
  
  final client = ApiClient(
    baseUrl: baseUrl,
    onAuthError: () {
      globalAuthErrorCallback?.call();
    },
  );
  return client.dio;
});

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

/// Customer repository provider
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository(ref.watch(dioProvider));
});

/// Credit item repository provider
final creditItemRepositoryProvider = Provider<CreditItemRepository>((ref) {
  return CreditItemRepository(ref.watch(dioProvider));
});

/// Payment repository provider
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(ref.watch(dioProvider));
});
