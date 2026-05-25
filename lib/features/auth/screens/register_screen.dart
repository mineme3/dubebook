import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../utils/theme.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPw = TextEditingController();
  final _shopName = TextEditingController();
  final _telegram = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final ok = await ref.read(authNotifierProvider.notifier).register(
      fullName: _fullName.text.trim(), phone: _phone.text.trim(),
      email: _email.text.trim(), password: _password.text,
      shopName: _shopName.text.trim(),
      telegramChatId: _telegram.text.trim().isEmpty ? null : _telegram.text.trim(),
    );
    if (mounted) { setState(() => _loading = false); if (ok) context.go('/dashboard'); }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final err = auth.error != null && !auth.isAuthenticated && !_loading;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            IconButton(icon: const Icon(Icons.arrow_back_ios_rounded, size: 20), onPressed: () => context.go('/login')),
            const Expanded(child: Text('CREATE ACCOUNT', textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 3, color: AppTheme.textPrimary))),
            const SizedBox(width: 48),
          ]),
          const SizedBox(height: 8),
          Center(child: Text('Set up your shop on the cloud',
            style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w600))),
          const SizedBox(height: 32),
          if (err) Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 20), padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.error.withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
            child: Text(auth.error ?? 'Registration failed', style: const TextStyle(color: AppTheme.error, fontSize: 12, fontWeight: FontWeight.w600))),
          _label('OWNER INFORMATION'), const SizedBox(height: 12),
          _field(_fullName, 'Full Name', Icons.person_outline_rounded, v: (s) => s != null && s.length >= 2 ? null : 'Min 2 chars'),
          const SizedBox(height: 16),
          _field(_phone, 'Phone Number', Icons.phone_outlined, kb: TextInputType.phone, v: (s) => s != null && s.isNotEmpty ? null : 'Required'),
          const SizedBox(height: 16),
          _field(_email, 'Email', Icons.email_outlined, kb: TextInputType.emailAddress, v: (s) { if (s == null || s.isEmpty) return 'Required'; if (!s.contains('@')) return 'Invalid'; return null; }),
          const SizedBox(height: 28), _label('SHOP DETAILS'), const SizedBox(height: 12),
          _field(_shopName, 'Shop Name', Icons.storefront_rounded, v: (s) => s != null && s.isNotEmpty ? null : 'Required'),
          const SizedBox(height: 16),
          _field(_telegram, 'Telegram Chat ID (optional)', Icons.telegram_rounded),
          const SizedBox(height: 28), _label('SECURITY'), const SizedBox(height: 12),
          TextFormField(controller: _password, obscureText: _obscure,
            style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
            decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
              suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20, color: AppTheme.textSecondary),
                onPressed: () => setState(() => _obscure = !_obscure))),
            validator: (v) { if (v == null || v.isEmpty) return 'Required'; if (v.length < 6) return 'Min 6 chars'; return null; }),
          const SizedBox(height: 16),
          TextFormField(controller: _confirmPw, obscureText: true,
            style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(labelText: 'Confirm Password', prefixIcon: Icon(Icons.lock_outline_rounded, size: 20)),
            validator: (v) => v != _password.text ? 'Passwords do not match' : null),
          const SizedBox(height: 40),
          Container(width: double.infinity, height: 64, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(colors: [AppTheme.accentGreen, AppTheme.accentGreen.withGreen(200)]),
            boxShadow: [BoxShadow(color: AppTheme.accentGreen.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))]),
            child: ElevatedButton(onPressed: _loading ? null : _register,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: _loading ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white)))
                : const Text('CREATE ACCOUNT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16, color: Colors.white)))),
          const SizedBox(height: 24),
          Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Already have an account?  ', style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w600)),
            GestureDetector(onTap: () => context.go('/login'), child: const Text('Login', style: TextStyle(color: AppTheme.primaryBlue, fontSize: 12, fontWeight: FontWeight.w900))),
          ])),
          const SizedBox(height: 20),
        ])))),
    );
  }

  Widget _label(String t) => Text(t, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2, color: AppTheme.textSecondary.withOpacity(0.5)));

  Widget _field(TextEditingController c, String l, IconData i, {TextInputType kb = TextInputType.text, String? Function(String?)? v}) =>
    TextFormField(controller: c, keyboardType: kb, textCapitalization: kb == TextInputType.text ? TextCapitalization.words : TextCapitalization.none,
      style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
      decoration: InputDecoration(labelText: l, prefixIcon: Icon(i, size: 20)), validator: v);

  @override
  void dispose() { _fullName.dispose(); _phone.dispose(); _email.dispose(); _password.dispose(); _confirmPw.dispose(); _shopName.dispose(); _telegram.dispose(); super.dispose(); }
}
