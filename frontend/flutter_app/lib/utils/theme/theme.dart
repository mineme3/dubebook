import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme_extension.dart';

class DubeTheme {
  static SaaSTokens get lightSaaSTokens => const SaaSTokens(
        surfaceBorder: Color(0xFFE2E8F0),
        successMuted: Color(0xFFD1FAE5),
        warningMuted: Color(0xFFFEF3C7),
        errorMuted: Color(0xFFFEE2E2),
        infoMuted: Color(0xFFE0F2FE),
        textMuted: Color(0xFF64748B),
        shimmerGradient: LinearGradient(
          colors: [
            Color(0xFFE2E8F0),
            Color(0xFFF1F5F9),
            Color(0xFFE2E8F0),
          ],
          stops: [0.1, 0.3, 0.4],
          begin: Alignment(-1.0, -0.3),
          end: Alignment(1.0, 0.3),
          tileMode: TileMode.clamp,
        ),
        surfaceLow: Color(0xFFF8FAFC),
        surfaceHigh: Color(0xFFF1F5F9),
        onSurfaceMuted: Color(0xFF64748B),
        warning: Color(0xFFD97706),
        info: Color(0xFF2563EB),
      );

  static SaaSTokens get darkSaaSTokens => lightSaaSTokens; // Adapt to match previous light style

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: Color(0xFF0F172A)),
          displayMedium: TextStyle(color: Color(0xFF0F172A)),
          displaySmall: TextStyle(color: Color(0xFF0F172A)),
          headlineLarge: TextStyle(color: Color(0xFF0F172A)),
          headlineMedium: TextStyle(color: Color(0xFF0F172A)),
          headlineSmall: TextStyle(color: Color(0xFF0F172A)),
          titleLarge: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: Color(0xFF0F172A)),
          titleSmall: TextStyle(color: Color(0xFF0F172A)),
          bodyLarge: TextStyle(color: Color(0xFF0F172A)),
          bodyMedium: TextStyle(color: Color(0xFF0F172A)),
          bodySmall: TextStyle(color: Color(0xFF64748B)),
          labelLarge: TextStyle(color: Color(0xFF0F172A)),
          labelMedium: TextStyle(color: Color(0xFF64748B)),
          labelSmall: TextStyle(color: Color(0xFF64748B)),
        ),
      ),
      scaffoldBackgroundColor: Colors.white,
      primaryColor: const Color(0xFF1E3A8A),
      extensions: [lightSaaSTokens],
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1E3A8A),
        secondary: Color(0xFF059669),
        surface: Color(0xFFF8FAFC),
        onSurface: Color(0xFF0F172A),
        error: Color(0xFFDC2626),
        outline: Color(0xFFE2E8F0),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: Color(0xFF0F172A)),

      // AppBar Style
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
        iconTheme: IconThemeData(color: Color(0xFF0F172A)),
        actionsIconTheme: IconThemeData(color: Color(0xFF0F172A)),
      ),

      // Buttons Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1E3A8A),
          side: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
        prefixIconColor: const Color(0xFF1E3A8A),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: const Color(0xFF64748B).withOpacity(0.1)),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF1E3A8A),
        unselectedItemColor: Color(0xFF64748B),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme; // Adapt to match previous light style
}
