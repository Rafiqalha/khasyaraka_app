import 'package:flutter/material.dart';
import 'colors.dart';

/// Pradigi Design System: Typography
/// 
/// Headline: Outfit
/// Body: Inter
/// Code: JetBrains Mono
class PradigiTypography {
  static const String headlineFont = 'Outfit';
  static const String bodyFont = 'Inter';
  static const String codeFont = 'JetBrains Mono';

  static const TextStyle h1 = TextStyle(
    fontFamily: headlineFont,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: PradigiColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: headlineFont,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: PradigiColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: headlineFont,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: PradigiColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5, // 150% line height
    color: PradigiColors.textPrimary,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: PradigiColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: PradigiColors.textSecondary,
  );

  static const TextStyle code = TextStyle(
    fontFamily: codeFont,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: PradigiColors.textPrimary,
  );
}
