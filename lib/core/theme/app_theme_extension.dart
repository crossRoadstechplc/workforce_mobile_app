import 'package:flutter/material.dart';

/// Legacy static accessors — prefer [AppColorsExtension] via [context.appColors].
class AppColors {
  AppColors._();

  static const primary = Color(0xFF2563EB);
  static const primaryDark = Color(0xFF1D4ED8);
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFD97706);
  static const error = Color(0xFFDC2626);
  static const background = Color(0xFFF8FAFC);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF475569);
  static const border = Color(0xFFE2E8F0);
  static const muted = Color(0xFFF1F5F9);
}

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.primary,
    required this.primaryDark,
    required this.success,
    required this.warning,
    required this.error,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.muted,
    required this.successBg,
    required this.warningBg,
    required this.errorBg,
    required this.mapTileUrl,
  });

  final Color primary;
  final Color primaryDark;
  final Color success;
  final Color warning;
  final Color error;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color muted;
  final Color successBg;
  final Color warningBg;
  final Color errorBg;
  final String mapTileUrl;

  static const light = AppColorsExtension(
    primary: Color(0xFF2563EB),
    primaryDark: Color(0xFF1D4ED8),
    success: Color(0xFF16A34A),
    warning: Color(0xFFD97706),
    error: Color(0xFFDC2626),
    background: Color(0xFFF8FAFC),
    surface: Colors.white,
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    border: Color(0xFFE2E8F0),
    muted: Color(0xFFF1F5F9),
    successBg: Color(0xFFDCFCE7),
    warningBg: Color(0xFFFEF3C7),
    errorBg: Color(0xFFFEE2E2),
    mapTileUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );

  static const dark = AppColorsExtension(
    primary: Color(0xFF60A5FA),
    primaryDark: Color(0xFF3B82F6),
    success: Color(0xFF4ADE80),
    warning: Color(0xFFFBBF24),
    error: Color(0xFFF87171),
    background: Color(0xFF0F172A),
    surface: Color(0xFF1E293B),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFF94A3B8),
    border: Color(0xFF334155),
    muted: Color(0xFF273449),
    successBg: Color(0xFF14532D),
    warningBg: Color(0xFF78350F),
    errorBg: Color(0xFF7F1D1D),
    mapTileUrl: 'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
  );

  @override
  AppColorsExtension copyWith({
    Color? primary,
    Color? primaryDark,
    Color? success,
    Color? warning,
    Color? error,
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? muted,
    Color? successBg,
    Color? warningBg,
    Color? errorBg,
    String? mapTileUrl,
  }) {
    return AppColorsExtension(
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      muted: muted ?? this.muted,
      successBg: successBg ?? this.successBg,
      warningBg: warningBg ?? this.warningBg,
      errorBg: errorBg ?? this.errorBg,
      mapTileUrl: mapTileUrl ?? this.mapTileUrl,
    );
  }

  @override
  AppColorsExtension lerp(covariant ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      successBg: Color.lerp(successBg, other.successBg, t)!,
      warningBg: Color.lerp(warningBg, other.warningBg, t)!,
      errorBg: Color.lerp(errorBg, other.errorBg, t)!,
      mapTileUrl: t < 0.5 ? mapTileUrl : other.mapTileUrl,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>() ?? AppColorsExtension.light;
}
