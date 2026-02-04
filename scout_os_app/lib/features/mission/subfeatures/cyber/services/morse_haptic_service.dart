import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Morse Haptic Service
/// 
/// Handles haptic feedback for Morse code according to standard:
/// - Dot (.) = 1 unit (short vibration ~100ms)
/// - Dash (-) = 3 units (long vibration ~300ms)
/// 
/// Uses single vibration with duration control, NOT multiple vibrations
class MorseHapticService {
  /// Check if device supports vibration
  static Future<bool> _hasVibrator() async {
    try {
      return await Vibration.hasVibrator();
    } catch (e) {
      return false;
    }
  }

  /// Play dot (.) - Short vibration (~100ms)
  /// Single vibration, not multiple
  static Future<void> playDot() async {
    try {
      final hasVibrator = await _hasVibrator();
      
      if (hasVibrator) {
        // Use vibration package for precise duration control
        await Vibration.vibrate(duration: 100); // 100ms for dot
      } else {
        // Fallback to HapticFeedback for devices without vibration support
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      // Silent fail - device might not support haptic
      try {
        HapticFeedback.lightImpact();
      } catch (_) {
        // Complete silent fail
      }
    }
  }

  /// Play dash (-) - Long vibration (~300ms)
  /// Single long vibration, NOT multiple short ones
  static Future<void> playDash() async {
    try {
      final hasVibrator = await _hasVibrator();
      
      if (hasVibrator) {
        // Use vibration package for precise duration control
        // Single long vibration (3x duration of dot)
        await Vibration.vibrate(duration: 300); // 300ms for dash (3 units)
      } else {
        // Fallback to HapticFeedback for devices without vibration support
        // Use heavyImpact which feels longer than lightImpact
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      // Silent fail - device might not support haptic
      try {
        HapticFeedback.heavyImpact();
      } catch (_) {
        // Complete silent fail
      }
    }
  }
}
