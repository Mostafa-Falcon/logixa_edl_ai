import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      textTheme: _buildTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.topBar,
        foregroundColor: AppColors.textPrimary,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 0.5,
      ),
      iconTheme: const IconThemeData(color: AppColors.textSecondary),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base) {
    final themed = base.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return themed.copyWith(
      displayLarge: _font(themed.displayLarge),
      displayMedium: _font(themed.displayMedium),
      displaySmall: _font(themed.displaySmall),
      headlineLarge: _font(themed.headlineLarge),
      headlineMedium: _font(themed.headlineMedium),
      headlineSmall: _font(themed.headlineSmall),
      titleLarge: _font(themed.titleLarge),
      titleMedium: _font(themed.titleMedium),
      titleSmall: _font(themed.titleSmall),
      bodyLarge: _font(themed.bodyLarge),
      bodyMedium: _font(themed.bodyMedium),
      bodySmall: _font(themed.bodySmall),
      labelLarge: _font(themed.labelLarge),
      labelMedium: _font(themed.labelMedium),
      labelSmall: _font(themed.labelSmall),
    );
  }

  static TextStyle? _font(TextStyle? style) {
    if (style == null) return null;
    return style.copyWith(
      fontFamily: AppFonts.arabic,
      fontFamilyFallback: const [
        AppFonts.arabicAlt,
        AppFonts.english,
        'Arial',
        'Noto Sans Arabic',
        'sans-serif',
      ],
    );
  }
}
