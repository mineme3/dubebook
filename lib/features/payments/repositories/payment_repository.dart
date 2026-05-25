import 'package:dio/dio.dart';
import '../../../core/models/payment_record.dart';

class PaymentRepository {
  final Dio _dio;

  PaymentRepository(this._dio);

  Future<List<PaymentRecord>> fetchForCustomer(String customerId) async {
    final response = await _dio.get('/customers/$customerId/payments');
    final data = response.data as List;
    return data
        .map((p) => PaymentRecord.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  Future<PaymentRecord> create(
      String customerId, CreatePaymentDto dto) async {
    final response = await _dio.post(
      '/customers/$customerId/payments',
      data: dto.toJson(),
    );
    return PaymentRecord.fromJson(response.data as Map<String, dynamic>);
  }
}
