import 'package:flutter/material.dart';
import 'design_tokens.dart';

class AppTextStyles {
  AppTextStyles._();

  // Headings
  @deprecated
  static TextStyle get h1 => AppTypographyTokens.display;

  @deprecated
  static TextStyle get h2 => AppTypographyTokens.pageHeading;

  @deprecated
  static TextStyle get h3 => AppTypographyTokens.sectionHeading;

  // Body Text
  @deprecated
  static TextStyle get bodyLarge => AppTypographyTokens.bodyStrong;

  @deprecated
  static TextStyle get bodyMedium => AppTypographyTokens.body;

  // Captions/Labels
  @deprecated
  static TextStyle get caption => AppTypographyTokens.caption;

  // Buttons
  @deprecated
  static TextStyle get button => AppTypographyTokens.bodyStrong;

  // Currency/Points (Deprecated gaming element)
  @deprecated
  static TextStyle get currency => AppTypographyTokens.metadata;
}
