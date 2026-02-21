import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// DUOLINGO-INSPIRED DESIGN SYSTEM
/// This file establishes the strict visual rules for the app's UI:
/// - Bright, playful colors with flat design + solid shadows
/// - Bold typography with rounded fonts
/// - Large border radius for all UI elements (16-20px)
/// - "Bouncy" 3D effect using solid color shadows

class DuoTheme {
  // ==================== COLORS ====================

  // Primary Brand Colors (Bright & Vibrant)
  static const Color duoGreen = Color(0xFF58CC02); // Main brand green
  static const Color duoGreenDark = Color(
    0xFF46A302,
  ); // Darker shade for shadows
  static const Color duoGreenLight = Color(0xFF89E219); // Light accent

  // Secondary Colors (Playful & Energetic)
  static const Color duoYellow = Color(0xFFFFD600); // XP, achievements
  static const Color duoOrange = Color(0xFFFF9600); // Streak, fire
  static const Color duoBlue = Color(0xFF1CB0F6); // Water, progress
  static const Color duoPurple = Color(0xFFCE82FF); // Premium, special
  static const Color duoRed = Color(0xFFFF4B4B); // Error, locked
  static const Color duoPink = Color(0xFFFF85B7); // Playful accent

  // Neutral Colors (Clean & Crisp)
  static const Color duoWhite = Color(0xFFFFFFFF); // Pure white
  static const Color duoSnow = Color(0xFFF7F7F7); // Off-white background
  static const Color duoGrey = Color(0xFFE5E5E5); // Light grey
  static const Color duoGreyDark = Color(0xFFAFAFAF); // Medium grey
  static const Color duoBlack = Color(0xFF3C3C3C); // Text black
  static const Color duoBlackLight = Color(0xFF777777); // Secondary text

  // Shadow Colors (For 3D Bouncy Effect)
  static const Color shadowGreen = duoGreenDark;
  static const Color shadowYellow = Color(0xFFDDB400);
  static const Color shadowOrange = Color(0xFFE67E00);
  static const Color shadowBlue = Color(0xFF1899D6);
  static const Color shadowRed = Color(0xFFE03838);
  static const Color shadowGrey = Color(0xFFCCCCCC);

  // ==================== TYPOGRAPHY ====================

  static TextTheme getTextTheme() {
    return TextTheme(
      // Huge headers (e.g., "PETA BELAJAR")
      displayLarge: GoogleFonts.nunito(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: duoBlack,
        height: 1.2,
      ),

      // Section titles (e.g., "Unit 1: Sandi & Morse")
      displayMedium: GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: duoBlack,
        height: 1.3,
      ),

      // Card headers
      displaySmall: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: duoBlack,
        height: 1.3,
      ),

      // Body text (bold)
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: duoBlack,
        height: 1.5,
      ),

      // Body text (medium)
      bodyMedium: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: duoBlackLight,
        height: 1.5,
      ),

      // Small text
      bodySmall: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: duoBlackLight,
        height: 1.4,
      ),

      // Button text
      labelLarge: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: duoWhite,
        letterSpacing: 0.5,
      ),
    );
  }

  // ==================== SHAPES ====================

  // Standard border radius for all UI elements
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 20.0;
  static const double radiusXLarge = 24.0;

  static BorderRadius get borderSmall => BorderRadius.circular(radiusSmall);
  static BorderRadius get borderMedium => BorderRadius.circular(radiusMedium);
  static BorderRadius get borderLarge => BorderRadius.circular(radiusLarge);
  static BorderRadius get borderXLarge => BorderRadius.circular(radiusXLarge);

  // ==================== SPACING ====================

  static const double spaceXS = 4.0;
  static const double spaceS = 8.0;
  static const double spaceM = 12.0;
  static const double spaceL = 16.0;
  static const double spaceXL = 20.0;
  static const double spaceXXL = 24.0;
  static const double spaceHuge = 32.0;

  // ==================== SHADOWS (3D BOUNCY EFFECT) ====================

  /// Creates a solid "pressed" shadow effect for buttons and cards
  /// This is the signature Duolingo "bouncy" look
  static BoxDecoration bouncyDecoration({
    required Color mainColor,
    required Color shadowColor,
    double borderRadius = radiusMedium,
    double shadowHeight = 4.0,
  }) {
    return BoxDecoration(
      color: mainColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: shadowColor, width: 2.0),
      boxShadow: [
        BoxShadow(
          color: shadowColor,
          offset: Offset(0, shadowHeight),
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ],
    );
  }

  /// Flat card with subtle shadow (for backgrounds)
  static BoxDecoration cardDecoration({
    Color color = duoWhite,
    double borderRadius = radiusMedium,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // ==================== THEME DATA ====================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // Background
      scaffoldBackgroundColor: duoSnow,
      canvasColor: duoSnow,

      // Color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: duoGreen,
        primary: duoGreen,
        secondary: duoYellow,
        surface: duoWhite,
        error: duoRed,
        brightness: Brightness.light,
      ),

      // Typography
      textTheme: getTextTheme(),

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: duoBlack),
        titleTextStyle: GoogleFonts.nunito(
          color: duoBlack,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: duoWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: borderMedium),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: duoGreen,
          foregroundColor: duoWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: borderMedium),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: duoWhite,
        elevation: 4,
        indicatorColor: duoGreen.withValues(alpha: 0.15),
        height: 70,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: duoGreen, size: 28);
          }
          return const IconThemeData(color: duoGreyDark, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.nunito(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: duoGreen,
            );
          }
          return GoogleFonts.nunito(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: duoGreyDark,
          );
        }),
      ),
    );
  }
}
