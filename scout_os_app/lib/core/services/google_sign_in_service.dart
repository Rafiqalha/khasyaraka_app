import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// GoogleSignInService — Single source of truth for all Google Sign-In operations.
///
/// Singleton that centralizes:
/// - GoogleSignIn configuration (clientId, scopes)
/// - Sign-in flow with retry mechanism
/// - Sign-out / disconnect for logout
/// - Silent sign-in for auto-login
///
/// Usage:
///   final idToken = await GoogleSignInService().signIn();
///   await GoogleSignInService().signOut();
class GoogleSignInService {
  static final GoogleSignInService _instance = GoogleSignInService._();
  factory GoogleSignInService() => _instance;
  GoogleSignInService._();

  // ── Google OAuth Configuration ──
  // Web Client ID — used as serverClientId to generate idToken for backend verification.
  // Get from: https://console.cloud.google.com/apis/credentials
  // Android Client ID is read automatically from google-services.json.
  static const String _webClientId =
      '890949539640-b6pggk05brv780fott32uq1leckbkg80.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: _webClientId,
    scopes: ['email', 'profile'],
  );

  // ── Public API ──

  /// Perform interactive Google Sign-In and return the `idToken`.
  ///
  /// Returns `null` if the user cancels.
  /// Throws on unrecoverable errors after [maxRetries] attempts.
  Future<String?> signIn({int maxRetries = 3}) async {
    debugPrint('🔵 [GOOGLE] Starting Google Sign-In flow...');

    // 1. Interactive sign-in
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      debugPrint('ℹ️ [GOOGLE] User cancelled sign-in');
      return null;
    }
    debugPrint('✅ [GOOGLE] Signed in as ${googleUser.email}');

    // 2. Get idToken with retry
    return _getIdTokenWithRetry(googleUser, maxRetries: maxRetries);
  }

  /// Sign out gently — clears local Google state but keeps server-side grant.
  /// Use for normal logout.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      debugPrint('✅ [GOOGLE] Signed out');
    } catch (e) {
      debugPrint('⚠️ [GOOGLE] Sign-out failed: $e');
    }
  }

  /// Disconnect — revokes the user's grant entirely.
  /// Forces account picker on next sign-in. Use sparingly.
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
      debugPrint('✅ [GOOGLE] Disconnected');
    } catch (e) {
      debugPrint('⚠️ [GOOGLE] Disconnect failed: $e');
    }
  }

  /// Try to refresh Google session silently (no UI).
  /// Useful for auto-login on app startup.
  Future<void> trySilentSignIn() async {
    try {
      final user = await _googleSignIn.signInSilently();
      if (user != null) {
        debugPrint('✅ [GOOGLE] Silent sign-in successful: ${user.email}');
      }
    } catch (e) {
      debugPrint('⚠️ [GOOGLE] Silent sign-in failed: $e');
    }
  }

  // ── Private Helpers ──

  Future<String> _getIdTokenWithRetry(
    GoogleSignInAccount googleUser, {
    required int maxRetries,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final auth = await googleUser.authentication;
        if (auth.idToken != null) {
          debugPrint('✅ [GOOGLE] idToken retrieved (attempt $attempt)');
          return auth.idToken!;
        }
      } catch (e) {
        debugPrint(
          '⚠️ [GOOGLE] idToken attempt $attempt/$maxRetries failed: $e',
        );
      }

      if (attempt < maxRetries) {
        final delay = Duration(seconds: attempt);
        debugPrint('⏱️ [GOOGLE] Waiting ${delay.inSeconds}s before retry...');
        await Future.delayed(delay);

        // Try silent refresh to get new tokens
        try {
          await _googleSignIn.signInSilently();
        } catch (_) {}
      }
    }

    throw Exception('Failed to get idToken after $maxRetries attempts');
  }
}
