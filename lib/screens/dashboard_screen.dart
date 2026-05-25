import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/models/customer.dart';
import '../core/providers/auth_provider.dart';
import '../features/customers/providers/customer_provider.dart';
import '../shared/widgets/customer_card.dart';
import '../shared/widgets/confirm_dialog.dart';
import '../utils/theme.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final Set<String> _selected = {};
  bool get _isSelectionMode => _selected.isNotEmpty;

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) { _selected.remove(id); } else { _selected.add(id); }
    });
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

  Future<void> _deleteSelected() async {
    final ok = await showConfirmDialog(
      context: context, title: 'Delete Customers',
      message: 'Permanently delete ${_selected.length} customer(s) and all their data?',
      confirmText: 'Delete', isDestructive: true,
    );
    if (!ok) return;
    final notifier = ref.read(customerNotifierProvider.notifier);
    try {
      for (final id in _selected) { await notifier.deleteCustomer(id); }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: ${_friendlyError(e)}'), backgroundColor: AppTheme.error),
        );
      }
    }
    setState(() => _selected.clear());
  }

  void _showAddCustomerDialog() {
    final name = TextEditingController();
    final phone = TextEditingController();
    final telegram = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Register Customer', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.2)),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(labelText: 'Full Name *', prefixIcon: Icon(Icons.person_outline, size: 20)),
            textCapitalization: TextCapitalization.words),
          const SizedBox(height: 16),
          TextField(controller: phone, style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(labelText: 'Phone *', prefixIcon: Icon(Icons.phone_outlined, size: 20)),
            keyboardType: TextInputType.phone),
          const SizedBox(height: 16),
          TextField(controller: telegram, style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(labelText: 'Telegram Username', prefixIcon: Icon(Icons.telegram_rounded, size: 20))),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary))),
          ElevatedButton(
            onPressed: () async {
              if (name.text.isEmpty || phone.text.isEmpty) return;
              try {
                await ref.read(customerNotifierProvider.notifier).addCustomer(
                  CreateCustomerDto(fullName: name.text.trim(), phone: phone.text.trim(), telegramUsername: telegram.text.trim()),
                );
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${_friendlyError(e)}'), backgroundColor: AppTheme.error),
                  );
                }
              }
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customerNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final shopName = authState.owner?.shopName ?? 'My Shop';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _isSelectionMode
        ? AppBar(
            backgroundColor: AppTheme.primaryBlue, elevation: 0, centerTitle: false,
            leading: IconButton(icon: const Icon(Icons.close_rounded, color: Colors.white),
              onPressed: () => setState(() => _selected.clear())),
            title: Text('${_selected.length}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            actions: [
              IconButton(icon: const Icon(Icons.delete_rounded, color: Colors.red), onPressed: _deleteSelected),
            ],
          )
        : AppBar(
            title: Text(shopName.toUpperCase()),
            actions: [
              IconButton(icon: const Icon(Icons.notifications_outlined, color: AppTheme.textSecondary),
                onPressed: () => context.push('/notifications')),
              IconButton(icon: const Icon(Icons.settings_rounded, color: AppTheme.textSecondary),
                onPressed: () => context.push('/settings')),
            ],
          ),
      body: customersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
        error: (e, _) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.cloud_off_rounded, size: 64, color: AppTheme.error),
          const SizedBox(height: 16),
          Text('Failed to load data', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('$e', style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5), fontSize: 11), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () => ref.invalidate(customerNotifierProvider), child: const Text('Retry')),
        ])),
        data: (customers) => _buildContent(customers),
      ),
      floatingActionButton: _isSelectionMode ? null : FloatingActionButton.extended(
        onPressed: _showAddCustomerDialog,
        backgroundColor: AppTheme.primaryBlue,
        label: const Text('New Customer', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildContent(List<Customer> customers) {
    final totalOutstanding = customers.fold<double>(0, (s, c) => s + c.outstandingBalance);
    final overdueCount = customers.where((c) => c.isOverdue).length;
    final activeCount = customers.where((c) => c.isActive || c.isOverdue).length;

    return Column(children: [
      // Hero card
      _HeroCard(totalOutstanding: totalOutstanding, customerCount: customers.length, overdueCount: overdueCount, activeCount: activeCount),
      // Section header
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
        child: Row(children: [
          const Text('CUSTOMERS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2, color: AppTheme.textSecondary)),
          const Spacer(),
          Text('${customers.length} total', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary.withOpacity(0.5), fontWeight: FontWeight.bold)),
        ]),
      ),
      // List
      Expanded(
        child: customers.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.shield_moon_rounded, size: 100, color: AppTheme.textSecondary.withOpacity(0.1)),
              const SizedBox(height: 24),
              Text('NO CUSTOMERS YET', style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.3), fontWeight: FontWeight.w900, letterSpacing: 3)),
            ]))
          : RefreshIndicator(
              onRefresh: () => ref.read(customerNotifierProvider.notifier).refresh(),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  final c = customers[index];
                  return CustomerCard(
                    customer: c, index: index,
                    isSelected: _selected.contains(c.id),
                    onTap: () {
                      if (_isSelectionMode) { _toggle(c.id); }
                      else { context.push('/customers/${c.id}'); }
                    },
                    onLongPress: () => _toggle(c.id),
                  );
                },
              ),
            ),
      ),
    ]);
  }
}

class _HeroCard extends StatelessWidget {
  final double totalOutstanding;
  final int customerCount;
  final int overdueCount;
  final int activeCount;

  const _HeroCard({required this.totalOutstanding, required this.customerCount, required this.overdueCount, required this.activeCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(colors: [AppTheme.primaryBlue, AppTheme.primaryBlue.withBlue(200)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 12))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('TOTAL OUTSTANDING', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const SizedBox(height: 12),
        FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic,
          children: [
            Text(totalOutstanding.toStringAsFixed(2), style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(width: 8),
            Text('ETB', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.7))),
          ],
        )),
        const SizedBox(height: 20),
        Row(children: [
          _chip(Icons.people_rounded, '$customerCount Customers'),
          const SizedBox(width: 10),
          if (overdueCount > 0) _chip(Icons.warning_amber_rounded, '$overdueCount Overdue', color: const Color(0xFFFF6B6B)),
          if (overdueCount > 0) const SizedBox(width: 10),
          _chip(Icons.trending_up_rounded, '$activeCount Active'),
        ]),
      ]),
    );
  }

  Widget _chip(IconData icon, String text, {Color color = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color.withOpacity(0.9))),
      ]),
    );
  }
}
