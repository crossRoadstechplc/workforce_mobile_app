import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme_extension.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light(Locale? locale) => _build(AppColorsExtension.light, Brightness.light, locale);

  static ThemeData dark(Locale? locale) => _build(AppColorsExtension.dark, Brightness.dark, locale);

  static ThemeData _build(AppColorsExtension colors, Brightness brightness, Locale? locale) {
    final isAmharic = locale?.languageCode == 'am';
    final textTheme = isAmharic
        ? GoogleFonts.notoSansEthiopicTextTheme()
        : GoogleFonts.interTextTheme();

    final scheme = ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: brightness == Brightness.light ? Colors.white : const Color(0xFF0F172A),
      secondary: colors.primaryDark,
      onSecondary: Colors.white,
      error: colors.error,
      onError: Colors.white,
      surface: colors.surface,
      onSurface: colors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.background,
      textTheme: textTheme.apply(
        bodyColor: colors.textPrimary,
        displayColor: colors.textPrimary,
      ),
      fontFamily: isAmharic ? GoogleFonts.notoSansEthiopic().fontFamily : GoogleFonts.inter().fontFamily,
      fontFamilyFallback: const ['Roboto', 'Arial'],
      extensions: [colors],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: colors.border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? colors.primary : colors.textSecondary,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: brightness == Brightness.light ? Colors.white : const Color(0xFF0F172A),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: brightness == Brightness.light ? Colors.white : const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colors.primary),
      ),
      dividerColor: colors.border,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      tooltipTheme: const TooltipThemeData(waitDuration: Duration(milliseconds: 450)),
    );
  }
}
