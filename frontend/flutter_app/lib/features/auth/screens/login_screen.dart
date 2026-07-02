import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../utils/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/components/saas_components.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_identifierController.text.isEmpty || _passwordController.text.isEmpty) return;
    setState(() => _isLoading = true);
    final input = _identifierController.text.trim();
    final isEmail = input.contains('@');
    final success = await ref.read(authNotifierProvider.notifier).login(
      email: isEmail ? input : null,
      username: isEmail ? null : input,
      password: _passwordController.text,
    );
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<DubeTokens>()!;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width > 600 ? 80.0 : 32.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shield_outlined, size: 48, color: AppTheme.primary),
                  const SizedBox(height: 24),
                  Text(l10n.dubebook, style: theme.textTheme.headlineMedium?.copyWith(
                    letterSpacing: 4,
                    fontWeight: FontWeight.w900,
                  )),
                  const SizedBox(height: 4),
                  Text(l10n.secureCreditManagement, style: theme.textTheme.bodySmall?.copyWith(
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  )),
                  const SizedBox(height: 48),
                  TextField(
                    controller: _identifierController,
                    decoration: InputDecoration(labelText: l10n.emailOrUsername, prefixIcon: const Icon(Icons.person_outline)),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: l10n.password, prefixIcon: const Icon(Icons.lock_outline)),
                    onSubmitted: (_) => _login(),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _showForgotPasswordDialog(context),
                      child: Text(
                        l10n.forgotPassword,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SaaSButton(label: l10n.signIn, isLoading: _isLoading, onPressed: _login),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: Divider(color: tokens.surfaceBorder)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR', style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(child: Divider(color: tokens.surfaceBorder)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: tokens.surfaceBorder),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _handleGoogleSignIn(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://img.icons8.com/color/48/google-logo.png',
                          height: 20,
                          width: 20,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.login, color: AppTheme.primary),
                        ),
                        const SizedBox(width: 10),
                        const Text('Continue with Google', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.newHere, style: TextStyle(color: tokens.onSurfaceMuted)),
                      GestureDetector(
                        onTap: () => context.go('/register'),
                        child: Text(l10n.createAccount, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final selectedAccount = await showModalBottomSheet<Map<String, String>>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final accounts = [
          {'name': 'Salih Team', 'email': 'salih@gmail.com', 'id': 'google_123456789'},
          {'name': 'Dube Shop Owner', 'email': 'test_owner@gmail.com', 'id': 'google_owner_test'},
          {'name': 'Dube Customer', 'email': 'test_customer@gmail.com', 'id': 'google_customer_test'},
        ];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Choose an account to continue to Dubebook',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
              ),
              const Divider(height: 1),
              ...accounts.map((acc) {
                final tokens = Theme.of(ctx).extension<DubeTokens>()!;
                return ListTile(
                leading: CircleAvatar(
                  backgroundColor: tokens.infoMuted,
                  child: Text(acc['name']![0].toUpperCase(), style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                ),
                title: Text(acc['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(acc['email']!),
                onTap: () => Navigator.pop(ctx, acc),
              );
              }),
            ],
          ),
        );
      },
    );

    if (selectedAccount != null && mounted) {
      setState(() => _isLoading = true);
      final success = await ref.read(authNotifierProvider.notifier).loginWithGoogle(
        email: selectedAccount['email']!,
        fullName: selectedAccount['name']!,
        googleId: selectedAccount['id']!,
        role: selectedAccount['email']!.contains('customer') ? 'CUSTOMER' : 'SHOP_OWNER',
      );
      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          context.go('/dashboard');
        } else {
          final error = ref.read(authNotifierProvider).error ?? 'Google Login failed';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: AppTheme.error),
          );
        }
      }
    }
  }

  Future<void> _showForgotPasswordDialog(BuildContext context) async {
    final emailController = TextEditingController();
    
    final email = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Forgot Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Enter your registered email address to receive a password reset code.'),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, emailController.text.trim()),
              child: const Text('SEND CODE'),
            ),
          ],
        );
      },
    );

    if (email == null || email.isEmpty || !mounted) return;

    setState(() => _isLoading = true);
    final recoveryCode = await ref.read(authNotifierProvider.notifier).forgotPassword(email);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (recoveryCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate recovery code. Please check your email.'), backgroundColor: AppTheme.error),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Recovery Code Generated'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('A password reset code has been sent to your email (simulated).'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  recoveryCode,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primary, letterSpacing: 4),
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    final codeController = TextEditingController(text: recoveryCode);
    final newPasswordController = TextEditingController();

    final resetSuccess = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Recovery Code'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password', prefixIcon: Icon(Icons.lock_outline)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('CANCEL', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () async {
                final code = codeController.text.trim();
                final newPw = newPasswordController.text;
                if (code.isEmpty || newPw.isEmpty) return;
                
                final ok = await ref.read(authNotifierProvider.notifier).resetPassword(
                  email: email,
                  code: code,
                  newPassword: newPw,
                );
                if (mounted) {
                  Navigator.pop(ctx, ok);
                }
              },
              child: const Text('RESET PASSWORD'),
            ),
          ],
        );
      },
    );

    if (resetSuccess == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Password reset successfully! Please sign in.'), backgroundColor: AppTheme.accent),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to reset password. Check recovery code.'), backgroundColor: AppTheme.error),
      );
    }
  }
}
