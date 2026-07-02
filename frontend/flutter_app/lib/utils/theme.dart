import 'package:flutter/material.dart';

// Export all the new Design System and Theme Foundation files
export 'theme/app_typography.dart';
export 'theme/app_spacing.dart';
export 'theme/app_radius.dart';
export 'theme/app_breakpoints.dart';
export 'theme/app_theme_extension.dart';
export 'theme/theme.dart';

import 'theme/theme.dart';
import 'theme/app_theme_extension.dart';

// Alias for backwards compatibility of theme extensions
typedef DubeTokens = SaaSTokens;

/// Backward compatibility layer for AppTheme reference throughout the app
class AppTheme {
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFF8FAFC);
  static const Color primary = Color(0xFF1E3A8A);
  static const Color accent = Color(0xFF059669);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color error = Color(0xFFDC2626);

  static const Color primaryBlue = Color(0xFF1E3A8A);

  static ThemeData get darkTheme => DubeTheme.darkTheme;
  static ThemeData get lightTheme => DubeTheme.lightTheme;
}
