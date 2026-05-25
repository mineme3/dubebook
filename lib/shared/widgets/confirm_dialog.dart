import 'package:flutter/material.dart';
import '../../utils/theme.dart';

/// Shows a confirmation dialog with optional destructive styling.
/// Returns true if confirmed, false otherwise.
Future<bool> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  bool isDestructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: isDestructive ? AppTheme.error : AppTheme.textPrimary,
        ),
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(
            cancelText,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
        ),
        ElevatedButton(
          style: isDestructive
              ? ElevatedButton.styleFrom(backgroundColor: AppTheme.error)
              : null,
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmText),
        ),
      ],
    ),
  );
  return result ?? false;
}
