import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pradigi AI-Native Design Tokens (v3.0)

class AppSpacing {
  AppSpacing._();
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 12.0;
  static const double l = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;
  static const double massive = 64.0;
}

class AppRadius {
  AppRadius._();
  static const double xs = 12.0;
  static const double s = 16.0;
  static const double m = 20.0;
  static const double l = 24.0;
  
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
  static const Color primary = Color(0xFF2563EB); // AI Blue
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFFDBEAFE);

  // Surface & Background
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color card = Color(0xFFFFFFFF);
  
  // Borders
  static const Color divider = Color(0xFFE5E7EB);
  
  // Typography
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  
  // Semantic States
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);
  static const Color info = Color(0xFF3B82F6);
}

class AppTypographyTokens {
  AppTypographyTokens._();
  
  static TextStyle get baseStyle => GoogleFonts.inter(
    color: AppColorTokens.textPrimary,
  );
  
  static TextStyle get terminalStyle => GoogleFonts.robotoMono(
    color: const Color(0xFFE5E7EB),
  );

  static TextStyle get display => baseStyle.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );
  
  static TextStyle get pageHeading => baseStyle.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );
  
  static TextStyle get sectionHeading => baseStyle.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle get cardTitle => baseStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle get body => baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );
  
  static TextStyle get bodyStrong => baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get caption => baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColorTokens.textSecondary,
  );
  
  static TextStyle get metadata => baseStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColorTokens.textSecondary,
  );
}
