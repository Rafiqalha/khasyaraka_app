import 'package:flutter/foundation.dart';

/// Pradigi OS Analytics Service.
/// 
/// Replaced Firebase Analytics with local/telemetry logging.
/// Production telemetry is handled by Pradigi EpisodeRecorder & Telemetry Pipeline.
class AnalyticsService {
  static Future<void> logLogin(String loginMethod) async {
    debugPrint('📊 [Pradigi OS Telemetry] Login: $loginMethod');
  }

  static Future<void> logSignUp(String signUpMethod) async {
    debugPrint('📊 [Pradigi OS Telemetry] SignUp: $signUpMethod');
  }

  static Future<void> logLevelComplete(int levelId, int score) async {
    debugPrint('📊 [Pradigi OS Telemetry] Level Complete: id=$levelId score=$score');
  }

  static Future<void> logEvent(String name, [Map<String, dynamic>? parameters]) async {
    debugPrint('📊 [Pradigi OS Telemetry] Event: $name params=$parameters');
  }
}
