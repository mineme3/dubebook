import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/customer.dart';
import '../../../core/providers/api_client_provider.dart';
import '../../../core/providers/shop_provider.dart';
import '../repositories/customer_repository.dart';

/// Async notifier for the customer list
class CustomerNotifier extends AsyncNotifier<List<Customer>> {
  @override
  Future<List<Customer>> build() async {
    final selectedShop = ref.watch(selectedShopProvider);
    if (selectedShop == null) {
      return [];
    }
    return ref.watch(customerRepositoryProvider).fetchAll(shopId: selectedShop.id);
  }

  Future<Customer> addCustomer(CreateCustomerDto dto) async {
    final repo = ref.read(customerRepositoryProvider);
    final created = await repo.create(dto);
    ref.invalidateSelf();
    ref.invalidate(customerDashboardProvider);
    await future; // wait for rebuild
    return created;
  }

  Future<void> updateCustomer(String id, UpdateCustomerDto dto) async {
    final repo = ref.read(customerRepositoryProvider);
    await repo.update(id, dto);
    ref.invalidateSelf();
    ref.invalidate(customerDashboardProvider);
    ref.invalidate(customerSummaryProvider(id));
    await future;
  }

  Future<void> deleteCustomer(String id) async {
    final repo = ref.read(customerRepositoryProvider);
    await repo.delete(id);
    ref.invalidateSelf();
    ref.invalidate(customerDashboardProvider);
    ref.invalidate(customerSummaryProvider(id));
    await future;
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    ref.invalidate(customerDashboardProvider);
    await future;
  }
}

final customerNotifierProvider =
    AsyncNotifierProvider<CustomerNotifier, List<Customer>>(
  CustomerNotifier.new,
);

/// Provider for a single customer's full financial summary
final customerSummaryProvider =
    FutureProvider.family<CustomerSummary, String>((ref, customerId) async {
  return ref.watch(customerRepositoryProvider).getSummary(customerId);
});

/// Provider for customer's aggregate dashboard (across all shops)
final customerDashboardProvider =
    FutureProvider<({double totalAggregateDebt, List<Customer> linkedAccounts})>((ref) async {
  return ref.watch(customerRepositoryProvider).getMyDashboard();
});
