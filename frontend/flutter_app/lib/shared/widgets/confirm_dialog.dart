import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../l10n/app_localizations.dart';

Future<bool> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String? confirmText,
  String? cancelText,
  bool isDestructive = false,
}) async {
  final l10n = AppLocalizations.of(context);
  final actualConfirmText = confirmText ?? l10n?.confirm ?? 'Confirm';
  final actualCancelText = cancelText ?? l10n?.cancel ?? 'Cancel';

  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title, style: TextStyle(color: isDestructive ? AppTheme.error : null)),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(actualCancelText, style: const TextStyle(color: AppTheme.textMuted)),
        ),
        ElevatedButton(
          style: isDestructive ? ElevatedButton.styleFrom(backgroundColor: AppTheme.error) : null,
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(actualConfirmText),
        ),
      ],
    ),
  );
  return result ?? false;
}
