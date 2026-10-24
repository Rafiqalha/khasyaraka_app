import 'package:flutter/material.dart';
import '../../design_system/tokens/colors.dart';
import '../../design_system/tokens/typography.dart';
import '../../design_system/tokens/spacing.dart';
import '../../design_system/tokens/radius.dart';

/// Pradigi AI-Native Design Tokens (v3.0)
///
/// Single source of truth integration delegating directly to PradigiTokens.

class AppSpacing {
  AppSpacing._();
  static const double xs = 4.0;
  static const double s = PradigiSpacing.s8;
  static const double m = PradigiSpacing.s12;
  static const double l = PradigiSpacing.s16;
  static const double xl = PradigiSpacing.s24;
  static const double xxl = PradigiSpacing.s32;
  static const double xxxl = PradigiSpacing.s48;
  static const double massive = 64.0;
}

class AppRadius {
  AppRadius._();
  static const double xs = PradigiRadius.r8;
  static const double s = PradigiRadius.r12;
  static const double m = PradigiRadius.r16;
  static const double l = PradigiRadius.r20;
  
  static final BorderRadius radiusXs = BorderRadius.circular(xs);
  static final BorderRadius radiusS = BorderRadius.circular(s);
  static final BorderRadius radiusM = BorderRadius.circular(m);
  static final BorderRadius radiusL = BorderRadius.circular(l);
}

class AppElevation {
  AppElevation._();
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
      
  static List<BoxShadow> get mediumShadow => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
}

class AppColorTokens {
  AppColorTokens._();
  
  // Brand
  static const Color primary = PradigiColors.primary; // AI Blue
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFFDBEAFE);

  // Surface & Background
  static const Color background = PradigiColors.background;
  static const Color surface = PradigiColors.surface;
  static const Color card = PradigiColors.surface;
  
  // Borders
  static const Color divider = PradigiColors.border;
  
  // Typography
  static const Color textPrimary = PradigiColors.textPrimary;
  static const Color textSecondary = PradigiColors.textSecondary;
  static const Color textTertiary = Color(0xFF94A3B8);
  
  // Semantic States
  static const Color success = PradigiColors.success;
  static const Color warning = PradigiColors.warning;
  static const Color danger = PradigiColors.danger;
  static const Color info = PradigiColors.primary;
}

class AppTypographyTokens {
  AppTypographyTokens._();
  
  static TextStyle get baseStyle => PradigiTypography.body;
  static TextStyle get terminalStyle => PradigiTypography.code;

  static TextStyle get display => PradigiTypography.h1;
  static TextStyle get pageHeading => PradigiTypography.h2;
  static TextStyle get sectionHeading => PradigiTypography.h3;
  static TextStyle get cardTitle => PradigiTypography.h3;
  
  static TextStyle get body => PradigiTypography.body;
  static TextStyle get bodyStrong => PradigiTypography.body.copyWith(fontWeight: FontWeight.w600);
  static TextStyle get caption => PradigiTypography.caption;
  static TextStyle get metadata => PradigiTypography.caption.copyWith(fontSize: 12);
}
