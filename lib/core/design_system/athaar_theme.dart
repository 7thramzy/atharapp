import 'package:athaar/core/design_system/athaar_colors.dart';
import 'package:flutter/material.dart';

abstract final class AthaarTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AthaarColors.petrol,
      brightness: Brightness.light,
    ).copyWith(
      primary: AthaarColors.petrol,
      onPrimary: Colors.white,
      secondary: AthaarColors.mutedGold,
      surface: AthaarColors.lightSurface,
      onSurface: AthaarColors.lightText,
      surfaceContainer: AthaarColors.lightSurfaceAlt,
      outline: const Color(0xFFB8C2C5),
      error: AthaarColors.error,
    );

    return _build(
      colorScheme: scheme,
      scaffoldBackgroundColor: AthaarColors.lightBackground,
      mutedTextColor: AthaarColors.lightTextMuted,
    );
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: AthaarColors.petrol,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFF61BED0),
      onPrimary: const Color(0xFF002F3A),
      secondary: const Color(0xFFD0B67D),
      surface: AthaarColors.darkSurface,
      onSurface: AthaarColors.darkText,
      surfaceContainer: AthaarColors.darkSurfaceAlt,
      outline: const Color(0xFF52636B),
      error: const Color(0xFFFFB4AB),
    );

    return _build(
      colorScheme: scheme,
      scaffoldBackgroundColor: AthaarColors.darkBackground,
      mutedTextColor: AthaarColors.darkTextMuted,
    );
  }

  static ThemeData _build({
    required ColorScheme colorScheme,
    required Color scaffoldBackgroundColor,
    required Color mutedTextColor,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      dividerColor: colorScheme.outlineVariant,
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackgroundColor,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.55)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.13),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ).copyWith(
        bodySmall: base.textTheme.bodySmall?.copyWith(color: mutedTextColor),
      ),
    );
  }
}
