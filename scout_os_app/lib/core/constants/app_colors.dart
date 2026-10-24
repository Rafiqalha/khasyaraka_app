import 'package:flutter/material.dart';
import 'package:scout_os_app/design_system/tokens/colors.dart';

/// Pradigi OS Color Constants
/// 
/// Unified with PradigiColors single source of truth.
/// Deprecated scout & cyberpunk color aliases are mapped directly to clean Pradigi palette.
class AppColors {
  AppColors._();

  // --- Pradigi Core Tokens ---
  static const Color primary = PradigiColors.primary;
  static const Color background = PradigiColors.background;
  static const Color surface = PradigiColors.surface;
  static const Color textPrimary = PradigiColors.textPrimary;
  static const Color textSecondary = PradigiColors.textSecondary;
  static const Color border = PradigiColors.border;

  // --- Semantic States ---
  static const Color success = PradigiColors.success;
  static const Color warning = PradigiColors.warning;
  static const Color danger = PradigiColors.danger;
  static const Color info = PradigiColors.primary;

  // --- Cyber & Terminal Workspace (Dark Theme) ---
  static const Color cyberBlue = PradigiColors.primary;
  static const Color graphite = PradigiColors.editorBackground;
  static const Color deepCharcoal = PradigiColors.editorBackground;
  static const Color charcoalSurface = Color(0xFF1E293B);

  // --- Modernized Legacy Mappings (Maintained for non-breaking compatibility) ---
  static const Color scoutLightBrown = PradigiColors.background;
  static const Color scoutDarkBrown = PradigiColors.textPrimary;
  static const Color penegakYellow = PradigiColors.warning;
  static const Color hasdukRed = PradigiColors.danger;
  static const Color hasdukWhite = PradigiColors.surface;
  static const Color pitchBlack = PradigiColors.textPrimary;

  static const Color scoutBg = PradigiColors.background;
  static const Color scoutBrown = PradigiColors.textSecondary;
  static const Color scoutRed = PradigiColors.danger;
  static const Color textDark = PradigiColors.textPrimary;
  static const Color textGrey = PradigiColors.textSecondary;

  static const Color successGreen = PradigiColors.success;
  static const Color actionOrange = PradigiColors.warning;
  static const Color goldBadge = PradigiColors.warning;
  static const Color forestGreen = PradigiColors.success;
  static const Color scoutWhite = PradigiColors.surface;
  static const Color scoutKhaki = PradigiColors.textSecondary;
  static const Color alertRed = PradigiColors.danger;
  static const Color wosmPurple = PradigiColors.primary;

  // --- Modernized Selection & Feedback Mappings ---
  static const Color duoSuccess = PradigiColors.success;
  static const Color duoSuccessShadow = PradigiColors.success;
  static const Color duoSuccessLight = PradigiColors.successLight;

  static const Color duoError = PradigiColors.danger;
  static const Color duoErrorShadow = PradigiColors.danger;
  static const Color duoErrorLight = Color(0xFFFEE2E2);

  static const Color duoNeutralBorder = PradigiColors.border;
  static const Color duoSelectedBorder = PradigiColors.primary;
  static const Color duoSelectedBg = Color(0xFFEFF6FF);
  static const Color duoButtonShadow = Colors.transparent;
}
