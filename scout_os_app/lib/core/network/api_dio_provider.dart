import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:scout_os_app/core/config/environment.dart';

/// Centralized Dio instance with JWT interceptor.
/// 
/// ✅ HARD RESET: Memory-only token storage
/// Token is cleared when app is killed (no local persistence).
/// 
/// Handles:
/// - Adding Bearer token to all requests
/// - Handling 401 errors (logout and redirect)
class ApiDioProvider {
  // ✅ Memory-only token storage (cleared on app kill)
  static String? _token;
  static String _tokenType = 'bearer';
  
  static Dio? _dioInstance;

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
          // ✅ Use memory-only token
          final token = _token;
          
          // ✅ CRITICAL DEBUG: Log request details
          debugPrint('🔍 [DIO_INTERCEPTOR] Request: ${options.method} ${options.baseUrl}${options.path}');
          
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            debugPrint('✅ [DIO_INTERCEPTOR] Authorization header added: Bearer ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
          } else {
            debugPrint('⚠️ [DIO_INTERCEPTOR] No token found, request will be sent without Authorization header');
          }
          
          debugPrint('🔍 [DIO_INTERCEPTOR] Request headers: ${options.headers}');
          
          handler.next(options);
        },
        onError: (error, handler) async {
          // ✅ CRITICAL DEBUG: Log error details
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

  /// Save JWT token to memory only.
  /// ✅ HARD RESET: No longer persists to SharedPreferences.
  static Future<void> saveToken(String token, {String tokenType = 'bearer'}) async {
    _token = token;
    _tokenType = tokenType;
    debugPrint('✅ [AUTH] Token saved to memory (not persisted to disk)');
  }

  /// Get saved JWT token from memory.
  static Future<String?> getToken() async {
    return _token;
  }

  /// Clear token from memory (logout).
  static Future<void> clearToken() async {
    _token = null;
    _tokenType = 'bearer';
    debugPrint('🧹 [AUTH] Token cleared from memory');
  }

  /// Handle 401 error: Clear token and redirect to login.
  static Future<void> _handle401Error() async {
    await clearToken();
    
    // Navigate to login page
    // Note: This requires BuildContext, so we'll handle it in the UI layer
    // For now, just clear the token
    debugPrint('⚠️ 401 Unauthorized - Token cleared. User must login again.');
  }

  /// Reset Dio instance (useful for testing or reconfiguration).
  static void reset() {
    _dioInstance = null;
  }
}
