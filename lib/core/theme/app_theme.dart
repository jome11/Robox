import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        surface: AppColors.surface,
        onSurface: AppColors.text,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.text),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.headline,
        bodyMedium: AppTextStyles.body,
        labelSmall: AppTextStyles.label,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
    );
  }
}
