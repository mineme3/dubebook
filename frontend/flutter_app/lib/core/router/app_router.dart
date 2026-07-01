import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/api_client_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../screens/dashboard_screen.dart';
import '../../screens/customer_detail_screen.dart';
import '../../features/credits/screens/add_credit_item_screen.dart';
import '../../features/payments/screens/record_payment_screen.dart';
import '../../features/notifications/screens/notification_log_screen.dart';
import '../../screens/settings_screen.dart';
import '../../shared/widgets/layouts/scaffold_with_navbar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorDashboardKey = GlobalKey<NavigatorState>(debugLabel: 'dashboard');
final _shellNavigatorNotificationsKey = GlobalKey<NavigatorState>(debugLabel: 'notifications');
final _shellNavigatorSettingsKey = GlobalKey<NavigatorState>(debugLabel: 'settings');

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  final router = GoRouter(
    initialLocation: '/login',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      final isOnLogin = state.matchedLocation == '/login';
      final isOnRegister = state.matchedLocation == '/register';
      final isAuthRoute = isOnLogin || isOnRegister;

      if (isLoading) return null;
      if (!isAuth && !isAuthRoute) return '/login';
      if (isAuth && isAuthRoute) return '/dashboard';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Customer detail routes (full-screen, outside shell)
      GoRoute(
        path: '/customers/:id',
        name: 'customerDetail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final customerId = state.pathParameters['id']!;
          return CustomerDetailScreen(customerId: customerId);
        },
        routes: [
          GoRoute(
            path: 'add-item',
            name: 'addCreditItem',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) {
              final customerId = state.pathParameters['id']!;
              return AddCreditItemScreen(customerId: customerId);
            },
          ),
          GoRoute(
            path: 'record-payment',
            name: 'recordPayment',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) {
              final customerId = state.pathParameters['id']!;
              final outstandingBalance =
                  (state.extra as Map<String, dynamic>?)?['outstandingBalance']
                      as double? ?? 0.0;
              return RecordPaymentScreen(
                customerId: customerId,
                outstandingBalance: outstandingBalance,
              );
            },
          ),
        ],
      ),

      // 3-branch shell: Dashboard, Notifications, Settings
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorDashboardKey,
            routes: [
              GoRoute(
                path: '/dashboard',
                name: 'dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorNotificationsKey,
            routes: [
              GoRoute(
                path: '/notifications',
                name: 'notifications',
                builder: (context, state) => const NotificationLogScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSettingsKey,
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  globalAuthErrorCallback = () {
    ref.read(authNotifierProvider.notifier).logout();
  };

  return router;
});
