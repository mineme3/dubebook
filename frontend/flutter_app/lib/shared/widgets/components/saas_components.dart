import 'package:flutter/material.dart';
import '../../../utils/theme.dart';

enum SaaSButtonVariant { primary, secondary, ghost }

class SaaSButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final SaaSButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const SaaSButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = SaaSButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DubeTokens>()!;

    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min, // don't force max width unless isFullWidth wraps it
      children: [
        if (isLoading)
          const SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.background),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, size: 18, color: variant == SaaSButtonVariant.primary ? AppTheme.background : theme.colorScheme.primary),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ],
      ],
    );

    if (isFullWidth) {
      content = SizedBox(width: double.infinity, child: content);
    }

    switch (variant) {
      case SaaSButtonVariant.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: AppTheme.background,
          ),
          child: content,
        );
      case SaaSButtonVariant.secondary:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: tokens.surfaceHigh),
            foregroundColor: theme.colorScheme.onSurface,
          ),
          child: content,
        );
      case SaaSButtonVariant.ghost:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
          ),
          child: content,
        );
    }
  }
}

class SaaSCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;

  const SaaSCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<DubeTokens>()!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tokens.surfaceBorder),
        ),
        child: child,
      ),
    );
  }
}

class SaaSStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? trend;
  final IconData? icon;
  final Color? valueColor;
  final bool usePrimaryColor;

  const SaaSStatCard({
    super.key,
    required this.label,
    required this.value,
    this.trend,
    this.icon,
    this.valueColor,
    this.usePrimaryColor = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DubeTokens>()!;
    final isPrimary = usePrimaryColor;

    final textColor = isPrimary ? AppTheme.background.withOpacity(0.7) : tokens.onSurfaceMuted;
    final valueTextColor = isPrimary ? AppTheme.background : (valueColor ?? theme.colorScheme.onSurface);
    final iconColor = isPrimary ? AppTheme.background.withOpacity(0.7) : tokens.onSurfaceMuted;

    return SaaSCard(
      color: isPrimary ? theme.primaryColor : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // label needs bounding too — long labels + icon on narrow cards will overflow
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 4),
                Icon(icon, size: 16, color: iconColor),
              ],
            ],
          ),
          const SizedBox(height: 8),
          // value is the real risk here: currency strings from live data
          // (e.g. "ETB 1,250,000.00") will overflow a fixed-width stat card
          // long before a UI label ever would.
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: 24,
              color: valueTextColor,
            ),
          ),
          if (trend != null) ...[
            const SizedBox(height: 4),
            Text(
              trend!,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isPrimary ? tokens.onSurfaceMuted : theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SaaSSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SaaSSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<DubeTokens>()!;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: tokens.surfaceHigh.withOpacity(0.5),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class SaaSEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SaaSEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DubeTokens>()!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: tokens.surfaceLow,
                shape: BoxShape.circle,
                border: Border.all(color: tokens.surfaceBorder),
              ),
              child: Icon(icon, size: 48, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 32),
              SaaSButton(
                label: actionLabel!,
                onPressed: onAction,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}