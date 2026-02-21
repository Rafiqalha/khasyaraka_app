import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:scout_os_app/core/config/environment.dart';
import 'package:scout_os_app/core/services/secure_storage_service.dart';

/// Senior Flutter Architect & Backend Specialist Implementation
/// Centralized Dio instance with JWT interceptor and robust 401 handling.
///
/// ✅ PERSISTENT LOGIN: Uses secure storage for token persistence
/// Token survives app restarts and device reboots.
///
/// Handles:
/// - Adding Bearer token to all requests
/// - Handling 401 errors (auto-logout)
/// - Token persistence via secure storage
/// - Global logout events
class ApiDioProvider {
  static Dio? _dioInstance;
  static GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  /// Get or create singleton Dio instance with JWT interceptor.
  static Dio getDio() {
    if (_dioInstance != null) return _dioInstance!;

    _dioInstance = Dio(
      BaseOptions(
        baseUrl: Environment.apiBaseUrl,
        connectTimeout: Duration(milliseconds: Environment.connectTimeout),
        receiveTimeout: Duration(milliseconds: Environment.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dioInstance!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Use secure storage for token
          final token = await SecureStorageService.getToken();

          // Log request details
          debugPrint(
            '🔍 [DIO_INTERCEPTOR] Request: ${options.method} ${options.baseUrl}${options.path}',
          );

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            debugPrint(
              '✅ [DIO_INTERCEPTOR] Authorization header added: Bearer ${token.substring(0, token.length > 20 ? 20 : token.length)}...',
            );
          } else {
            debugPrint(
              '⚠️ [DIO_INTERCEPTOR] No token found, request will be sent without Authorization header',
            );
          }

          debugPrint(
            '🔍 [DIO_INTERCEPTOR] Request headers: ${options.headers}',
          );

          handler.next(options);
        },
        onError: (error, handler) async {
          // Log error details
          debugPrint('❌ [DIO_INTERCEPTOR] Error: ${error.message}');
          if (error.response != null) {
            debugPrint('   Status: ${error.response!.statusCode}');
            debugPrint('   Headers: ${error.response!.headers.map}');
            debugPrint('   Body: ${error.response!.data}');
          }

          // Handle 401 Unauthorized
          if (error.response?.statusCode == 401) {
            await _handle401Error();
          }
          handler.next(error);
        },
      ),
    );

    return _dioInstance!;
  }

  /// Save JWT token to secure storage.
  /// ✅ PERSISTENT LOGIN: Token survives app restarts.
  static Future<void> saveToken(
    String token, {
    String tokenType = 'bearer',
  }) async {
    await SecureStorageService.saveToken(token, tokenType: tokenType);
    debugPrint('✅ [AUTH] Token saved to secure storage (persistent)');
  }

  /// Get saved JWT token from secure storage.
  static Future<String?> getToken() async {
    return await SecureStorageService.getToken();
  }

  /// Clear token from secure storage (logout).
  static Future<void> clearToken() async {
    await SecureStorageService.clearToken();
    debugPrint('🧹 [AUTH] Token cleared from secure storage');
  }

  /// Handle 401 error: Clear token and trigger global logout.
  static Future<void> _handle401Error() async {
    debugPrint(
      '🚨 [DIO_INTERCEPTOR] 401 Unauthorized detected - triggering global logout',
    );

    // Clear all authentication data
    await clearToken();

    // Trigger global logout event
    await _triggerGlobalLogout();
  }

  /// Trigger global logout event across the app
  static Future<void> _triggerGlobalLogout() async {
    try {
      debugPrint('🚪 [DIO_INTERCEPTOR] Global logout triggered');

      // Clear all secure storage data
      await SecureStorageService.clearAll();

      // Navigate to login screen if navigator is available
      if (_navigatorKey.currentContext != null) {
        Navigator.of(
          _navigatorKey.currentContext!,
        ).pushNamedAndRemoveUntil('/onboarding', (route) => false);
      }
    } catch (e) {
      debugPrint('❌ [DIO_INTERCEPTOR] Error during global logout: $e');
    }
  }

  /// Set navigator key for global navigation
  static void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  /// Reset Dio instance (useful for testing or reconfiguration).
  static void reset() {
    _dioInstance = null;
  }

  /// Create a new Dio instance with custom configuration
  static Dio createCustomDio({
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Map<String, String>? headers,
  }) {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl ?? Environment.apiBaseUrl,
        connectTimeout:
            connectTimeout ??
            Duration(milliseconds: Environment.connectTimeout),
        receiveTimeout:
            receiveTimeout ??
            Duration(milliseconds: Environment.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...?headers,
        },
      ),
    );
  }

  /// Add custom interceptor to Dio instance
  static void addInterceptor(Interceptor interceptor) {
    getDio().interceptors.add(interceptor);
  }

  /// Remove interceptor from Dio instance
  static void removeInterceptor(Interceptor interceptor) {
    getDio().interceptors.remove(interceptor);
  }
}
