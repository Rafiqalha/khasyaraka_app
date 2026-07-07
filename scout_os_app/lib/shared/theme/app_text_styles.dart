import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Headings
  static TextStyle h1 = GoogleFonts.fredoka(
    fontSize: 32,
    fontWeight: FontWeight.w700, // Bold
  );

  static TextStyle h2 = GoogleFonts.fredoka(
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static TextStyle h3 = GoogleFonts.fredoka(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  // Body Text
  static TextStyle bodyLarge = GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w700, // Bold for readability like Duolingo
  );

  static TextStyle bodyMedium = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  // Captions/Labels
  static TextStyle caption = GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: Colors.grey,
  );

  // Buttons
  static TextStyle button = GoogleFonts.fredoka(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  // Currency/Points
  static TextStyle currency = GoogleFonts.fredoka(
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );
}
