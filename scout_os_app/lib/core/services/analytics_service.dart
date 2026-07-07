import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class AnalyticsService {
  static bool get _isSupported {
    if (kIsWeb) return true; // Firebase Web is usually configured
    if (Platform.isLinux || Platform.isWindows) return false;
    return true;
  }

  static FirebaseAnalytics? get _analytics {
    if (!_isSupported) return null;
    try {
      return FirebaseAnalytics.instance;
    } catch (e) {
      return null;
    }
  }
  
  static FirebaseAnalyticsObserver? get observer {
    if (!_isSupported || _analytics == null) return null;
    try {
      return FirebaseAnalyticsObserver(analytics: _analytics!);
    } catch (e) {
      return null;
    }
  }

  static Future<void> logLogin(String loginMethod) async {
    try {
      await _analytics?.logLogin(loginMethod: loginMethod);
    } catch (e) {
      // Ignored if firebase is not fully configured
    }
  }

  static Future<void> logSignUp(String signUpMethod) async {
    try {
      await _analytics?.logSignUp(signUpMethod: signUpMethod);
    } catch (e) {
      // Ignored
    }
  }

  static Future<void> logLevelComplete(int levelId, int score) async {
    try {
      await _analytics?.logEvent(
        name: 'level_complete',
        parameters: {'level': levelId, 'score': score},
      );
    } catch (e) {
      // Ignored
    }
  }

  static Future<void> logScreenView(
      String screenName, String screenClass) async {
    try {
      await _analytics?.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    } catch (e) {
      // Ignored
    }
  }

  static Future<void> setUserProperties(String userId, bool isPro) async {
    try {
      await _analytics?.setUserId(id: userId);
      await _analytics?.setUserProperty(name: 'is_pro', value: isPro.toString());
    } catch (e) {
      // Ignored
    }
  }
}
