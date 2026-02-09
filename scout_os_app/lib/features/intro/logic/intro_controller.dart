import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IntroController - Handles app startup flow
/// 
/// ✅ HARD RESET: No auto-login from local storage.
/// App always starts at login page after onboarding.
class IntroController extends ChangeNotifier {
  static const String _firstRunKey = 'is_first_run';
  static const String _introVersionKey = 'intro_v2_seen';

  Future<void> checkAppState(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final isFirstRun = prefs.getBool(_firstRunKey) ?? true;
    final hasSeenIntroV2 = prefs.getBool(_introVersionKey) ?? false;

    if (!context.mounted) return;

    // Show onboarding for first-time users
    if (isFirstRun || !hasSeenIntroV2) {
      Navigator.pushReplacementNamed(context, '/onboarding');
      return;
    }

    // ✅ HARD RESET: Always redirect to login page
    // No auto-login from local storage
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstRunKey, false);
    await prefs.setBool(_introVersionKey, true);
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }
}
