import 'package:dio/dio.dart';
import '../../../core/models/credit_item.dart';

class CreditItemRepository {
  final Dio _dio;

  CreditItemRepository(this._dio);

  Future<List<CreditItem>> fetchForCustomer(String customerId) async {
    final response = await _dio.get('/customers/$customerId/items');
    final data = response.data as List;
    return data
        .map((i) => CreditItem.fromJson(i as Map<String, dynamic>))
        .toList();
  }

  Future<CreditItem> create(
      String customerId, CreateCreditItemDto dto) async {
    final response =
        await _dio.post('/customers/$customerId/items', data: dto.toJson());
    return CreditItem.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(String customerId, String itemId) async {
    await _dio.delete('/customers/$customerId/items/$itemId');
  }
}
