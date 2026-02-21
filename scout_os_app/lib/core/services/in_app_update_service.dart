import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

/// Service to handle Google Play In-App Updates.
///
/// Uses IMMEDIATE update type — blocks the user from using the app
/// until the update is installed. This ensures all users run the
/// latest version from Google Play.
class InAppUpdateService {
  /// Check for updates and force immediate update if available.
  ///
  /// Call this early in app startup (e.g., from SplashPage or main).
  /// Only runs on Android — silently skips on iOS/other platforms.
  static Future<void> checkForUpdate() async {
    // Only Android supports Play In-App Updates
    if (!Platform.isAndroid) return;

    try {
      final updateInfo = await InAppUpdate.checkForUpdate();

      debugPrint(
        '🔄 [IN_APP_UPDATE] Available: ${updateInfo.updateAvailability}',
      );
      debugPrint(
        '🔄 [IN_APP_UPDATE] Immediate allowed: ${updateInfo.immediateUpdateAllowed}',
      );
      debugPrint(
        '🔄 [IN_APP_UPDATE] Flexible allowed: ${updateInfo.flexibleUpdateAllowed}',
      );

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateUpdateAllowed) {
          // Force immediate update — user cannot skip
          debugPrint('🚀 [IN_APP_UPDATE] Starting IMMEDIATE update...');
          await InAppUpdate.performImmediateUpdate();
        } else if (updateInfo.flexibleUpdateAllowed) {
          // Fallback: start flexible update if immediate isn't allowed
          debugPrint(
            '📦 [IN_APP_UPDATE] Immediate not allowed, starting flexible update...',
          );
          await InAppUpdate.startFlexibleUpdate();
          // Auto-complete when downloaded
          await InAppUpdate.completeFlexibleUpdate();
        }
      } else {
        debugPrint('✅ [IN_APP_UPDATE] App is up to date');
      }
    } catch (e) {
      // Non-fatal — don't block app startup if update check fails
      // Common failures: no Play Store (emulator), no internet, etc.
      debugPrint('⚠️ [IN_APP_UPDATE] Check failed (non-fatal): $e');
    }
  }
}
