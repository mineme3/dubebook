import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/credit_session.dart';
import '../../../core/models/credit_item.dart';
import '../../../core/providers/api_client_provider.dart';
import '../../customers/providers/customer_provider.dart';

/// Provider for adding a credit session and invalidating related providers
class CreditItemActions {
  final Ref _ref;
  CreditItemActions(this._ref);

  Future<CreditSession> addSession(
      String customerId, CreateCreditSessionDto dto) async {
    final repo = _ref.read(creditItemRepositoryProvider);
    final session = await repo.createSession(customerId, dto);

    // Invalidate the customer summary to reflect new balance and sessions
    _ref.invalidate(customerSummaryProvider(customerId));
    _ref.invalidate(customerNotifierProvider);
    return session;
  }

  Future<void> cancelSession(String customerId, String sessionId) async {
    final repo = _ref.read(creditItemRepositoryProvider);
    await repo.cancelSession(sessionId);

    _ref.invalidate(customerSummaryProvider(customerId));
    _ref.invalidate(customerNotifierProvider);
  }

  Future<CreditItem> addItemToSession(
      String customerId, String sessionId, CreateCreditItemDto itemDto) async {
    final repo = _ref.read(creditItemRepositoryProvider);
    final item = await repo.addItemToSession(sessionId, itemDto);

    _ref.invalidate(customerSummaryProvider(customerId));
    _ref.invalidate(customerNotifierProvider);
    return item;
  }

  Future<CreditSession> updateSessionDeadline(
    String customerId,
    String sessionId, {
    required DateTime deadline,
    required Map<String, int> ethiopianDeadline,
  }) async {
    final repo = _ref.read(creditItemRepositoryProvider);
    final session = await repo.updateSessionDeadline(
      sessionId,
      deadline: deadline,
      ethiopianDeadline: ethiopianDeadline,
    );

    _ref.invalidate(customerSummaryProvider(customerId));
    _ref.invalidate(customerNotifierProvider);
    return session;
  }
}

final creditItemActionsProvider = Provider<CreditItemActions>((ref) {
  return CreditItemActions(ref);
});