import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';

/// SCOUT DUOLINGO-STYLE DESIGN SYSTEM
/// 
/// This theme configuration establishes a "bouncy 3D" Duolingo-inspired aesthetic
/// while STRICTLY using Scout (Pramuka) colors.
/// 
/// Key Principles:
/// - Warm Scout color palette (browns, creams, golds)
/// - Large rounded corners (20px default)
/// - Bold typography (Nunito/Poppins)
/// - Shadow colors for 3D bouncy effects
/// - Material 3 design

class ThemeConfig {
  
  // ==================== SCOUT COLOR PALETTE ====================
  
  /// Background Colors
  static const Color backgroundCream = AppColors.scoutLightBrown; // #F0E6D2 - Main scaffold bg
  static const Color surfaceWhite = AppColors.hasdukWhite;        // #FFFFFF - Cards, inputs
  
  /// Primary Colors (Actions, Unlocked, Active)
  static const Color primaryBrown = AppColors.scoutDarkBrown;     // #4E342E - Main actions
  static const Color primaryOrange = AppColors.actionOrange;      // #E65100 - Warm alternative
  
  /// Secondary Colors (Locked, Inactive, Disabled)
  static const Color secondaryGrey = Color(0xFFBDBDBD);           // Muted grey
  static const Color secondaryLightGrey = Color(0xFFE0E0E0);      // Lighter grey
  
  /// Accent Colors (XP, Rewards, Success)
  static const Color accentGold = AppColors.penegakYellow;        // #FFD600 - Rewards, XP
  static const Color accentKhaki = AppColors.scoutKhaki;          // #C9B037 - Badges
  static const Color accentGreen = AppColors.successGreen;        // #388E3C - Completed
  
  /// Semantic Colors
  static const Color errorRed = AppColors.hasdukRed;              // #D32F2F - Errors
  static const Color warningOrange = Color(0xFFF57C00);           // Warning states
  
  /// Text Colors
  static const Color textPrimary = AppColors.scoutDarkBrown;      // #4E342E - Primary text
  static const Color textSecondary = AppColors.textGrey;          // #795548 - Secondary text
  static const Color textOnDark = AppColors.hasdukWhite;          // #FFFFFF - Text on dark bg
  
  // ==================== 3D SHADOW COLORS (For Bouncy Effect) ====================
  
  /// Shadow colors are DARKER shades of main colors
  /// Used for creating solid "pressed down" 3D effect (NO BLUR!)
  
  static const Color primaryBrownShadow = Color(0xFF3E2723);      // Darker brown
  static const Color primaryOrangeShadow = Color(0xFFBF360C);     // Darker orange
  static const Color accentGoldShadow = Color(0xFFFFA000);        // Darker gold
  static const Color accentKhakiShadow = Color(0xFF9E7B00);       // Darker khaki
  static const Color accentGreenShadow = Color(0xFF2E7D32);       // Darker green
  static const Color secondaryGreyShadow = Color(0xFF9E9E9E);     // Darker grey
  static const Color errorRedShadow = Color(0xFFB71C1C);          // Darker red
  
  // ==================== SHAPE CONSTANTS ====================
  
  /// Standard border radius for all UI elements (Duolingo-style: LARGE & ROUNDED)
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 20.0;   // DEFAULT for cards, buttons
  static const double radiusXLarge = 24.0;  // Lesson nodes, special elements
  
  static BorderRadius get borderSmall => BorderRadius.circular(radiusSmall);
  static BorderRadius get borderMedium => BorderRadius.circular(radiusMedium);
  static BorderRadius get borderLarge => BorderRadius.circular(radiusLarge);
  static BorderRadius get borderXLarge => BorderRadius.circular(radiusXLarge);
  
  // ==================== SPACING CONSTANTS ====================
  
  static const double spaceXS = 4.0;
  static const double spaceS = 8.0;
  static const double spaceM = 12.0;
  static const double spaceL = 16.0;
  static const double spaceXL = 20.0;
  static const double spaceXXL = 24.0;
  
  // ==================== SHADOW HELPER (3D Bouncy Effect) ====================
  
  /// Creates a solid "pressed" shadow for the Duolingo bouncy look
  /// 
  /// Usage:
  /// ```dart
  /// Container(
  ///   decoration: BoxDecoration(
  ///     color: ThemeConfig.primaryOrange,
  ///     borderRadius: ThemeConfig.borderLarge,
  ///     border: Border.all(color: ThemeConfig.primaryOrangeShadow, width: 2),
  ///     boxShadow: ThemeConfig.bouncyShadow(ThemeConfig.primaryOrangeShadow),
  ///   ),
  /// )
  /// ```
  static List<BoxShadow> bouncyShadow(Color shadowColor, {double height = 6.0}) {
    return [
      BoxShadow(
        color: shadowColor,
        offset: Offset(0, height),
        blurRadius: 0,    // NO BLUR for flat 3D effect
        spreadRadius: 0,
      ),
    ];
  }
  
  /// Soft shadow for subtle elevation (navigation, cards without bouncy effect)
  static List<BoxShadow> softShadow({double opacity = 0.08}) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: opacity),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }
  
  // ==================== THEME DATA ====================
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // --- BACKGROUND & SURFACE ---
      scaffoldBackgroundColor: backgroundCream,
      canvasColor: backgroundCream,
      
      // --- PRIMARY COLORS ---
      primaryColor: primaryBrown,
      
      // --- COLOR SCHEME (Material 3) ---
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBrown,
        primary: primaryBrown,
        secondary: accentGold,
        tertiary: primaryOrange,
        surface: backgroundCream,
        onSurface: textPrimary,
        error: errorRed,
        brightness: Brightness.light,
      ),
      
      // --- TYPOGRAPHY (Nunito - Rounded & Friendly) ---
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        // Display (Large Headers)
        displayLarge: GoogleFonts.nunito(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          height: 1.2,
        ),
        displayMedium: GoogleFonts.nunito(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: 1.3,
        ),
        displaySmall: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: 1.3,
        ),
        
        // Headline (Section Titles)
        headlineMedium: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: 1.3,
        ),
        
        // Body Text
        bodyLarge: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textSecondary,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textSecondary,
          height: 1.4,
        ),
        
        // Labels (Buttons, Tabs)
        labelLarge: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: textOnDark,
          letterSpacing: 0.5,
        ),
      ),
      
      // --- APP BAR THEME ---
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: primaryBrown),
        titleTextStyle: GoogleFonts.nunito(
          color: primaryBrown,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      
      // --- CARD THEME (Large Rounded Corners) ---
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0, // We'll use custom shadows instead
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: borderLarge), // 20px!
        margin: const EdgeInsets.symmetric(vertical: spaceS),
      ),
      
      // --- BUTTON THEMES ---
      
      // Elevated Button (Primary Actions)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBrown,
          foregroundColor: textOnDark,
          elevation: 0, // We use solid shadow instead
          padding: const EdgeInsets.symmetric(horizontal: spaceXXL, vertical: spaceL),
          shape: RoundedRectangleBorder(borderRadius: borderLarge), // 20px!
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Outlined Button (Secondary Actions)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBrown,
          side: const BorderSide(color: primaryBrown, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: spaceXXL, vertical: spaceL),
          shape: RoundedRectangleBorder(borderRadius: borderLarge), // 20px!
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Text Button (Tertiary Actions)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBrown,
          padding: const EdgeInsets.symmetric(horizontal: spaceL, vertical: spaceM),
          textStyle: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // --- INPUT DECORATION (Text Fields) ---
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: spaceXL, vertical: spaceL),
        
        // Border styles with LARGE radius
        border: OutlineInputBorder(
          borderRadius: borderLarge, // 20px!
          borderSide: const BorderSide(color: secondaryGrey, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderLarge,
          borderSide: const BorderSide(color: secondaryGrey, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderLarge,
          borderSide: const BorderSide(color: accentGold, width: 3), // Gold focus!
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderLarge,
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderLarge,
          borderSide: const BorderSide(color: errorRed, width: 3),
        ),
        
        // Text styles
        labelStyle: GoogleFonts.nunito(
          color: textSecondary,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: GoogleFonts.nunito(
          color: textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // --- NAVIGATION BAR (Bottom Menu) ---
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceWhite,
        elevation: 4,
        indicatorColor: accentGold.withValues(alpha: 0.2), // Gold indicator
        height: 70,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryBrown, size: 28);
          }
          return const IconThemeData(color: secondaryGrey, size: 24);
        }),
        
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.nunito(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: primaryBrown,
            );
          }
          return GoogleFonts.nunito(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: secondaryGrey,
          );
        }),
      ),
      
      // --- FLOATING ACTION BUTTON ---
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentGold,
        foregroundColor: textPrimary,
        elevation: 0, // Use solid shadow instead
        shape: RoundedRectangleBorder(borderRadius: borderLarge),
      ),
      
      // --- CHIP THEME ---
      chipTheme: ChipThemeData(
        backgroundColor: secondaryLightGrey,
        selectedColor: accentGold,
        labelStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        shape: RoundedRectangleBorder(borderRadius: borderMedium),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: spaceM, vertical: spaceS),
      ),
      
      // --- DIALOG THEME ---
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: borderLarge), // 20px!
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        contentTextStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textSecondary,
        ),
      ),
      
      // --- SNACKBAR THEME ---
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryBrown,
        contentTextStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textOnDark,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: borderMedium),
      ),
    );
  }
}