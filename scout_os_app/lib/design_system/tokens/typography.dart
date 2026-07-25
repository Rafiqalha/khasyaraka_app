import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Pradigi Design System: Typography
/// 
/// Headline: Outfit
/// Body: Inter
/// Code: JetBrains Mono
class PradigiTypography {
  static TextStyle get h1 => GoogleFonts.outfit(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: PradigiColors.textPrimary,
  );

  static TextStyle get h2 => GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: PradigiColors.textPrimary,
  );

  static TextStyle get h3 => GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: PradigiColors.textPrimary,
  );

  static TextStyle get body => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5, // 150% line height
    color: PradigiColors.textPrimary,
  );

  static TextStyle get bodySecondary => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: PradigiColors.textSecondary,
  );

  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: PradigiColors.textSecondary,
  );

  static TextStyle get code => GoogleFonts.jetBrainsMono(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: PradigiColors.textPrimary,
  );
}
