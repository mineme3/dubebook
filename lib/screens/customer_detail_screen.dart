import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/models/customer.dart';
import '../core/models/credit_item.dart';
import '../core/models/payment_record.dart';
import '../features/customers/providers/customer_provider.dart';
import '../features/customers/repositories/customer_repository.dart';
import '../features/credits/providers/credit_item_provider.dart';
import '../shared/widgets/balance_summary_widget.dart';
import '../shared/widgets/credit_item_card.dart';
import '../shared/widgets/payment_card.dart';
import '../shared/widgets/confirm_dialog.dart';
import '../utils/theme.dart';

class CustomerDetailScreen extends ConsumerStatefulWidget {
  final String customerId;
  const CustomerDetailScreen({super.key, required this.customerId});
  @override
  ConsumerState<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  String _friendlyError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data.containsKey('error')) {
        return data['error'] as String;
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'Connection timed out';
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'Cannot reach server';
      }
    }
    return 'Something went wrong';
  }

  Future<void> _deleteItem(CreditItem item) async {
    final ok = await showConfirmDialog(
      context: context, title: 'Delete Credit Item',
      message: 'Delete "${item.itemName}"? This will recalculate the balance.',
      confirmText: 'Delete', isDestructive: true,
    );
    if (!ok) return;
    try {
      await ref.read(creditItemActionsProvider).deleteItem(widget.customerId, item.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: ${_friendlyError(e)}'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  Future<void> _deleteCustomer() async {
    final ok = await showConfirmDialog(
      context: context, title: 'Delete Customer',
      message: 'Permanently delete this customer and all their credit/payment records?',
      confirmText: 'Delete', isDestructive: true,
    );
    if (!ok) return;
    try {
      await ref.read(customerNotifierProvider.notifier).deleteCustomer(widget.customerId);
      if (mounted) context.go('/dashboard');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: ${_friendlyError(e)}'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(customerSummaryProvider(widget.customerId));
    final locale = Localizations.localeOf(context).languageCode;

    return summaryAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(title: const Text('LOADING...')),
        body: const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(title: const Text('ERROR')),
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.error),
          const SizedBox(height: 12),
          Text('$e', style: const TextStyle(color: AppTheme.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () => ref.invalidate(customerSummaryProvider(widget.customerId)), child: const Text('Retry')),
        ])),
      ),
      data: (summary) => _buildDetail(summary, locale),
    );
  }

  Widget _buildDetail(CustomerSummary summary, String locale) {
    final c = summary.customer;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(c.fullName.toUpperCase()),
        actions: [
          IconButton(icon: const Icon(Icons.delete_sweep_rounded, color: AppTheme.error), onPressed: _deleteCustomer),
        ],
      ),
      body: Column(children: [
        // Balance summary
        BalanceSummaryWidget(
          totalDebt: c.totalDebt, totalPaid: c.totalPaid,
          outstandingBalance: c.outstandingBalance, status: c.status,
        ),
        // Customer info chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(children: [
            _infoChip(Icons.phone_outlined, c.phone),
            if (c.telegramUsername.isNotEmpty) ...[
              const SizedBox(width: 8),
              _infoChip(Icons.telegram_rounded, '@${c.telegramUsername}'),
            ],
          ]),
        ),
        // Tab bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: AppTheme.surface, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.textSecondary.withOpacity(0.1)),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryBlue,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
            tabs: [
              Tab(text: 'CREDITS (${summary.unpaidItemCount})'),
              Tab(text: 'PAYMENTS (${summary.paymentHistory.length})'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Tab content
        Expanded(
          child: TabBarView(controller: _tabController, children: [
            _buildItemsTab(summary.creditItems, locale),
            _buildPaymentsTab(summary.paymentHistory, locale),
          ]),
        ),
        // Action buttons
        _buildActions(c),
      ]),
    );
  }

  Widget _buildItemsTab(List<CreditItem> items, String locale) {
    if (items.isEmpty) {
      return Center(child: Text('NO CREDIT ITEMS',
        style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.2), fontWeight: FontWeight.w900, letterSpacing: 2)));
    }
    // Show unpaid first, then paid
    final sorted = [...items]..sort((a, b) {
      if (a.isPaid != b.isPaid) return a.isPaid ? 1 : -1;
      return b.createdAt.compareTo(a.createdAt);
    });
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: sorted.length,
      itemBuilder: (context, i) => CreditItemCard(
        item: sorted[i], locale: locale,
        onDelete: sorted[i].isPaid ? null : () => _deleteItem(sorted[i]),
      ),
    );
  }

  Widget _buildPaymentsTab(List<PaymentRecord> payments, String locale) {
    if (payments.isEmpty) {
      return Center(child: Text('NO PAYMENTS RECORDED',
        style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.2), fontWeight: FontWeight.w900, letterSpacing: 2)));
    }
    final sorted = [...payments]..sort((a, b) => b.paidAt.compareTo(a.paidAt));
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: sorted.length,
      itemBuilder: (context, i) => PaymentCard(payment: sorted[i], locale: locale),
    );
  }

  Widget _buildActions(Customer c) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.background,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(children: [
        Expanded(child: OutlinedButton.icon(
          onPressed: () => context.push('/customers/${widget.customerId}/add-item'),
          icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
          label: const Text('Add Credit'),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppTheme.primaryBlue, width: 2),
            padding: const EdgeInsets.symmetric(vertical: 18),
            foregroundColor: AppTheme.primaryBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        )),
        const SizedBox(width: 16),
        Expanded(child: ElevatedButton.icon(
          onPressed: c.outstandingBalance > 0
            ? () => context.push('/customers/${widget.customerId}/record-payment', extra: {'outstandingBalance': c.outstandingBalance})
            : null,
          icon: const Icon(Icons.payment_rounded, size: 20),
          label: const Text('Payment'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentGreen,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        )),
      ]),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.textSecondary.withOpacity(0.1))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
      ]),
    );
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }
}
