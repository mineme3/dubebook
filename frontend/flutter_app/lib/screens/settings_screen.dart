import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../services/locale_service.dart';
import '../core/providers/auth_provider.dart';
import '../core/providers/shop_provider.dart';
import '../core/models/shop.dart';
import '../core/models/owner.dart';
import '../utils/theme.dart';
import '../main.dart';
import '../shared/widgets/components/saas_components.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final authState = ref.watch(authNotifierProvider);
    final owner = authState.owner;
    final selectedShop = ref.watch(selectedShopProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (owner != null) ...[
            _buildSectionHeader(context, l.account),
            SaaSCard(
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primary,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(owner.fullName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                        Text(owner.email, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppTheme.primary),
                    onPressed: () => _showEditProfileDialog(context, ref, owner, l),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (owner != null && owner.role == 'SHOP_OWNER' && selectedShop != null) ...[
            _buildSectionHeader(context, l.shopDetails),
            SaaSCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.storefront, color: AppTheme.primary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(selectedShop.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                            Text(selectedShop.businessType.toUpperCase(), style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SaaSButton(
                    label: l.editShopDetails, 
                    variant: SaaSButtonVariant.secondary, 
                    icon: Icons.edit_outlined, 
                    onPressed: () => _showEditShopDialog(context, ref, selectedShop, l)
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          _buildSectionHeader(context, l.preferences),
          _buildSettingsTile(
            context,
            icon: Icons.translate,
            title: l.language,
            subtitle: l.languageDescription,
            onTap: () => _showLanguageDialog(context),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, l.dangerZone),
          SaaSButton(
            label: l.signOut,
            variant: SaaSButtonVariant.ghost,
            icon: Icons.logout_rounded,
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
          const SizedBox(height: 48),
          Center(
            child: Opacity(
              opacity: 0.3,
              child: Column(
                children: [
                  const Icon(Icons.shield_moon_outlined, size: 48),
                  const SizedBox(height: 8),
                  Text('${l.appName} SaaS v1.0', style: Theme.of(context).textTheme.bodySmall?.copyWith(letterSpacing: 2, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(letterSpacing: 1.5, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSettingsTile(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SaaSCard(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.changeLanguage),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(name: 'English', code: 'en'),
            _LanguageOption(name: 'አማርኛ', code: 'am'),
            _LanguageOption(name: 'Afan Oromo', code: 'om'),
            _LanguageOption(name: 'Af Soomaali', code: 'so'),
          ],
        ),
      ),
    );
  }

  void _showEditShopDialog(BuildContext context, WidgetRef ref, Shop shop, AppLocalizations l) {
    final name = TextEditingController(text: shop.name);
    final type = TextEditingController(text: shop.businessType);
    final phone = TextEditingController(text: shop.phone ?? '');
    final email = TextEditingController(text: shop.email ?? '');
    final address = TextEditingController(text: shop.address ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.editShop),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: InputDecoration(labelText: l.shopNameLabel)),
              const SizedBox(height: 16),
              TextField(controller: type, decoration: InputDecoration(labelText: l.businessType)),
              const SizedBox(height: 16),
              TextField(controller: phone, decoration: InputDecoration(labelText: l.phone)),
              const SizedBox(height: 16),
              TextField(controller: email, decoration: InputDecoration(labelText: l.email)),
              const SizedBox(height: 16),
              TextField(controller: address, decoration: InputDecoration(labelText: l.address)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          SaaSButton(
            label: l.save,
            isFullWidth: false,
            onPressed: () async {
              if (name.text.isEmpty) return;
              await ref.read(shopsListProvider.notifier).updateShopDetails(
                shop.id,
                name: name.text.trim(),
                businessType: type.text.trim(),
                phone: phone.text.trim().isEmpty ? null : phone.text.trim(),
                email: email.text.trim().isEmpty ? null : email.text.trim(),
                address: address.text.trim().isEmpty ? null : address.text.trim(),
                ref: ref,
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, Owner owner, AppLocalizations l) {
    final fullName = TextEditingController(text: owner.fullName);
    final phone = TextEditingController(text: owner.phone);
    final email = TextEditingController(text: owner.email);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.editProfile),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: fullName, decoration: InputDecoration(labelText: l.fullName)),
              const SizedBox(height: 16),
              TextField(controller: phone, decoration: InputDecoration(labelText: l.phoneNumber)),
              const SizedBox(height: 16),
              TextField(controller: email, decoration: InputDecoration(labelText: l.emailAddress)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          SaaSButton(
            label: l.save,
            isFullWidth: false,
            onPressed: () async {
              if (fullName.text.isEmpty || phone.text.isEmpty || email.text.isEmpty) return;
              try {
                await ref.read(authNotifierProvider.notifier).updateProfile(
                  fullName: fullName.text.trim(),
                  phone: phone.text.trim(),
                  email: email.text.trim(),
                );
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text(l.updateProfileFailed(e.toString()))),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends ConsumerWidget {
  final String name;
  final String code;
  const _LanguageOption({required this.name, required this.code});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(name),
      onTap: () async {
        await LocaleService.setLocale(code);
        if (context.mounted) {
          DubeNoteApp.setLocale(context, Locale(code));
          Navigator.pop(context);
        }
      },
    );
  }
}
