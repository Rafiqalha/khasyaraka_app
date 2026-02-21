import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Haptic feedback service for quiz interactions
///
/// Provides distinct tactile feedback for:
/// - Correct answers: Light, quick feedback
/// - Wrong answers: Heavy, longer buzz
class QuizHapticService {
  /// Check if device supports vibration
  static Future<bool> hasVibrationSupport() async {
    try {
      return await Vibration.hasVibrator() ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Trigger light haptic for correct answer (~50ms)
  static Future<void> correctFeedback() async {
    try {
      if (await hasVibrationSupport()) {
        await Vibration.vibrate(duration: 50);
      } else {
        await HapticFeedback.lightImpact();
      }
    } catch (e) {
      // Fallback to system haptic
      await HapticFeedback.lightImpact();
    }
  }

  /// Trigger heavy haptic for wrong answer (~400ms)
  static Future<void> wrongFeedback() async {
    try {
      if (await hasVibrationSupport()) {
        await Vibration.vibrate(duration: 400);
      } else {
        await HapticFeedback.heavyImpact();
      }
    } catch (e) {
      // Fallback to system haptic
      await HapticFeedback.heavyImpact();
    }
  }

  /// Trigger LONG vibration for correct answer (~500ms)
  /// Requested by user for distinct success feeling
  static Future<void> correctFeedbackLong() async {
    try {
      if (await hasVibrationSupport()) {
        // Pattern: Strong vibration for 500ms
        await Vibration.vibrate(duration: 500);
      } else {
        // Fallback: Triple heavy impact
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.heavyImpact();
      }
    } catch (e) {
      debugPrint('Haptic Error: $e');
    }
  }

  /// Selection tap feedback (subtle)
  static Future<void> selectionFeedback() async {
    await HapticFeedback.selectionClick();
  }
}
