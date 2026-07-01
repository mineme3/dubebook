import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors (SaaS Slate / Zinc base)
  static const Color lightBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceBorder = Color(0xFFE2E8F0); // Slate 200
  static const Color lightTextPrimary = Color(0xFF0F172A); // Slate 900
  static const Color lightTextSecondary = Color(0xFF475569); // Slate 600
  static const Color lightTextMuted = Color(0xFF94A3B8); // Slate 400

  // Dark Theme Colors (SaaS OLED / Charcoal base)
  static const Color darkBackground = Color(0xFF030712); // Slate 950
  static const Color darkSurface = Color(0xFF0B0F19); // Custom deep surface
  static const Color darkSurfaceBorder = Color(0xFF1F2937); // Gray 800
  static const Color darkTextPrimary = Color(0xFFF9FAFB); // Gray 50
  static const Color darkTextSecondary = Color(0xFF9CA3AF); // Gray 400
  static const Color darkTextMuted = Color(0xFF6B7280); // Gray 500

  // Brand / Status Colors (Material 3 Financial grade)
  static const Color primaryBlue = Color(0xFF2563EB); // Stripe / Linear Blue
  static const Color primaryBlueDark = Color(0xFF3B82F6); // Lighter accent for dark mode
  
  static const Color successGreen = Color(0xFF16A34A); // Emerald 600
  static const Color successGreenDark = Color(0xFF22C55E); // Emerald 500
  static const Color successGreenMuted = Color(0xFFDCFCE7); // Light green background
  static const Color successGreenMutedDark = Color(0xFF064E3B); // Dark green background

  static const Color warningOrange = Color(0xFFD97706); // Amber 600
  static const Color warningOrangeDark = Color(0xFFF59E0B); // Amber 500
  static const Color warningOrangeMuted = Color(0xFFFEF3C7);
  static const Color warningOrangeMutedDark = Color(0xFF78350F);

  static const Color errorRed = Color(0xFFDC2626); // Rose 600
  static const Color errorRedDark = Color(0xFFEF4444); // Rose 500
  static const Color errorRedMuted = Color(0xFFFEE2E2);
  static const Color errorRedMutedDark = Color(0xFF7F1D1D);

  static const Color infoBlue = Color(0xFF0284C7); // Sky 600
  static const Color infoBlueDark = Color(0xFF38BDF8); // Sky 400
}
