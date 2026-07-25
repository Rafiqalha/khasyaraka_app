import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';
import '../tokens/spacing.dart';
import '../tokens/radius.dart';

class PradigiTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: PradigiColors.background,
      colorScheme: const ColorScheme.light(
        primary: PradigiColors.primary,
        onPrimary: PradigiColors.surface,
        surface: PradigiColors.surface,
        onSurface: PradigiColors.textPrimary,
        error: PradigiColors.danger,
        onError: PradigiColors.surface,
      ),
      textTheme: TextTheme(
        displayLarge: PradigiTypography.h1,
        displayMedium: PradigiTypography.h2,
        displaySmall: PradigiTypography.h3,
        bodyLarge: PradigiTypography.body,
        bodyMedium: PradigiTypography.bodySecondary,
        labelLarge: PradigiTypography.caption,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: PradigiColors.primary,
          foregroundColor: PradigiColors.surface,
          textStyle: PradigiTypography.body.copyWith(fontWeight: FontWeight.w600, color: PradigiColors.surface),
          padding: const EdgeInsets.symmetric(
            vertical: PradigiSpacing.s16,
            horizontal: PradigiSpacing.s24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PradigiRadius.r14),
          ),
          elevation: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: PradigiColors.surface,
        elevation: 0, // Flat workspace feel
        shadowColor: PradigiColors.textPrimary.withValues(alpha: 0.02), // 2% opacity
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PradigiRadius.r16),
          side: const BorderSide(color: PradigiColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PradigiColors.surface,
        contentPadding: const EdgeInsets.all(PradigiSpacing.s16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PradigiRadius.r16),
          borderSide: const BorderSide(color: PradigiColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PradigiRadius.r16),
          borderSide: const BorderSide(color: PradigiColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PradigiRadius.r16),
          borderSide: const BorderSide(color: PradigiColors.primary, width: 2),
        ),
        labelStyle: PradigiTypography.bodySecondary,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: PradigiColors.surface,
        indicatorColor: PradigiColors.primary.withValues(alpha: 0.1),
        labelTextStyle: WidgetStateProperty.all(PradigiTypography.caption),
      ),
      dividerTheme: const DividerThemeData(
        color: PradigiColors.border,
        space: 1,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: PradigiColors.textPrimary,
        contentTextStyle: PradigiTypography.body.copyWith(color: PradigiColors.surface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PradigiRadius.r16),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: const ColorScheme.dark(
        primary: PradigiColors.primary,
        onPrimary: PradigiColors.surface,
        surface: Color(0xFF1E1E1E),
        onSurface: Colors.white,
        error: PradigiColors.danger,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: PradigiTypography.h1,
        displayMedium: PradigiTypography.h2,
        displaySmall: PradigiTypography.h3,
        bodyLarge: PradigiTypography.body,
        bodyMedium: PradigiTypography.bodySecondary,
        labelLarge: PradigiTypography.caption,
      ).apply(bodyColor: Colors.white, displayColor: Colors.white),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: PradigiColors.primary,
          foregroundColor: PradigiColors.surface,
          textStyle: PradigiTypography.body.copyWith(fontWeight: FontWeight.w600, color: PradigiColors.surface),
          padding: const EdgeInsets.symmetric(
            vertical: PradigiSpacing.s16,
            horizontal: PradigiSpacing.s24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PradigiRadius.r14),
          ),
          elevation: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 0,
        shadowColor: Colors.white.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PradigiRadius.r16),
          side: const BorderSide(color: Color(0xFF333333), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
