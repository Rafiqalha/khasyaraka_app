import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CyberTheme {
  // Deep Dark Blue Background
  static const Color background = Color(0xFF0A0E27);
  static const Color surface = Color(0xFF1A1F3A);

  // Neon Colors
  static const Color neonCyan = Color(0xFF00FFFF);
  static const Color matrixGreen = Color(0xFF00FF88);
  static const Color alertOrange = Color(0xFFFF6B35);
  static const Color neonYellow = Color(0xFFFFD600);

  // Legacy colors (for compatibility)
  static const Color primary = neonCyan;
  static const Color onPrimary = Color(0xFF000000);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF757575);
  static const Color error = Color(0xFFFF003C);
  static const Color border = Color(0xFF1F1F1F);

  static TextStyle headline() {
    return GoogleFonts.orbitron(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: textPrimary,
      letterSpacing: 1.2,
    );
  }

  static TextStyle body() {
    return GoogleFonts.courierPrime(
      fontSize: 14,
      color: textSecondary,
      letterSpacing: 0.5,
    );
  }

  static TextStyle terminal() {
    return GoogleFonts.courierPrime(
      fontSize: 12,
      color: neonCyan,
      letterSpacing: 1,
    );
  }
}
