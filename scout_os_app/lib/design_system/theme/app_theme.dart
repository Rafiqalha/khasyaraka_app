import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';
import '../tokens/spacing.dart';
import '../tokens/radius.dart';

class PradigiTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
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
    const Color darkBackground = Color(0xFF0F172A); // Slate 950 / editorBackground
    const Color darkSurface = Color(0xFF1E293B);    // Slate 800
    const Color darkBorder = Color(0xFF334155);     // Slate 700
    const Color textLight = Color(0xFFF8FAFC);      // Slate 50

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: PradigiColors.primary,
        onPrimary: Colors.white,
        surface: darkSurface,
        onSurface: textLight,
        error: PradigiColors.danger,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: PradigiTypography.h1.copyWith(color: textLight),
        displayMedium: PradigiTypography.h2.copyWith(color: textLight),
        displaySmall: PradigiTypography.h3.copyWith(color: textLight),
        bodyLarge: PradigiTypography.body.copyWith(color: textLight),
        bodyMedium: PradigiTypography.bodySecondary.copyWith(color: const Color(0xFF94A3B8)),
        labelLarge: PradigiTypography.caption.copyWith(color: const Color(0xFF94A3B8)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: PradigiColors.primary,
          foregroundColor: Colors.white,
          textStyle: PradigiTypography.body.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
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
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PradigiRadius.r16),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding: const EdgeInsets.all(PradigiSpacing.s16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PradigiRadius.r16),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PradigiRadius.r16),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PradigiRadius.r16),
          borderSide: const BorderSide(color: PradigiColors.primary, width: 2),
        ),
        labelStyle: PradigiTypography.bodySecondary.copyWith(color: const Color(0xFF94A3B8)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface,
        indicatorColor: PradigiColors.primary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.all(PradigiTypography.caption.copyWith(color: textLight)),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        space: 1,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkSurface,
        contentTextStyle: PradigiTypography.body.copyWith(color: textLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PradigiRadius.r16),
          side: const BorderSide(color: darkBorder),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
