import 'package:flutter/material.dart';
import '../../design_system/tokens/colors.dart';
import 'design_tokens.dart';

/// Legacy AppColors compatibility class.
/// 
/// Unified with PradigiColors single source of truth.
class AppColors {
  AppColors._();

  // Primary Color
  static const Color primary = PradigiColors.primary;
  static const Color secondary = PradigiColors.textSecondary;
  static const Color accent = PradigiColors.warning;

  // Background Colors
  static const Color deepCharcoal = PradigiColors.editorBackground;
  static const Color charcoalSurface = Color(0xFF1E293B);
  
  static const Color wosmPurple = PradigiColors.primary;
  static const Color wosmPurpleDark = Color(0xFF1D4ED8);

  static const Color scoutBrown = PradigiColors.textSecondary;
  static const Color scoutBrownDark = PradigiColors.textPrimary;
  
  static const Color lockedGrey = Color(0xFF94A3B8);
  static const Color lockedGreyDark = Color(0xFF64748B);

  // Stats Colors mapped to clean Pradigi semantic tokens
  static const Color statFire = PradigiColors.warning;
  static const Color statFireDark = PradigiColors.warning;
  
  static const Color statStar = PradigiColors.warning;
  static const Color statStarDark = PradigiColors.warning;
  
  static const Color statHeart = PradigiColors.danger;
  static const Color statHeartDark = PradigiColors.danger;

  static const Color statCourse = PradigiColors.primary;
  static const Color statCourseDark = Color(0xFF1D4ED8);

  // Background Colors
  static const Color backgroundLight = PradigiColors.background;
  static const Color backgroundDark = PradigiColors.editorBackground;

  // Text Colors
  static const Color textPrimaryLight = PradigiColors.textPrimary;
  static const Color textPrimaryDark = Color(0xFFF1F5F9);

  // Functional Colors
  static const Color danger = PradigiColors.danger;
  static const Color success = PradigiColors.success;
  static const Color warning = PradigiColors.warning;
  static const Color info = PradigiColors.primary;

  // Surface Colors
  static const Color surfaceLight = PradigiColors.surface;
  static const Color surfaceDark = Color(0xFF1E293B);

  /// Helper to get background color based on theme
  static Color backgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? backgroundDark
        : backgroundLight;
  }
}
