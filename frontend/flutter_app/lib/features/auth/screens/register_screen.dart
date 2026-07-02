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
                    Text(l10n.joinDubebook, style: theme.textTheme.headlineMedium?.copyWith(
                      letterSpacing: 2,
                      fontWeight: FontWeight.w900,
                    )),
                    const SizedBox(height: 4),
                    Text(l10n.startManagingCredit, style: theme.textTheme.bodySmall?.copyWith(
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    )),
                    const SizedBox(height: 48),

                    // Role Selection
                    Row(
                      children: [
                        Expanded(child: _RoleButton(label: l10n.retailer, isSelected: _selectedRole == 'SHOP_OWNER', onTap: () => setState(() => _selectedRole = 'SHOP_OWNER'))),
                        const SizedBox(width: 12),
                        Expanded(child: _RoleButton(label: l10n.customer, isSelected: _selectedRole == 'CUSTOMER', onTap: () => setState(() => _selectedRole = 'CUSTOMER'))),
                      ],
                    ),
                    const SizedBox(height: 32),

                    _field(_fullName, l10n.fullName, Icons.person_outline, l10n.required),
                    const SizedBox(height: 16),
                    _field(_username, l10n.username, Icons.alternate_email, l10n.required),
                    const SizedBox(height: 16),
                    _field(_phone, l10n.phoneNumber, Icons.phone_outlined, l10n.required, kb: TextInputType.phone),
                    const SizedBox(height: 16),
                    _field(_email, l10n.emailAddress, Icons.email_outlined, l10n.required, kb: TextInputType.emailAddress),
                    
                    if (_selectedRole == 'SHOP_OWNER') ...[
                      const SizedBox(height: 16),
                      _field(_shopName, l10n.shopNameLabel, Icons.storefront_outlined, l10n.required),
                    ],

                    const SizedBox(height: 16),
                    _field(_password, l10n.password, Icons.lock_outline, l10n.required, obscure: true),
                    const SizedBox(height: 32),

                    SaaSButton(label: l10n.createAccountBtn, isLoading: _loading, onPressed: _register),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l10n.haveAccount, style: TextStyle(color: tokens.onSurfaceMuted)),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Text(l10n.signIn, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
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

  Widget _field(TextEditingController c, String l, IconData i, String requiredMsg, {TextInputType kb = TextInputType.text, bool obscure = false}) =>
      TextFormField(
        controller: c,
        keyboardType: kb,
        obscureText: obscure,
        decoration: InputDecoration(labelText: l, prefixIcon: Icon(i)),
        validator: (v) => (v == null || v.isEmpty) ? requiredMsg : null,
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
