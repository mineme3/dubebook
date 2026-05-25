import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/credit_item.dart';
import '../../../core/providers/api_client_provider.dart';
import '../../customers/providers/customer_provider.dart';

/// Family async notifier for credit items per customer
final creditItemsProvider = FutureProvider.family<List<CreditItem>, String>(
  (ref, customerId) async {
    return ref.watch(creditItemRepositoryProvider).fetchForCustomer(customerId);
  },
);

/// Provider for adding a credit item and invalidating related providers
class CreditItemActions {
  final Ref _ref;
  CreditItemActions(this._ref);

  Future<CreditItem> addItem(
      String customerId, CreateCreditItemDto dto) async {
    final repo = _ref.read(creditItemRepositoryProvider);
    final item = await repo.create(customerId, dto);

    // Invalidate the items list and customer summary to reflect new balance
    _ref.invalidate(creditItemsProvider(customerId));
    _ref.invalidate(customerSummaryProvider(customerId));
    _ref.invalidate(customerNotifierProvider);
    return item;
  }

  Future<void> deleteItem(String customerId, String itemId) async {
    final repo = _ref.read(creditItemRepositoryProvider);
    await repo.delete(customerId, itemId);

    _ref.invalidate(creditItemsProvider(customerId));
    _ref.invalidate(customerSummaryProvider(customerId));
    _ref.invalidate(customerNotifierProvider);
  }
}

final creditItemActionsProvider = Provider<CreditItemActions>((ref) {
  return CreditItemActions(ref);
});
