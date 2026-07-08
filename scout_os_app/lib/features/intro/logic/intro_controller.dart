import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IntroController - Handles app startup flow
///
/// ✅ HARD RESET: No auto-login from local storage.
/// App always starts at login page after onboarding.
class IntroController extends ChangeNotifier {
  static const String _firstRunKey = 'is_first_run';
  static const String _introVersionKey = 'intro_v2_seen';

  // Routing is now handled directly by main.dart based on AuthController state.
}
