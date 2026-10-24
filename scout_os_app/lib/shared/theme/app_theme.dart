import 'package:flutter/material.dart';
import '../../design_system/theme/app_theme.dart';

/// Legacy AppTheme wrapper delegating to PradigiTheme single source of truth.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => PradigiTheme.lightTheme;
  static ThemeData get darkTheme => PradigiTheme.darkTheme;
}
