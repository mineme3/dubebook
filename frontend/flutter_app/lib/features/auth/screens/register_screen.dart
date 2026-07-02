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

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    String shopName = _shopName.text.trim();
    if (_selectedRole == 'SHOP_OWNER' && shopName.isEmpty) {
      final promptedName = await showDialog<String>(
        context: context,
        builder: (ctx) {
          final controller = TextEditingController();
          return AlertDialog(
            title: const Text('Enter Shop Name'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Shop Name',
                hintText: 'e.g., Alazar Grocery',
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                child: const Text('CONTINUE'),
              ),
            ],
          );
        },
      );
      if (promptedName == null || promptedName.isEmpty) return;
      shopName = promptedName;
      _shopName.text = shopName;
    }

    if (!mounted) return;
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
              const Divider(height: 1),
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.add)),
                title: const Text('Use another account', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final customAcc = await showDialog<Map<String, String>>(
                    context: context,
                    builder: (dialCtx) {
                      final nameCtrl = TextEditingController();
                      final emailCtrl = TextEditingController();
                      return AlertDialog(
                        title: const Text('Mock Google Account'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
                            const SizedBox(height: 12),
                            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address')),
                          ],
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(dialCtx), child: const Text('CANCEL')),
                          ElevatedButton(
                            onPressed: () {
                              if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty) return;
                              Navigator.pop(dialCtx, {
                                'name': nameCtrl.text,
                                'email': emailCtrl.text,
                                'id': 'google_custom_${DateTime.now().millisecondsSinceEpoch}'
                              });
                            },
                            child: const Text('SIGN IN'),
                          ),
                        ],
                      );
                    },
                  );
                  if (customAcc != null && mounted) {
                    _loginGoogleUser(customAcc, shopName);
                  }
                },
              ),
            ],
          ),
        );
      },
    );

    if (selectedAccount != null && mounted) {
      _loginGoogleUser(selectedAccount, shopName);
    }
  }

  Future<void> _loginGoogleUser(Map<String, String> account, String shopName) async {
    setState(() => _loading = true);
    final success = await ref.read(authNotifierProvider.notifier).loginWithGoogle(
      email: account['email']!,
      fullName: account['name']!,
      googleId: account['id']!,
      shopName: _selectedRole == 'SHOP_OWNER' ? shopName : null,
      role: _selectedRole,
    );
    if (mounted) {
      setState(() => _loading = false);
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
          border: Border.all(color: isSelected ? AppTheme.primary : tokens.surfaceBorder),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isSelected ? AppTheme.background : tokens.onSurfaceMuted,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
