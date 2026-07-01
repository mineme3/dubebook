import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/payment_record.dart';
import '../../../core/providers/api_client_provider.dart';
import '../../customers/providers/customer_provider.dart';
import '../../credits/providers/credit_item_provider.dart';

/// Family async provider for payment history per customer
final paymentHistoryProvider =
    FutureProvider.family<List<PaymentRecord>, String>(
  (ref, customerId) async {
    return ref.watch(paymentRepositoryProvider).fetchForCustomer(customerId);
  },
);

/// Provider for recording payments and cascading invalidation
class PaymentActions {
  final Ref _ref;
  PaymentActions(this._ref);

  Future<PaymentRecord> recordPayment(
      String customerId, CreatePaymentDto dto) async {
    final repo = _ref.read(paymentRepositoryProvider);
    final payment = await repo.create(customerId, dto);

    // Invalidate everything that depends on balance
    _ref.invalidate(paymentHistoryProvider(customerId));
    _ref.invalidate(customerSummaryProvider(customerId));
    _ref.invalidate(customerNotifierProvider);
    return payment;
  }
}

final paymentActionsProvider = Provider<PaymentActions>((ref) {
  return PaymentActions(ref);
});
