import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../services/locale_service.dart';
import '../core/providers/auth_provider.dart';
import '../utils/theme.dart';
import '../main.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final authState = ref.watch(authNotifierProvider);
    final owner = authState.owner;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(l.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (owner != null) ...[
            _buildSectionHeader('OWNER PROFILE'),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.textSecondary.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppTheme.primaryBlue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          owner.fullName,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          owner.email,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          owner.phone,
                          style: TextStyle(
                            color: AppTheme.textSecondary.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          _buildSectionHeader(l.language.toUpperCase()),
          _buildSettingsTile(
            icon: Icons.translate_rounded,
            title: Text(
              l.language,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              l.languageDescription,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            onTap: () => _showLanguageDialog(context),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('ACCOUNT SECURITY'),
          _buildSettingsTile(
            icon: Icons.logout_rounded,
            title: const Text(
              'Logout',
              style: TextStyle(
                color: AppTheme.error,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text(
              'Sign out from this device',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppTheme.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.error)),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await ref.read(authNotifierProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(l.applicationInfo),
          _buildSettingsTile(
            icon: Icons.auto_awesome_rounded,
            title: Text(
              l.appName,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              l.version,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          _buildSettingsTile(
            icon: Icons.cloud_done_rounded,
            title: const Text(
              'Cloud Architecture',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text(
              'Synchronized with MongoDB Atlas',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 48),
          Center(
            child: Opacity(
              opacity: 0.2,
              child: Column(
                children: [
                  const Icon(Icons.wallet_rounded, size: 48, color: AppTheme.primaryBlue),
                  const SizedBox(height: 8),
                  Text(
                    l.appName,
                    style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 4, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.copyright,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l.changeLanguage, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(ctx, 'English', 'en'),
            const SizedBox(height: 10),
            _buildLanguageOption(ctx, 'አማርኛ', 'am'),
            const SizedBox(height: 10),
            _buildLanguageOption(ctx, 'Afan Oromo', 'om'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel, style: const TextStyle(color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String name, String code) {
    return GestureDetector(
      onTap: () async {
        await LocaleService.setLocale(code);
        if (context.mounted) {
          DubeNoteApp.setLocale(context, Locale(code));
          Navigator.pop(context);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  code.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppTheme.primaryBlue),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.textPrimary),
            ),
            const Spacer(),
            const Icon(Icons.check_circle_outline_rounded, color: AppTheme.primaryBlue, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.primaryBlue,
          fontWeight: FontWeight.w900,
          fontSize: 12,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({required IconData icon, required dynamic title, dynamic subtitle, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.textSecondary.withOpacity(0.1)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryBlue, size: 24),
        ),
        title: title is String
            ? Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w800, fontSize: 16))
            : title,
        subtitle: subtitle != null
            ? (subtitle is String
                ? Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500))
                : subtitle)
            : null,
        trailing: onTap != null ? const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.textSecondary, size: 16) : null,
      ),
    );
  }
}