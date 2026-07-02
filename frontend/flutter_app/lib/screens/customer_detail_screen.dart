import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../core/models/customer.dart';
import '../core/models/credit_item.dart';
import '../core/models/credit_session.dart';
import '../core/models/payment_record.dart';
import '../core/providers/auth_provider.dart';
import '../core/providers/api_client_provider.dart';
import '../features/customers/providers/customer_provider.dart';
import '../features/customers/repositories/customer_repository.dart';
import '../features/credits/providers/credit_item_provider.dart';
import '../shared/widgets/components/saas_components.dart';
import '../shared/widgets/confirm_dialog.dart';
import '../features/notifications/screens/notification_log_screen.dart';
import '../utils/theme.dart';
import '../utils/ethiopian_date_picker.dart';
import '../utils/ethiopian_calendar.dart';
import '../l10n/app_localizations.dart';

class CustomerDetailScreen extends ConsumerStatefulWidget {
  final String customerId;
  const CustomerDetailScreen({super.key, required this.customerId});
  @override
  ConsumerState<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _sessionLimitHit = false; // set true only after a blocked create attempt
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  String _friendlyError(Object e, AppLocalizations l10n) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data.containsKey('error')) return data['error'] as String;
      return l10n.serverError;
    }
    return l10n.somethingWentWrong;
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(customerSummaryProvider(widget.customerId));
    final tokens = Theme.of(context).extension<DubeTokens>()!;
    final l10n = AppLocalizations.of(context)!;

    return summaryAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (summary) => _buildScaffold(summary, tokens, l10n),
    );
  }

  Widget _buildScaffold(CustomerSummary summary, DubeTokens tokens, AppLocalizations l10n) {
    final c = summary.customer;
    final theme = Theme.of(context);
    final authState = ref.watch(authNotifierProvider);
    final isCustomer = authState.owner?.role == 'CUSTOMER';

    final logsAsync = ref.watch(notificationLogProvider);
    final alertCount = logsAsync.asData?.value.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child:Text(c.fullName.toUpperCase(), style: theme.textTheme.titleLarge?.copyWith(fontSize: 16))),
            Center(child:Text(c.phone.isNotEmpty ? c.phone : l10n.noPhone, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11))),
          ],
        ),
        actions: [
          if (!isCustomer)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error),
              onPressed: () async {
                final ok = await showConfirmDialog(
                  context: context, 
                  title: l10n.deleteCustomer, 
                  message: l10n.deleteCustomerAndRecords, 
                  confirmText: l10n.delete,
                  cancelText: l10n.cancel,
                  isDestructive: true
                );
                if (ok) {
                  await ref.read(customerNotifierProvider.notifier).deleteCustomer(widget.customerId);
                  if (mounted) context.go('/dashboard');
                }
              },
            )
          else ...[
            IconButton(
              icon: Badge(
                label: alertCount > 0 ? Text('$alertCount') : null,
                isLabelVisible: alertCount > 0,
                child: const Icon(Icons.notifications_outlined),
              ),
              onPressed: () => context.push('/notifications'),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => context.push('/settings'),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 60) / 2,
                  child: SaaSStatCard(
                    label: l10n.balance, 
                    value: l10n.etbAmount(c.outstandingBalance.toStringAsFixed(0)), 
                    valueColor: c.isOverdue ? AppTheme.error : AppTheme.primary
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 60) / 2,
                  child: SaaSStatCard(
                    label: l10n.totalDebt, 
                    value: l10n.etbAmount(c.totalDebt.toStringAsFixed(0))
                  ),
                ),
                if (c.walletBalance > 0)
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 48,
                    child: SaaSStatCard(
                      label: l10n.walletBalancePositive, 
                      value: l10n.etbAmount(c.walletBalance.toStringAsFixed(0)),
                      valueColor: AppTheme.primary,
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                  ),
              ],
            ),
          ),
          // Date Range Filter Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.date_range, size: 16),
                  label: Text(_fromDate == null 
                    ? l10n.startDate 
                    : DateFormat('MM/dd/yyyy').format(_fromDate!)),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _fromDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() => _fromDate = picked);
                    }
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.date_range, size: 16),
                  label: Text(_toDate == null 
                    ? l10n.endDate 
                    : DateFormat('MM/dd/yyyy').format(_toDate!)),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _toDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() => _toDate = picked);
                    }
                  },
                ),
                if (_fromDate != null || _toDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 16, color: AppTheme.error),
                    onPressed: () {
                      setState(() {
                        _fromDate = null;
                        _toDate = null;
                      });
                    },
                  ),
              ],
            ),
          ),
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: tokens.surfaceLow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: tokens.surfaceBorder),
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              dividerHeight: 0,
              indicator: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(18)),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppTheme.background,
              unselectedLabelColor: tokens.onSurfaceMuted,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              tabs: [Tab(text: l10n.timeline), Tab(text: l10n.payments)],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTimelineTab(summary.sessions, isCustomer, l10n),
                _buildPaymentsTab(summary.paymentHistory, l10n),
              ],
            ),
          ),
          if (!isCustomer) _buildActionFooter(c, summary.sessions, l10n),
        ],
      ),
    );
  }

  Widget _buildTimelineTab(List<CreditSession> sessions, bool isCustomer, AppLocalizations l10n) {
    var filtered = [...sessions]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (_fromDate != null) {
      filtered = filtered.where((s) => s.createdAt.isAfter(_fromDate!)).toList();
    }
    if (_toDate != null) {
      filtered = filtered.where((s) => s.createdAt.isBefore(_toDate!.add(const Duration(days: 1)))).toList();
    }
    if (filtered.isEmpty) return Center(child: Text(l10n.noCreditMatchesFilters));
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: filtered.length,
      itemBuilder: (context, i) => _FinancialTimelineItem(session: filtered[i], isCustomer: isCustomer, customerId: widget.customerId),
    );
  }

  Widget _buildPaymentsTab(List<PaymentRecord> payments, AppLocalizations l10n) {
    var filtered = [...payments]..sort((a, b) => b.paidAt.compareTo(a.paidAt));
    if (_fromDate != null) {
      filtered = filtered.where((p) => p.paidAt.isAfter(_fromDate!)).toList();
    }
    if (_toDate != null) {
      filtered = filtered.where((p) => p.paidAt.isBefore(_toDate!.add(const Duration(days: 1)))).toList();
    }
    if (filtered.isEmpty) return Center(child: Text(l10n.noPaymentsMatchesFilters));
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: filtered.length,
      itemBuilder: (context, i) {
        final p = filtered[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SaaSCard(
            child: Row(
              children: [
                const CircleAvatar(backgroundColor: AppTheme.primary, child: Icon(Icons.check, color: Colors.white, size: 16)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.paymentReceived, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                      Text(DateFormat('MMM dd, yyyy • hh:mm a').format(p.paidAt.toLocal()), style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Text('+${l10n.etbAmount(p.amountPaid.toStringAsFixed(0))}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16, color: AppTheme.primary)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionFooter(Customer c, List<CreditSession> sessions, AppLocalizations l10n) {
    final tokens = Theme.of(context).extension<DubeTokens>()!;
    final activeSessionsCount = sessions.where((s) => !s.isPaid).length;
    final blocked = _sessionLimitHit && activeSessionsCount >= 2;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border(top: BorderSide(color: tokens.surfaceBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (blocked) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.error.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppTheme.error, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.sessionLimitWarning,
                      style: const TextStyle(color: AppTheme.error, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SaaSButton(
                    label: l10n.addNew,
                    icon: Icons.add_circle_outline,
                    variant: blocked ? SaaSButtonVariant.ghost : SaaSButtonVariant.secondary,
                    onPressed: blocked ? null : () => _createNewSession(activeSessionsCount, l10n),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SaaSButton(
                    label: l10n.pay,
                    icon: Icons.payment,
                    onPressed: c.outstandingBalance > 0
                        ? () => context.push(
                              '/customers/${widget.customerId}/record-payment',
                              extra: {'outstandingBalance': c.outstandingBalance},
                            )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createNewSession(int activeSessionsCount, AppLocalizations l10n) async {
    if (activeSessionsCount >= 2) {
      setState(() => _sessionLimitHit = true);
      return;
    }
    final picked = await showEthiopianDatePicker(context: context, initialDate: DateTime.now());
    if (picked == null) return;
    final eth = EthiopianCalendar.fromGregorian(picked);
    try {
      await ref.read(creditItemActionsProvider).addSession(
        widget.customerId,
        CreateCreditSessionDto(deadline: picked.toUtc(), ethiopianDeadline: {'year': eth.year, 'month': eth.month, 'day': eth.day}),
      );
      ref.invalidate(customerSummaryProvider(widget.customerId));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error));
    }
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }
}

class _FinancialTimelineItem extends ConsumerWidget {
  final CreditSession session;
  final bool isCustomer;
  final String customerId;

  const _FinancialTimelineItem({required this.session, required this.isCustomer, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DubeTokens>()!;
    final l10n = AppLocalizations.of(context)!;
    final deadlineStr = session.deadline != null ? DateFormat('MMM dd, yyyy').format(session.deadline!.toLocal()) : l10n.noDeadline;

    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 12, height: 12,
                decoration: BoxDecoration(
                  color: session.isPaid ? AppTheme.primary : (session.isOverdue ? AppTheme.error : tokens.info),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.background, width: 2),
                ),
              ),
              Expanded(child: Container(width: 2, color: tokens.surfaceBorder)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: GestureDetector(
                onLongPress: isCustomer ? null : () => _showSessionActions(context, ref, l10n),
                child: SaaSCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('MMM dd').format(session.createdAt.toLocal()), style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              if (isCustomer && !session.isPaid)
                                  TextButton.icon(
                                    icon: const Icon(Icons.warning_amber_rounded, size: 14, color: AppTheme.error),
                                    label: Text(l10n.dispute, style: const TextStyle(color: AppTheme.error, fontSize: 10)),
                                    onPressed: () => _showDisputeDialog(context, ref, l10n),
                                  ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: session.isPaid ? tokens.successMuted : (session.isOverdue ? AppTheme.error.withOpacity(0.1) : tokens.surfaceHigh), borderRadius: BorderRadius.circular(8)),
                                child: Text(session.isPaid ? l10n.paid : (session.isOverdue ? l10n.overdue : l10n.active), style: theme.textTheme.bodySmall?.copyWith(fontSize: 9, color: session.isPaid ? AppTheme.primary : (session.isOverdue ? AppTheme.error : tokens.onSurfaceMuted), fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...session.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.itemName, style: theme.textTheme.bodyLarge?.copyWith(fontSize: 14)),
                                  Text(item.metadataDisplay, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(l10n.etbAmount(item.totalPrice.toStringAsFixed(0)), style: theme.textTheme.bodyLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
                                if (!isCustomer && !session.isPaid) ...[
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 16),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => _showEditItemDialog(context, ref, item, l10n),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppTheme.error),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => _deleteItem(context, ref, item.id, l10n),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      )),
                      if (session.items.isNotEmpty) Divider(height: 24, color: tokens.surfaceBorder),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${l10n.dueDate(deadlineStr)}', style: theme.textTheme.bodySmall?.copyWith(color: session.isOverdue ? AppTheme.error : tokens.onSurfaceMuted, fontWeight: FontWeight.bold)),
                              if (!session.isPaid && session.outstandingBalance < session.totalAmount)
                                Text(l10n.remaining(session.outstandingBalance.toStringAsFixed(0)), style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.primary, fontSize: 10)),
                            ],
                          ),
                          Text(l10n.etbAmount(session.totalAmount.toStringAsFixed(0)), style: theme.textTheme.titleLarge?.copyWith(color: AppTheme.primary)),
                        ],
                      ),
                      if (!isCustomer && !session.isPaid) ...[
                        const SizedBox(height: 16),
                        SaaSButton(
                          label: l10n.addItem,
                          variant: SaaSButtonVariant.secondary,
                          icon: Icons.add,
                          onPressed: () => _showAddItemDialog(context, ref, l10n),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem(BuildContext context, WidgetRef ref, String itemId, AppLocalizations l10n) async {
    final ok = await showConfirmDialog(
      context: context,
      title: l10n.deleteItem,
      message: l10n.deleteItemConfirm,
      confirmText: l10n.delete,
      cancelText: l10n.cancel,
      isDestructive: true,
    );
    if (!ok) return;

    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/credits/${session.id}/items/$itemId');
      ref.invalidate(customerSummaryProvider(customerId));
      ref.invalidate(customerNotifierProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting item: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  void _showEditItemDialog(BuildContext context, WidgetRef ref, CreditItem item, AppLocalizations l10n) {
    final itemName = TextEditingController(text: item.itemName);
    final qty = TextEditingController(text: item.quantity.toStringAsFixed(0));
    final price = TextEditingController(text: item.unitPrice.toStringAsFixed(0));
    bool isKg = item.unitType == 'kg';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final q = double.tryParse(qty.text) ?? 0;
            final p = double.tryParse(price.text) ?? 0;
            final itemTotal = q * p;

            return AlertDialog(
              title: Text(l10n.editItem),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: itemName,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: l10n.itemName,
                        prefixIcon: const Icon(Icons.shopping_bag_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: Center(child: Text(l10n.byKg)),
                            selected: isKg,
                            onSelected: (val) {
                              if (val) {
                                setState(() {
                                  isKg = true;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: Center(child: Text(l10n.byQuantity)),
                            selected: !isKg,
                            onSelected: (val) {
                              if (val) {
                                setState(() {
                                  isKg = false;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: qty,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: isKg ? l10n.weightKg : l10n.quantity,
                              prefixIcon: Icon(isKg ? Icons.scale_outlined : Icons.numbers_outlined),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: price,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: isKg ? l10n.pricePerKg : l10n.pricePerItem,
                              prefixIcon: const Icon(Icons.payments_outlined),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    if (itemTotal > 0) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          l10n.totalAmount(itemTotal.toStringAsFixed(0)),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.cancel),
                ),
                SaaSButton(
                  label: l10n.saveChanges,
                  isFullWidth: false,
                  onPressed: () async {
                    if (itemName.text.isEmpty || price.text.isEmpty) return;
                    final qVal = double.tryParse(qty.text) ?? 1;
                    final pVal = double.tryParse(price.text) ?? 0;
                    try {
                      final dio = ref.read(dioProvider);
                      await dio.patch(
                        '/credits/${session.id}/items/${item.id}',
                        data: {
                          'itemName': itemName.text.trim(),
                          'unitType': isKg ? 'kg' : 'piece',
                          'quantity': qVal,
                          'unitPrice': pVal,
                        },
                      );
                      ref.invalidate(customerSummaryProvider(customerId));
                      ref.invalidate(customerNotifierProvider);
                      if (ctx.mounted) Navigator.pop(ctx);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDisputeDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final complaintController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.raiseDispute),
        content: TextField(
          controller: complaintController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: l10n.complaintMessage,
            hintText: l10n.complaintHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          SaaSButton(
            label: l10n.submitDispute,
            isFullWidth: false,
            onPressed: () async {
              if (complaintController.text.trim().isEmpty) return;
              try {
                final dio = ref.read(dioProvider);
                await dio.post(
                  '/customers/$customerId/dispute',
                  data: {
                    'sessionId': session.id,
                    'message': complaintController.text.trim(),
                  },
                );
                ref.invalidate(customerSummaryProvider(customerId));
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.disputeSubmitted)),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error submitting dispute: $e'), backgroundColor: AppTheme.error),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showSessionActions(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_calendar_outlined),
              title: Text(l10n.updateDeadline),
              onTap: () {
                Navigator.pop(ctx);
                _updateDeadline(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel_outlined, color: AppTheme.error),
              title: Text(l10n.cancelSession, style: const TextStyle(color: AppTheme.error)),
              onTap: () {
                Navigator.pop(ctx);
                _cancelSession(context, ref, l10n);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateDeadline(BuildContext context, WidgetRef ref) async {
    final picked = await showEthiopianDatePicker(
      context: context,
      initialDate: session.deadline ?? DateTime.now(),
    );
    if (picked == null) return;
    final eth = EthiopianCalendar.fromGregorian(picked);
    try {
      await ref.read(creditItemActionsProvider).updateSessionDeadline(
        customerId,
        session.id,
        deadline: picked.toUtc(),
        ethiopianDeadline: {'year': eth.year, 'month': eth.month, 'day': eth.day},
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  Future<void> _cancelSession(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final ok = await showConfirmDialog(
      context: context,
      title: l10n.cancelSession,
      message: l10n.cancelSessionConfirm,
      confirmText: l10n.confirm,
      cancelText: l10n.cancel,
      isDestructive: true,
    );
    if (!ok) return;
    try {
      await ref.read(creditItemActionsProvider).cancelSession(customerId, session.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  void _showAddItemDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final itemName = TextEditingController();
    final qty = TextEditingController(text: '1');
    final price = TextEditingController();
    bool isKg = true;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final q = double.tryParse(qty.text) ?? 0;
            final p = double.tryParse(price.text) ?? 0;
            final itemTotal = q * p;

            return AlertDialog(
              title: Text(l10n.addItemToSession),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: itemName,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: l10n.itemName,
                        prefixIcon: const Icon(Icons.shopping_bag_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: Center(child: Text(l10n.byKg)),
                            selected: isKg,
                            onSelected: (val) {
                              if (val) {
                                setState(() {
                                    isKg = true;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: Center(child: Text(l10n.byQuantity)),
                            selected: !isKg,
                            onSelected: (val) {
                              if (val) {
                                setState(() {
                                    isKg = false;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: qty,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: isKg ? l10n.weightKg : l10n.quantity,
                              prefixIcon: Icon(isKg ? Icons.scale_outlined : Icons.numbers_outlined),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: price,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: isKg ? l10n.pricePerKg : l10n.pricePerItem,
                              prefixIcon: const Icon(Icons.payments_outlined),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    if (itemTotal > 0) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          l10n.totalAmount(itemTotal.toStringAsFixed(0)),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.cancel),
                ),
                SaaSButton(
                  label: l10n.addItem,
                  isFullWidth: false,
                  onPressed: () async {
                    if (itemName.text.isEmpty || price.text.isEmpty) return;
                    final qVal = double.tryParse(qty.text) ?? 1;
                    final pVal = double.tryParse(price.text) ?? 0;
                    await ref.read(creditItemActionsProvider).addItemToSession(
                      customerId,
                      session.id,
                      CreateCreditItemDto(
                        itemName: itemName.text.trim(),
                        unitType: isKg ? 'kg' : 'piece',
                        quantity: qVal,
                        unitPrice: pVal,
                      ),
                    );
                    ref.invalidate(customerSummaryProvider(customerId));
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}