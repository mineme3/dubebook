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

  String _friendlyError(Object e, AppLocalizations l10n) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data.containsKey('error')) return data['error'] as String;
      if (data is Map<String, dynamic> && data.containsKey('detail')) return data['detail'] as String;
      return l10n.serverError;
    }
    return l10n.somethingWentWrong;
  }

  void _showAddCustomerDialog(AppLocalizations l10n) {
    final usernameController = TextEditingController();
    final selectedShop = ref.read(selectedShopProvider);
    if (selectedShop == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.registerCustomer),
        content: TextField(
          controller: usernameController,
          decoration: InputDecoration(labelText: l10n.username),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          SaaSButton(
            label: l10n.register,
            isFullWidth: false,
            onPressed: () async {
              if (usernameController.text.isEmpty) return;
              try {
                final created = await ref.read(customerNotifierProvider.notifier).addCustomer(
                      CreateCustomerDto(shopId: selectedShop.id, username: usernameController.text.trim()),
                    );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  context.push('/customers/${created.id}');
                }
              } catch (e) {
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${_friendlyError(e, l10n)}'), backgroundColor: AppTheme.error),
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
    final l10n = AppLocalizations.of(context)!;

    if (isCustomer) return _buildCustomerPortal(context, l10n);

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
              _showShopSelector(context, shops, selectedShop, l10n);
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
                    Text(selectedShop?.name ?? l10n.appName, style: Theme.of(context).textTheme.titleLarge),
                    Text(selectedShop?.businessType.toUpperCase() ?? l10n.saasPlafform, 
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
              title: l10n.createYourShop,
              description: l10n.createYourShopDesc,
              actionLabel: l10n.createNewShop,
              onAction: () => _showCreateShopDialog(l10n),
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
              return _buildRetailerContent(filtered, l10n);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCustomerDialog(l10n),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.person_add_outlined),
      ),
    );
  }

  Widget _buildRetailerContent(List<Customer> customers, AppLocalizations l10n) {
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
                    label: l10n.totalOutstanding,
                    value: l10n.etbAmount(totalOutstanding.toStringAsFixed(2)),
                    icon: Icons.account_balance_wallet_rounded,
                    usePrimaryColor: true,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: l10n.searchCustomers,
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
                  Text(l10n.customers, style: theme.textTheme.bodySmall?.copyWith(letterSpacing: 2, fontWeight: FontWeight.bold)),
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
                    Text(l10n.noCustomersFoundLower, style: theme.textTheme.bodyLarge?.copyWith(color: tokens.onSurfaceMuted)),
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
                                  Text(c.isActive ? l10n.activeSession : l10n.noActiveCredit, 
                                       style: theme.textTheme.bodySmall?.copyWith(color: c.isActive ? AppTheme.primary : tokens.onSurfaceMuted)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(l10n.etbAmount(c.outstandingBalance.toStringAsFixed(2)), style: theme.textTheme.titleLarge?.copyWith(fontSize: 16)),
                                if (c.isOverdue)
                                  Text(l10n.overdue, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.error, fontWeight: FontWeight.bold)),
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

  Widget _buildCustomerPortal(BuildContext context, AppLocalizations l10n) {
    final dashboardAsync = ref.watch(customerDashboardProvider);
    final theme = Theme.of(context);
    final tokens = theme.extension<DubeTokens>()!;
    final logsAsync = ref.watch(notificationLogProvider);
    final alertCount = logsAsync.asData?.value.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myPortal),
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
                label: l10n.totalAggregateDebt,
                value: l10n.etbAmount(data.totalAggregateDebt.toStringAsFixed(2)),
                valueColor: AppTheme.error,
                icon: Icons.account_balance_outlined,
              ),
              const SizedBox(height: 32),
              Text(l10n.myCreditAccounts, style: theme.textTheme.bodySmall?.copyWith(letterSpacing: 2, fontWeight: FontWeight.bold)),
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
                        child: Text(acc.shop?.name ?? l10n.unknownShop, style: theme.textTheme.titleLarge?.copyWith(fontSize: 16)),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (acc.outstandingBalance > 0)
                            Text(l10n.etbAmount(acc.outstandingBalance.toStringAsFixed(2)), 
                                 style: theme.textTheme.titleLarge?.copyWith(fontSize: 16, color: AppTheme.error))
                          else if (acc.walletBalance > 0)
                            Text('+${l10n.etbAmount(acc.walletBalance.toStringAsFixed(2))}', 
                                 style: theme.textTheme.titleLarge?.copyWith(fontSize: 16, color: AppTheme.primary))
                          else
                            Text(l10n.etbAmount('0.00'), 
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

  void _showShopSelector(BuildContext context, List<Shop> shops, Shop? selectedShop, AppLocalizations l10n) {
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
            Text(l10n.switchShop, style: Theme.of(context).textTheme.bodySmall?.copyWith(letterSpacing: 2, fontWeight: FontWeight.bold)),
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
            SaaSButton(label: l10n.addNewShop, variant: SaaSButtonVariant.secondary, icon: Icons.add, onPressed: () {
              Navigator.pop(context);
              _showCreateShopDialog(l10n);
            }),
          ],
        ),
      ),
    );
  }

  void _showCreateShopDialog(AppLocalizations l10n) {
    final nameController = TextEditingController();
    final typeController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.createNewShop),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: l10n.shopNameLabel)),
            const SizedBox(height: 16),
            TextField(controller: typeController, decoration: InputDecoration(labelText: l10n.businessType)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          SaaSButton(
            label: l10n.create,
            isFullWidth: false,
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              await ref.read(shopsListProvider.notifier).createNewShop(name: nameController.text.trim(), businessType: typeController.text);
              if (ctx.mounted) Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}
