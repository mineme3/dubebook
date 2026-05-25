import 'package:dio/dio.dart';
import '../../../core/models/customer.dart';
import '../../../core/models/credit_item.dart';
import '../../../core/models/payment_record.dart';

class CustomerRepository {
  final Dio _dio;

  CustomerRepository(this._dio);

  Future<List<Customer>> fetchAll() async {
    final response = await _dio.get('/customers');
    final data = response.data as List;
    return data
        .map((c) => Customer.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  Future<Customer> create(CreateCustomerDto dto) async {
    final response = await _dio.post('/customers', data: dto.toJson());
    return Customer.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Customer> getById(String id) async {
    final response = await _dio.get('/customers/$id');
    return Customer.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Customer> update(String id, UpdateCustomerDto dto) async {
    final response = await _dio.patch('/customers/$id', data: dto.toJson());
    return Customer.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _dio.delete('/customers/$id');
  }

  /// Get full financial summary: customer + items + payments
  Future<CustomerSummary> getSummary(String id) async {
    final response = await _dio.get('/customers/$id/summary');
    final data = response.data as Map<String, dynamic>;

    final customer =
        Customer.fromJson(data['customer'] as Map<String, dynamic>);

    final items = (data['creditItems'] as List)
        .map((i) => CreditItem.fromJson(i as Map<String, dynamic>))
        .toList();

    final payments = (data['paymentHistory'] as List)
        .map((p) => PaymentRecord.fromJson(p as Map<String, dynamic>))
        .toList();

    return CustomerSummary(
      customer: customer,
      creditItems: items,
      paymentHistory: payments,
    );
  }
}

/// Composite summary containing customer details + items + payment history
class CustomerSummary {
  final Customer customer;
  final List<CreditItem> creditItems;
  final List<PaymentRecord> paymentHistory;

  const CustomerSummary({
    required this.customer,
    required this.creditItems,
    required this.paymentHistory,
  });

  int get overdueItemCount =>
      creditItems.where((i) => i.isOverdue).length;

  int get upcomingItemCount =>
      creditItems.where((i) => i.isUpcoming).length;

  int get unpaidItemCount =>
      creditItems.where((i) => !i.isPaid).length;
}
