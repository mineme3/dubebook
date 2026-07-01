import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../features/notifications/screens/notification_log_screen.dart';

class ScaffoldWithNavBar extends ConsumerWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isCustomer = authState.owner?.role == 'CUSTOMER';

    // Customers don't see the bottom navbar — they use AppBar icons instead
    if (isCustomer) {
      return Scaffold(body: navigationShell);
    }

    final logsAsync = ref.watch(notificationLogProvider);
    final count = logsAsync.asData?.value.length ?? 0;

    // Shop owner navbar: Dashboard, Alerts, Settings (no separate Customers tab)
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _mapBranchToNavIndex(navigationShell.currentIndex),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: count > 0 ? Text('$count') : null,
              isLabelVisible: count > 0,
              child: const Icon(Icons.notifications_outlined),
            ),
            activeIcon: Badge(
              label: count > 0 ? Text('$count') : null,
              isLabelVisible: count > 0,
              child: const Icon(Icons.notifications),
            ),
            label: 'Alerts',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (navIndex) => _onTap(navIndex),
      ),
    );
  }

  /// Maps the StatefulShellRoute branch index to the 3-item navbar index.
  /// Branch 0 = Dashboard → nav 0
  /// Branch 1 = Notifications → nav 1
  /// Branch 2 = Settings → nav 2
  int _mapBranchToNavIndex(int branchIndex) {
    return branchIndex.clamp(0, 2);
  }

  /// Maps the 3-item navbar index back to branch index.
  void _onTap(int navIndex) {
    navigationShell.goBranch(
      navIndex,
      initialLocation: navIndex == navigationShell.currentIndex,
    );
  }
}
