import 'package:dio/dio.dart';
import '../storage/secure_storage_helper.dart';

class JwtInterceptor extends Interceptor {
  JwtInterceptor({required this.onAuthError});
  final Function() onAuthError;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await SecureStorageHelper.instance.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return super.onRequest(options, handler);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await SecureStorageHelper.instance.clearAuthData();
      onAuthError();
    }
    return super.onError(err, handler);
  }
}
