import 'package:flutter/material.dart';

class SaaSTokens extends ThemeExtension<SaaSTokens> {
  final Color surfaceBorder;
  final Color successMuted;
  final Color warningMuted;
  final Color errorMuted;
  final Color infoMuted;
  final Color textMuted;
  final LinearGradient shimmerGradient;

  // Backward-compatibility properties
  final Color surfaceLow;
  final Color surfaceHigh;
  final Color onSurfaceMuted;
  final Color warning;
  final Color info;

  const SaaSTokens({
    required this.surfaceBorder,
    required this.successMuted,
    required this.warningMuted,
    required this.errorMuted,
    required this.infoMuted,
    required this.textMuted,
    required this.shimmerGradient,
    required this.surfaceLow,
    required this.surfaceHigh,
    required this.onSurfaceMuted,
    required this.warning,
    required this.info,
  });

  @override
  ThemeExtension<SaaSTokens> copyWith({
    Color? surfaceBorder,
    Color? successMuted,
    Color? warningMuted,
    Color? errorMuted,
    Color? infoMuted,
    Color? textMuted,
    LinearGradient? shimmerGradient,
    Color? surfaceLow,
    Color? surfaceHigh,
    Color? onSurfaceMuted,
    Color? warning,
    Color? info,
  }) {
    return SaaSTokens(
      surfaceBorder: surfaceBorder ?? this.surfaceBorder,
      successMuted: successMuted ?? this.successMuted,
      warningMuted: warningMuted ?? this.warningMuted,
      errorMuted: errorMuted ?? this.errorMuted,
      infoMuted: infoMuted ?? this.infoMuted,
      textMuted: textMuted ?? this.textMuted,
      shimmerGradient: shimmerGradient ?? this.shimmerGradient,
      surfaceLow: surfaceLow ?? this.surfaceLow,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      onSurfaceMuted: onSurfaceMuted ?? this.onSurfaceMuted,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  ThemeExtension<SaaSTokens> lerp(
      ThemeExtension<SaaSTokens>? other, double t) {
    if (other is! SaaSTokens) return this;
    return SaaSTokens(
      surfaceBorder: Color.lerp(surfaceBorder, other.surfaceBorder, t)!,
      successMuted: Color.lerp(successMuted, other.successMuted, t)!,
      warningMuted: Color.lerp(warningMuted, other.warningMuted, t)!,
      errorMuted: Color.lerp(errorMuted, other.errorMuted, t)!,
      infoMuted: Color.lerp(infoMuted, other.infoMuted, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      shimmerGradient: LinearGradient.lerp(shimmerGradient, other.shimmerGradient, t)!,
      surfaceLow: Color.lerp(surfaceLow, other.surfaceLow, t)!,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      onSurfaceMuted: Color.lerp(onSurfaceMuted, other.onSurfaceMuted, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}
