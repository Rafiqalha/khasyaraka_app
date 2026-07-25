import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'design_tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceLight,
        background: AppColors.backgroundLight,
        error: AppColors.danger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimaryLight,
        onBackground: AppColors.textPrimaryLight,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        displayMedium: AppTextStyles.h2.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        displaySmall: AppTextStyles.h3.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        headlineLarge: AppTextStyles.h1.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        headlineMedium: AppTextStyles.h2.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        headlineSmall: AppTextStyles.h3.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        titleLarge: AppTextStyles.h3.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        titleMedium: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimaryLight,
        ),
        titleSmall: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimaryLight,
        ),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        bodySmall: AppTextStyles.caption.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        labelLarge: AppTextStyles.button.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        labelSmall: AppTextStyles.caption.copyWith(
          color: AppColors.textPrimaryLight,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.h2.copyWith(color: AppColors.textPrimaryLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.button,
          elevation: 0, // Flat design token
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.m),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusS),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.l,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusS,
          borderSide: const BorderSide(color: AppColorTokens.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusS,
          borderSide: const BorderSide(color: AppColorTokens.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusS,
          borderSide: const BorderSide(color: AppColorTokens.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusS,
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColorTokens.textTertiary),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceDark,
        background: AppColors.backgroundDark,
        error: AppColors.danger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimaryDark,
        onBackground: AppColors.textPrimaryDark,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        displayMedium: AppTextStyles.h2.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        displaySmall: AppTextStyles.h3.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        headlineLarge: AppTextStyles.h1.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        headlineMedium: AppTextStyles.h2.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        headlineSmall: AppTextStyles.h3.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        titleLarge: AppTextStyles.h3.copyWith(color: AppColors.textPrimaryDark),
        titleMedium: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimaryDark,
        ),
        titleSmall: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimaryDark,
        ),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        bodySmall: AppTextStyles.caption.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        labelLarge: AppTextStyles.button.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        labelSmall: AppTextStyles.caption.copyWith(
          color: AppColors.textPrimaryDark,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.h2.copyWith(color: AppColors.textPrimaryDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.button,
          elevation: 0, // Flat design token
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.m),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusS),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.l,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusS,
          borderSide: const BorderSide(color: Color(0xFF424242)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusS,
          borderSide: const BorderSide(color: Color(0xFF424242)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusS,
          borderSide: const BorderSide(color: AppColorTokens.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusS,
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColorTokens.textTertiary),
      ),
    );
  }
}
