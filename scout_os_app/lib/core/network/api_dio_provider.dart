import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scout_os_app/core/config/environment.dart';

/// Centralized Dio instance with JWT interceptor.
/// 
/// Handles:
/// - Adding Bearer token to all requests
/// - Handling 401 errors (logout and redirect)
class ApiDioProvider {
  static const String _tokenKey = 'jwt_access_token';
  static const String _tokenTypeKey = 'jwt_token_type';
  
  static Dio? _dioInstance;
  static SharedPreferences? _prefs;

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
          // Load token from SharedPreferences
          _prefs ??= await SharedPreferences.getInstance();
          final token = _prefs?.getString(_tokenKey);
          
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

  /// Save JWT token to SharedPreferences.
  static Future<void> saveToken(String token, {String tokenType = 'bearer'}) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setString(_tokenKey, token);
    await _prefs?.setString(_tokenTypeKey, tokenType);
  }

  /// Get saved JWT token.
  static Future<String?> getToken() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs?.getString(_tokenKey);
  }

  /// Clear token (logout).
  static Future<void> clearToken() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.remove(_tokenKey);
    await _prefs?.remove(_tokenTypeKey);
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
