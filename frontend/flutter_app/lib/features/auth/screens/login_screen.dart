import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../utils/theme.dart';
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
                  Text('DUBEBOOK', style: theme.textTheme.headlineMedium?.copyWith(
                    letterSpacing: 4,
                    fontWeight: FontWeight.w900,
                  )),
                  const SizedBox(height: 4),
                  Text('SECURE CREDIT MANAGEMENT', style: theme.textTheme.bodySmall?.copyWith(
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  )),
                  const SizedBox(height: 48),
                  TextField(
                    controller: _identifierController,
                    decoration: const InputDecoration(labelText: 'Email or Username', prefixIcon: Icon(Icons.person_outline)),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
                    onSubmitted: (_) => _login(),
                  ),
                  const SizedBox(height: 32),
                  SaaSButton(label: 'SIGN IN', isLoading: _isLoading, onPressed: _login),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("New here? ", style: TextStyle(color: tokens.onSurfaceMuted)),
                      GestureDetector(
                        onTap: () => context.go('/register'),
                        child: const Text('Create Account', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
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
}
