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

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  final router = GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      final isOnLogin = state.matchedLocation == '/login';
      final isOnRegister = state.matchedLocation == '/register';
      final isAuthRoute = isOnLogin || isOnRegister;

      // Still checking auth state — don't redirect yet
      if (isLoading) return null;

      // Not authenticated and not on auth routes → redirect to login
      if (!isAuth && !isAuthRoute) return '/login';

      // Authenticated but still on auth routes → redirect to dashboard
      if (isAuth && isAuthRoute) return '/dashboard';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/customers/:id',
        name: 'customerDetail',
        builder: (context, state) {
          final customerId = state.pathParameters['id']!;
          return CustomerDetailScreen(customerId: customerId);
        },
        routes: [
          GoRoute(
            path: 'add-item',
            name: 'addCreditItem',
            builder: (context, state) {
              final customerId = state.pathParameters['id']!;
              return AddCreditItemScreen(customerId: customerId);
            },
          ),
          GoRoute(
            path: 'record-payment',
            name: 'recordPayment',
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
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationLogScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );

  // Set the global auth error callback to trigger logout
  globalAuthErrorCallback = () {
    ref.read(authNotifierProvider.notifier).logout();
  };

  return router;
});
