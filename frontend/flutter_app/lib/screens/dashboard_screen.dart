import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/models/customer.dart';
import '../core/models/shop.dart';
import '../core/providers/auth_provider.dart';
import '../core/providers/shop_provider.dart';
import '../features/customers/providers/customer_provider.dart';
import '../features/customers/repositories/customer_repository.dart';
import '../l10n/app_localizations.dart';
import '../shared/widgets/customer_card.dart';
import '../shared/widgets/confirm_dialog.dart';
import '../shared/widgets/components/saas_components.dart';
import '../features/notifications/screens/notification_log_screen.dart';
import '../utils/theme.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final Set<String> _selected = {};
  bool get _isSelectionMode => _selected.isNotEmpty;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isCustomer = ref.read(authNotifierProvider).owner?.role == 'CUSTOMER';
      ref.read(shopsListProvider.notifier).loadShops(isCustomer: isCustomer);
    });
  }

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  String _friendlyError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data.containsKey('error')) return data['error'] as String;
      if (data is Map<String, dynamic> && data.containsKey('detail')) return data['detail'] as String;
      return 'Server error';
    }
    return 'Something went wrong';
  }

  void _showAddCustomerDialog() {
    final username = TextEditingController();
    final selectedShop = ref.read(selectedShopProvider);
    if (selectedShop == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Register Customer'),
        content: TextField(
          controller: username,
          decoration: const InputDecoration(labelText: 'Username'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          SaaSButton(
            label: 'Register',
            isFullWidth: false,
            onPressed: () async {
              if (username.text.isEmpty) return;
              try {
                final created = await ref.read(customerNotifierProvider.notifier).addCustomer(
                      CreateCustomerDto(shopId: selectedShop.id, username: username.text.trim()),
                    );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  context.push('/customers/${created.id}');
                }
              } catch (e) {
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${_friendlyError(e)}'), backgroundColor: AppTheme.error),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isCustomer = authState.owner?.role == 'CUSTOMER';

    if (isCustomer) return _buildCustomerPortal(context);

    final shopsAsync = ref.watch(shopsListProvider);
    final selectedShop = ref.watch(selectedShopProvider);
    final customersAsync = ref.watch(customerNotifierProvider);
    final tokens = Theme.of(context).extension<DubeTokens>()!;

    // Auto-select first shop if none is selected
    ref.listen<AsyncValue<List<Shop>>>(shopsListProvider, (previous, next) {
      next.whenData((shops) {
        if (shops.isNotEmpty && ref.read(selectedShopProvider) == null) {
          ref.read(selectedShopProvider.notifier).selectShop(shops.first);
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            shopsAsync.whenData((shops) {
              _showShopSelector(context, shops, selectedShop);
            });
          },
          child: Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primary,
                child: Icon(Icons.storefront_rounded, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(selectedShop?.name ?? 'DubeBook', style: Theme.of(context).textTheme.titleLarge),
                    Text(selectedShop?.businessType.toUpperCase() ?? 'SaaS PLATFORM', 
                         style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10, letterSpacing: 1)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: shopsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (shops) {
          if (shops.isEmpty) {
            return SaaSEmptyState(
              icon: Icons.storefront_outlined,
              title: 'Create Your Shop',
              description: 'You need a shop profile to begin registering customers and tracking credits.',
              actionLabel: 'Create New Shop',
              onAction: _showCreateShopDialog,
            );
          }

          if (selectedShop == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return customersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (customers) {
              final filtered = customers.where((c) => 
                c.fullName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
              return _buildRetailerContent(filtered);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCustomerDialog,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.person_add_outlined),
      ),
    );
  }

  Widget _buildRetailerContent(List<Customer> customers) {
    final totalOutstanding = customers.fold<double>(0, (s, c) => s + c.outstandingBalance);
    final theme = Theme.of(context);
    final tokens = theme.extension<DubeTokens>()!;

    return RefreshIndicator(
      onRefresh: () => ref.read(customerNotifierProvider.notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   SaaSStatCard(
                    label: 'TOTAL OUTSTANDING',
                    value: '${totalOutstanding.toStringAsFixed(2)} ETB',
                    icon: Icons.account_balance_wallet_rounded,
                    usePrimaryColor: true,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search customers...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchQuery.isNotEmpty 
                        ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          })
                        : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('CUSTOMERS', style: theme.textTheme.bodySmall?.copyWith(letterSpacing: 2, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          if (customers.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people_outline_rounded, size: 64, color: tokens.onSurfaceMuted),
                    const SizedBox(height: 16),
                    Text('No customers found', style: theme.textTheme.bodyLarge?.copyWith(color: tokens.onSurfaceMuted)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final c = customers[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SaaSCard(
                        onTap: () => context.push('/customers/${c.id}'),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: tokens.surfaceHigh,
                              child: Text(c.fullName.isNotEmpty ? c.fullName[0].toUpperCase() : '?', style: const TextStyle(color: AppTheme.primary)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.fullName, style: theme.textTheme.titleLarge?.copyWith(fontSize: 16)),
                                  Text(c.isActive ? 'Active Session' : 'No Active Credit', 
                                       style: theme.textTheme.bodySmall?.copyWith(color: c.isActive ? AppTheme.primary : tokens.onSurfaceMuted)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${c.outstandingBalance.toStringAsFixed(2)} ETB', style: theme.textTheme.titleLarge?.copyWith(fontSize: 16)),
                                if (c.isOverdue)
                                  Text('OVERDUE', style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.error, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: customers.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildCustomerPortal(BuildContext context) {
    final dashboardAsync = ref.watch(customerDashboardProvider);
    final theme = Theme.of(context);
    final tokens = theme.extension<DubeTokens>()!;
    final logsAsync = ref.watch(notificationLogProvider);
    final alertCount = logsAsync.asData?.value.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MY PORTAL'),
        actions: [
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
      ),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(customerDashboardProvider);
            ref.invalidate(customerNotifierProvider);
            await ref.read(customerDashboardProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              SaaSStatCard(
                label: 'TOTAL AGGREGATE DEBT',
                value: '${data.totalAggregateDebt.toStringAsFixed(2)} ETB',
                valueColor: AppTheme.error,
                icon: Icons.account_balance_outlined,
              ),
              const SizedBox(height: 32),
              Text('MY CREDIT ACCOUNTS', style: theme.textTheme.bodySmall?.copyWith(letterSpacing: 2, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...data.linkedAccounts.map((acc) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SaaSCard(
                  onTap: () => context.push('/customers/${acc.id}'),
                  child: Row(
                    children: [
                      const Icon(Icons.store_outlined, color: AppTheme.primary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(acc.shop?.name ?? 'Unknown Shop', style: theme.textTheme.titleLarge?.copyWith(fontSize: 16)),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (acc.outstandingBalance > 0)
                            Text('${acc.outstandingBalance.toStringAsFixed(2)} ETB', 
                                 style: theme.textTheme.titleLarge?.copyWith(fontSize: 16, color: AppTheme.error))
                          else if (acc.walletBalance > 0)
                            Text('+${acc.walletBalance.toStringAsFixed(2)} ETB', 
                                 style: theme.textTheme.titleLarge?.copyWith(fontSize: 16, color: AppTheme.primary))
                          else
                            Text('0.00 ETB', 
                                 style: theme.textTheme.titleLarge?.copyWith(fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _showShopSelector(BuildContext context, List<Shop> shops, Shop? selectedShop) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SWITCH SHOP', style: Theme.of(context).textTheme.bodySmall?.copyWith(letterSpacing: 2, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...shops.map((s) => ListTile(
              leading: Icon(Icons.storefront_rounded, color: s.id == selectedShop?.id ? AppTheme.primary : null),
              title: Text(s.name),
              trailing: s.id == selectedShop?.id ? const Icon(Icons.check_circle, color: AppTheme.primary) : null,
              onTap: () {
                ref.read(selectedShopProvider.notifier).selectShop(s);
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 16),
            SaaSButton(label: 'Add New Shop', variant: SaaSButtonVariant.secondary, icon: Icons.add, onPressed: () {
              Navigator.pop(context);
              _showCreateShopDialog();
            }),
          ],
        ),
      ),
    );
  }

  void _showCreateShopDialog() {
    final name = TextEditingController();
    final type = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create New Shop'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Shop Name')),
            const SizedBox(height: 16),
            TextField(controller: type, decoration: const InputDecoration(labelText: 'Business Type')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          SaaSButton(
            label: 'Create',
            isFullWidth: false,
            onPressed: () async {
              if (name.text.isEmpty) return;
              await ref.read(shopsListProvider.notifier).createNewShop(name: name.text.trim(), businessType: type.text);
              if (ctx.mounted) Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<DubeTokens>()!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: tokens.surfaceLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Icon(icon, color: AppTheme.primary),
          ),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
