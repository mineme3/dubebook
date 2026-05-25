import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/customer.dart';
import '../../../core/providers/api_client_provider.dart';
import '../repositories/customer_repository.dart';

/// Async notifier for the customer list
class CustomerNotifier extends AsyncNotifier<List<Customer>> {
  @override
  Future<List<Customer>> build() async {
    return ref.watch(customerRepositoryProvider).fetchAll();
  }

  Future<void> addCustomer(CreateCustomerDto dto) async {
    final repo = ref.read(customerRepositoryProvider);
    await repo.create(dto);
    ref.invalidateSelf();
    await future; // wait for rebuild
  }

  Future<void> updateCustomer(String id, UpdateCustomerDto dto) async {
    final repo = ref.read(customerRepositoryProvider);
    await repo.update(id, dto);
    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteCustomer(String id) async {
    final repo = ref.read(customerRepositoryProvider);
    await repo.delete(id);
    ref.invalidateSelf();
    await future;
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
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
