import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scout_os_app/core/auth/local_auth_service.dart';

class IntroController extends ChangeNotifier {
  IntroController({LocalAuthService? authService})
      : _authService = authService ?? LocalAuthService();

  final LocalAuthService _authService;
  static const String _firstRunKey = 'is_first_run';
  static const String _introVersionKey = 'intro_v2_seen';

  Future<void> checkAppState(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final isFirstRun = prefs.getBool(_firstRunKey) ?? true;
    final hasSeenIntroV2 = prefs.getBool(_introVersionKey) ?? false;
    final userId = await _authService.getCurrentUserId();
    final isLoggedIn = userId != null;

    if (!context.mounted) return;

    if (isFirstRun || !hasSeenIntroV2) {
      Navigator.pushReplacementNamed(context, '/onboarding');
      return;
    }

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/dashboard');
      return;
    }

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
