import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../utils/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/components/saas_components.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPw = TextEditingController();
  final _shopName = TextEditingController();
  bool _loading = false;
  String _selectedRole = 'SHOP_OWNER';

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final ok = await ref.read(authNotifierProvider.notifier).register(
      username: _username.text.trim().toLowerCase(),
      fullName: _fullName.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      shopName: _selectedRole == 'SHOP_OWNER' ? _shopName.text.trim() : '',
      role: _selectedRole,
    );
    if (mounted) {
      setState(() => _loading = false);
      if (ok) context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);
    final tokens = theme.extension<DubeTokens>()!;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width > 600 ? 80.0 : 32.0,
              vertical: 40,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Icon(Icons.person_add_outlined, size: 48, color: AppTheme.primary),
                    const SizedBox(height: 24),
                    Text('JOIN DUBEBOOK', style: theme.textTheme.headlineMedium?.copyWith(
                      letterSpacing: 2,
                      fontWeight: FontWeight.w900,
                    )),
                    const SizedBox(height: 4),
                    Text('START MANAGING CREDIT SECURELY', style: theme.textTheme.bodySmall?.copyWith(
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    )),
                const SizedBox(height: 48),

                // Role Selection
                Row(
                  children: [
                    Expanded(child: _RoleButton(label: 'RETAILER', isSelected: _selectedRole == 'SHOP_OWNER', onTap: () => setState(() => _selectedRole = 'SHOP_OWNER'))),
                    const SizedBox(width: 12),
                    Expanded(child: _RoleButton(label: 'CUSTOMER', isSelected: _selectedRole == 'CUSTOMER', onTap: () => setState(() => _selectedRole = 'CUSTOMER'))),
                  ],
                ),
                const SizedBox(height: 32),

                _field(_fullName, 'Full Name', Icons.person_outline),
                const SizedBox(height: 16),
                _field(_username, 'Username', Icons.alternate_email),
                const SizedBox(height: 16),
                _field(_phone, 'Phone Number', Icons.phone_outlined, kb: TextInputType.phone),
                const SizedBox(height: 16),
                _field(_email, 'Email Address', Icons.email_outlined, kb: TextInputType.emailAddress),
                
                if (_selectedRole == 'SHOP_OWNER') ...[
                  const SizedBox(height: 16),
                  _field(_shopName, 'Shop Name', Icons.storefront_outlined),
                ],

                const SizedBox(height: 16),
                _field(_password, 'Password', Icons.lock_outline, obscure: true),
                const SizedBox(height: 32),

                SaaSButton(label: 'CREATE ACCOUNT', isLoading: _loading, onPressed: _register),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Have an account? ", style: TextStyle(color: tokens.onSurfaceMuted)),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: const Text('Sign In', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String l, IconData i, {TextInputType kb = TextInputType.text, bool obscure = false}) =>
      TextFormField(
        controller: c,
        keyboardType: kb,
        obscureText: obscure,
        decoration: InputDecoration(labelText: l, prefixIcon: Icon(i)),
        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
      );
}

class _RoleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleButton({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DubeTokens>()!;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : tokens.surfaceLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.primary : const Color(0xFF64748B).withOpacity(0.15)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isSelected ? Colors.white : tokens.onSurfaceMuted,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
