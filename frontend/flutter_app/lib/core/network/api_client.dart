import 'package:dio/dio.dart';
import 'jwt_interceptor.dart';

class ApiClient {
  ApiClient({required String baseUrl, required Function() onAuthError}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    )..interceptors.addAll([
        JwtInterceptor(onAuthError: onAuthError),
      ]);
  }

  late final Dio _dio;

  Dio get dio => _dio;
}
