import 'package:dio/dio.dart';
import '../../../core/models/customer.dart';
import '../../../core/models/credit_item.dart';
import '../../../core/models/credit_session.dart';
import '../../../core/models/payment_record.dart';

class CustomerRepository {
  final Dio _dio;

  CustomerRepository(this._dio);

  Future<List<Customer>> fetchAll({String? shopId}) async {
    final response = await _dio.get(
      '/customers',
      queryParameters: shopId != null ? {'shopId': shopId} : null,
    );
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

  /// Get full financial summary: customer + sessions + payments
  Future<CustomerSummary> getSummary(String id) async {
    final response = await _dio.get('/customers/$id/summary');
    final data = response.data as Map<String, dynamic>;

    final customer =
        Customer.fromJson(data['account'] as Map<String, dynamic>);

    final sessions = (data['sessions'] as List)
        .map((s) => CreditSession.fromJson(s as Map<String, dynamic>))
        .toList();

    final payments = (data['paymentHistory'] as List)
        .map((p) => PaymentRecord.fromJson(p as Map<String, dynamic>))
        .toList();

    return CustomerSummary(
      customer: customer,
      sessions: sessions,
      paymentHistory: payments,
    );
  }

  /// Fetch customer's dashboard: total aggregate debt + all linked shop accounts
  Future<({double totalAggregateDebt, List<Customer> linkedAccounts})> getMyDashboard() async {
    final response = await _dio.get('/customers/my-dashboard');
    final data = response.data as Map<String, dynamic>;

    final total = (data['totalAggregateDebt'] as num?)?.toDouble() ?? 0.0;
    final accounts = (data['linkedAccounts'] as List)
        .map((a) => Customer.fromJson(a as Map<String, dynamic>))
        .toList();

    return (
      totalAggregateDebt: total,
      linkedAccounts: accounts,
    );
  }
}

/// Composite summary containing customer details + sessions + payment history
class CustomerSummary {
  final Customer customer;
  final List<CreditSession> sessions;
  final List<PaymentRecord> paymentHistory;

  const CustomerSummary({
    required this.customer,
    required this.sessions,
    required this.paymentHistory,
  });

  bool get isOverdue => sessions.any((s) => s.isOverdue);

  int get overdueSessionCount => sessions.where((s) => s.isOverdue).length;

  int get activeSessionCount => sessions.where((s) => !s.isPaid).length;
}

class CustomerSelfSummary {
  final Customer customer;
  final List<CreditItem> creditItems;
  final List<PaymentRecord> paymentHistory;
  final String shopName;
  final String shopPhone;

  const CustomerSelfSummary({
    required this.customer,
    required this.creditItems,
    required this.paymentHistory,
    required this.shopName,
    required this.shopPhone,
  });
}
