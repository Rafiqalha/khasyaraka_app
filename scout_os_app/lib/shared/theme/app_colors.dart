import 'package:flutter/material.dart';
import 'design_tokens.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Color
  static const Color primary = AppColorTokens.primary;

  // Secondary Color
  @deprecated
  static const Color secondary = AppColorTokens.textSecondary;

  // Accent Color
  @deprecated
  static const Color accent = AppColorTokens.warning;

  // Background Colors
  static const Color deepCharcoal = Color(0xFF161616);
  static const Color charcoalSurface = Color(0xFF242424);
  
  @deprecated
  static const Color wosmPurple = AppColorTokens.info; 
  @deprecated
  static const Color wosmPurpleDark = AppColorTokens.primaryDark;

  @deprecated
  static const Color scoutBrown = AppColorTokens.textSecondary;
  @deprecated
  static const Color scoutBrownDark = AppColorTokens.textPrimary;
  
  static const Color lockedGrey = Color(0xFF424242);
  static const Color lockedGreyDark = Color(0xFF212121);

  // Flat 3D Stats Colors (Deprecated, mapping to semantic tokens)
  @deprecated
  static const Color statFire = AppColorTokens.warning;
  @deprecated
  static const Color statFireDark = AppColorTokens.warning;
  
  @deprecated
  static const Color statStar = AppColorTokens.warning;
  @deprecated
  static const Color statStarDark = AppColorTokens.warning;
  
  @deprecated
  static const Color statHeart = AppColorTokens.danger;
  @deprecated
  static const Color statHeartDark = AppColorTokens.danger;

  @deprecated
  static const Color statCourse = AppColorTokens.info;
  @deprecated
  static const Color statCourseDark = AppColorTokens.primaryDark;

  // Background Colors
  static const Color backgroundLight = AppColorTokens.background;
  static const Color backgroundDark = deepCharcoal;

  // Text Colors
  static const Color textPrimaryLight = AppColorTokens.textPrimary;
  static const Color textPrimaryDark = Color(0xFFE0E0E0);

  // Functional Colors
  static const Color danger = AppColorTokens.danger;
  static const Color success = AppColorTokens.success;
  static const Color warning = AppColorTokens.warning;
  static const Color info = AppColorTokens.info;

  // Surface Colors
  static const Color surfaceLight = AppColorTokens.surface;
  static const Color surfaceDark = charcoalSurface;

  /// Helper to get background color based on theme
  static Color backgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? backgroundDark
        : backgroundLight;
  }
}
