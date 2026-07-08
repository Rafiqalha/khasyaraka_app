import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scout_os_app/features/auth/data/auth_repository.dart';

/// SecureStorageService - Manages secure persistent storage
///
/// Provides secure storage for:
/// - JWT tokens (persistent login)
/// - User data (for offline access)
/// - Authentication preferences
class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Keys for secure storage
  static const String _accessTokenKey = 'access_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _userDataKey = 'user_data';
  static const String _lastLoginKey = 'last_login';

  /// Save JWT token securely
  static Future<void> saveToken(
    String token, {
    String tokenType = 'bearer',
  }) async {
    try {
      await _storage.write(key: _accessTokenKey, value: token);
      await _storage.write(key: _tokenTypeKey, value: tokenType);
      await _storage.write(
        key: _lastLoginKey,
        value: DateTime.now().toIso8601String(),
      );
      print('✅ [SECURE_STORAGE] Token saved securely');
    } catch (e) {
      print('⚠️ [SECURE_STORAGE] Failed to save token securely, falling back to SharedPreferences: $e');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accessTokenKey, token);
      await prefs.setString(_tokenTypeKey, tokenType);
      await prefs.setString(_lastLoginKey, DateTime.now().toIso8601String());
    }
  }

  /// Get saved JWT token
  static Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _accessTokenKey);
      if (token != null) return token;
      // Also check fallback
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_accessTokenKey);
    } catch (e) {
      print('⚠️ [SECURE_STORAGE] Failed to get token, falling back to SharedPreferences: $e');
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_accessTokenKey);
    }
  }

  /// Get token type
  static Future<String> getTokenType() async {
    try {
      final type = await _storage.read(key: _tokenTypeKey);
      if (type != null) return type;
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenTypeKey) ?? 'bearer';
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenTypeKey) ?? 'bearer';
    }
  }

  /// Save user data securely
  static Future<void> saveUserData(ApiUser user) async {
    try {
      final userData = {
        'id': user.id,
        'name': user.name,
        'username': user.username,
        'picture_url': user.pictureUrl,
        'is_pro': user.isPro,
        'gugus_depan': user.gugusDepan,
      };
      await _storage.write(key: _userDataKey, value: userData.toString());
      print('✅ [SECURE_STORAGE] User data saved securely');
    } catch (e) {
      print('❌ [SECURE_STORAGE] Failed to save user data: $e');
    }
  }

  /// Get saved user data
  static Future<ApiUser?> getUserData() async {
    try {
      final userDataString = await _storage.read(key: _userDataKey);
      if (userDataString == null) return null;

      // Parse user data from string (simplified approach)
      // In production, you might want to use JSON serialization
      final userData = _parseUserData(userDataString);
      return userData;
    } catch (e) {
      print('❌ [SECURE_STORAGE] Failed to get user data: $e');
      return null;
    }
  }

  /// Parse user data from stored string
  static ApiUser _parseUserData(String userDataString) {
    // This is a simplified parser - in production, use proper JSON serialization
    // Extract values using string manipulation (basic approach)
    final idMatch = RegExp(r'id: ([^,]+)').firstMatch(userDataString);
    final nameMatch = RegExp(r'name: ([^,]+)').firstMatch(userDataString);
    final usernameMatch = RegExp(
      r'username: ([^,]+)',
    ).firstMatch(userDataString);
    final pictureUrlMatch = RegExp(
      r'pictureUrl: ([^,]+)',
    ).firstMatch(userDataString);
    final isProMatch = RegExp(r'isPro: ([^,]+)').firstMatch(userDataString);
    final gugusDepanMatch = RegExp(
      r'gugusDepan: ([^,\)]+)',
    ).firstMatch(userDataString);

    return ApiUser(
      id: idMatch?.group(1) ?? '',
      name: nameMatch?.group(1) ?? '',
      username: usernameMatch?.group(1) ?? '',
      pictureUrl: pictureUrlMatch?.group(1),
      isPro: isProMatch?.group(1) == 'true',
      gugusDepan: gugusDepanMatch?.group(1),
    );
  }

  /// Check if user has valid session
  static Future<bool> hasValidSession() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) return false;

      String? lastLoginString;
      try {
        lastLoginString = await _storage.read(key: _lastLoginKey);
      } catch (e) {
        // Fallback triggered
      }
      
      if (lastLoginString == null) {
        final prefs = await SharedPreferences.getInstance();
        lastLoginString = prefs.getString(_lastLoginKey);
      }
      
      if (lastLoginString == null) return false;

      final lastLogin = DateTime.parse(lastLoginString);
      final now = DateTime.now();

      // Session never expires (selamanya) as requested by user
      // No time check needed


      return true;
    } catch (e) {
      print('❌ [SECURE_STORAGE] Failed to validate session: $e');
      return false;
    }
  }

  /// Clear all stored data (logout)
  static Future<void> clearAll() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _tokenTypeKey);
      await _storage.delete(key: _userDataKey);
      await _storage.delete(key: _lastLoginKey);
      print('✅ [SECURE_STORAGE] All data cleared successfully');
    } catch (e) {
      print('❌ [SECURE_STORAGE] Failed to clear data: $e');
    }
  }

  /// Clear only token (for token refresh scenarios)
  static Future<void> clearToken() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _tokenTypeKey);
      print('✅ [SECURE_STORAGE] Token cleared');
    } catch (e) {
      print('❌ [SECURE_STORAGE] Failed to clear token: $e');
    }
  }

  /// Debug: Print all stored keys (for development only)
  static Future<void> debugPrintAll() async {
    try {
      final allData = await _storage.readAll();
      print('🔍 [SECURE_STORAGE] All stored data:');
      allData.forEach((key, value) {
        print(
          '  $key: ${value.toString().substring(0, value.length > 20 ? 20 : value.length)}...',
        );
      });
    } catch (e) {
      print('❌ [SECURE_STORAGE] Failed to read all data: $e');
    }
  }
}
