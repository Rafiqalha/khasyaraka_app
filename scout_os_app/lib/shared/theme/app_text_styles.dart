import 'package:flutter/material.dart';
import '../../design_system/tokens/typography.dart';
import 'design_tokens.dart';

/// Legacy AppTextStyles compatibility class.
/// 
/// Unified with PradigiTypography single source of truth.
class AppTextStyles {
  AppTextStyles._();

  // Headings
  static TextStyle get h1 => PradigiTypography.h1;
  static TextStyle get h2 => PradigiTypography.h2;
  static TextStyle get h3 => PradigiTypography.h3;

  // Body Text
  static TextStyle get bodyLarge => PradigiTypography.body.copyWith(fontWeight: FontWeight.w600);
  static TextStyle get bodyMedium => PradigiTypography.body;

  // Captions/Labels
  static TextStyle get caption => PradigiTypography.caption;

  // Buttons
  static TextStyle get button => PradigiTypography.body.copyWith(fontWeight: FontWeight.w600);

  // Metadata/Currency
  static TextStyle get currency => PradigiTypography.caption;
}
