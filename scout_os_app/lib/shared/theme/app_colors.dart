import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Color: Tactical/Forest Green
  static const Color primary = Color(0xFF2E7D32);

  // Secondary Color: Scout Brown
  static const Color secondary = Color(0xFF795548);
  
  // Accent Color: Gold/Amber (Rank features)
  static const Color accent = Color(0xFFFFC107);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF5F5F5); // Light Grey
  static const Color backgroundDark = Color(0xFF121212); // Deep Charcoal

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF212121); // Dark for light mode
  static const Color textPrimaryDark = Color(0xFFE0E0E0); // Light for dark mode
  
  // Functional Colors
  static const Color danger = Color(0xFFD32F2F); // Red
  static const Color success = Color(0xFF388E3C); // Green
  static const Color warning = Color(0xFFFBC02D); // Yellow/Orange
  static const Color info = Color(0xFF1976D2); // Blue
  
  // Surface Colors (Cards, Sheets, etc.)
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);
}
