import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Color: Tactical/Forest Green
  static const Color primary = Color(0xFF2E7D32);

  // Secondary Color: Scout Brown
  static const Color secondary = Color(0xFF795548);

  // Accent Color: Gold/Amber (Rank features)
  static const Color accent = Color(0xFFFFC107);

  // Background Colors
  // Main Theme Colors for Sci-Fi / Heritage Scout Theme (Flat, Matte, Solid)
  static const Color deepCharcoal = Color(0xFF161616);
  static const Color charcoalSurface = Color(0xFF242424);
  
  // Diubah sementara dari Ungu ke Cyber Cyan (Neon Blue)
  static const Color wosmPurple = Color(0xFF00E5FF); // Neon Cyan
  static const Color wosmPurpleDark = Color(0xFF0097A7); // Dark Cyan

  static const Color scoutBrown = Color(0xFF5D4037);
  static const Color scoutBrownDark = Color(0xFF3E2723);
  
  static const Color lockedGrey = Color(0xFF424242);
  static const Color lockedGreyDark = Color(0xFF212121);

  // Flat 3D Stats Colors (No glow/neon allowed)
  static const Color statFire = Color(0xFFE65100);
  static const Color statFireDark = Color(0xFFBF360C);
  
  static const Color statStar = Color(0xFFF57F17);
  static const Color statStarDark = Color(0xFFF9A825);
  
  static const Color statHeart = Color(0xFFC62828);
  static const Color statHeartDark = Color(0xFFB71C1C);

  static const Color statCourse = Color(0xFF1565C0);
  static const Color statCourseDark = Color(0xFF0D47A1);

  // Background Colors
  static const Color backgroundLight = deepCharcoal; // Forced dark
  static const Color backgroundDark = deepCharcoal;

  // Text Colors
  static const Color textPrimaryLight = Color(0xFFE0E0E0); // Forced light text for dark background
  static const Color textPrimaryDark = Color(0xFFE0E0E0); // Light for dark mode

  // Functional Colors
  static const Color danger = Color(0xFFD32F2F); // Red
  static const Color success = Color(0xFF388E3C); // Green
  static const Color warning = Color(0xFFFBC02D); // Yellow/Orange
  static const Color info = Color(0xFF1976D2); // Blue

  // Surface Colors (Cards, Sheets, etc.)
  static const Color surfaceLight = charcoalSurface;
  static const Color surfaceDark = charcoalSurface;

  /// Helper to get background color based on theme
  static Color backgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? backgroundDark
        : backgroundLight;
  }
}
