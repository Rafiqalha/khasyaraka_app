import 'package:dio/dio.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';
import 'package:scout_os_app/features/auth/data/auth_exception.dart';
import 'package:scout_os_app/core/services/secure_storage_service.dart';

/// AuthRepository - Online authentication via FastAPI backend.
///
/// ✅ Google login only - uses JWT token stored via ApiDioProvider
///
/// Endpoints:
/// - POST /api/v1/auth/google (Google Sign-In)
/// - GET /api/v1/users/me
class AuthRepository {
  final Dio _dio;

  AuthRepository({Dio? dio}) : _dio = dio ?? ApiDioProvider.getDio();

  /// Login via API.
  ///
  /// POST /api/v1/auth/login
  /// Body: { "username": "...", "password": "..." }
  /// Response: { "success": true, "data": { "access_token": "...", "token_type": "bearer", ... } }
  Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'username': username.trim(), 'password': password},
      );

      // Handle nested response structure: { "success": true, "data": { ... } }
      final responseData = response.data as Map<String, dynamic>;
      final data =
          responseData['data'] as Map<String, dynamic>? ?? responseData;

      final token = data['access_token'] as String;
      final tokenType = data['token_type'] as String? ?? 'bearer';

      // Save token
      await ApiDioProvider.saveToken(token, tokenType: tokenType);

      // Fetch user profile
      final user = await getCurrentUser();

      return AuthResponse(
        success: true,
        token: token,
        tokenType: tokenType,
        user: user,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;

      // Handle validation errors (422, 400)
      if (statusCode == 422 || statusCode == 400) {
        final errorMessage = _extractErrorMessage(e.response?.data);
        throw AuthException(errorMessage, statusCode: statusCode);
      }

      // Handle authentication errors (401)
      if (statusCode == 401) {
        throw AuthException(
          'Username atau password salah.',
          statusCode: statusCode,
        );
      }

      // Handle not found (404)
      if (statusCode == 404) {
        throw AuthException(
          'Endpoint tidak ditemukan. Pastikan backend berjalan.',
          statusCode: statusCode,
        );
      }

      // Handle server errors (500+)
      if (statusCode != null && statusCode >= 500) {
        throw AuthException(
          'Terjadi kesalahan server. Silakan coba lagi nanti.',
          statusCode: statusCode,
        );
      }

      // Handle timeout/connection errors
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw AuthException(
          'Gagal terhubung ke server. Periksa koneksi internet Anda.',
        );
      }

      // Generic error
      throw AuthException(
        'Gagal login: ${e.message ?? "Terjadi kesalahan"}',
        statusCode: statusCode,
      );
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Gagal terhubung ke server: ${e.toString()}');
    }
  }

  /// Register via API.
  ///
  /// POST /api/v1/auth/register
  /// Body: { "name": "...", "username": "...", "password": "...", "gugus_depan": "..." }
  /// Response: { "success": true, "data": { "access_token": "...", "token_type": "bearer", ... } }
  Future<AuthResponse> register({
    required String name,
    required String username,
    required String password,
    String? gugusDepan,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'name': name.trim(),
          'username': username.trim().toLowerCase(),
          'password': password,
          if (gugusDepan != null && gugusDepan.isNotEmpty)
            'gugus_depan': gugusDepan.trim(),
        },
      );

      // Handle nested response structure: { "success": true, "data": { ... } }
      final responseData = response.data as Map<String, dynamic>;
      final data =
          responseData['data'] as Map<String, dynamic>? ?? responseData;

      final token = data['access_token'] as String;
      final tokenType = data['token_type'] as String? ?? 'bearer';

      // Save token
      await ApiDioProvider.saveToken(token, tokenType: tokenType);

      // Fetch user profile
      final user = await getCurrentUser();

      return AuthResponse(
        success: true,
        token: token,
        tokenType: tokenType,
        user: user,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;

      // Handle validation errors (422, 400)
      if (statusCode == 422 || statusCode == 400) {
        final errorMessage = _extractErrorMessage(e.response?.data);
        throw AuthException(errorMessage, statusCode: statusCode);
      }

      // Handle conflict (409) - username already taken
      if (statusCode == 409) {
        final errorMessage = _extractErrorMessage(e.response?.data);
        throw AuthException(errorMessage, statusCode: statusCode);
      }

      // Handle server errors (500+)
      if (statusCode != null && statusCode >= 500) {
        throw AuthException(
          'Terjadi kesalahan server. Silakan coba lagi nanti.',
          statusCode: statusCode,
        );
      }

      // Handle timeout/connection errors
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw AuthException(
          'Gagal terhubung ke server. Periksa koneksi internet Anda.',
        );
      }

      // Generic error
      throw AuthException(
        'Gagal register: ${e.message ?? "Terjadi kesalahan"}',
        statusCode: statusCode,
      );
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Gagal terhubung ke server: ${e.toString()}');
    }
  }

  /// Extract error message from API response.
  /// Handles various response formats:
  /// - { "detail": "..." }
  /// - { "message": "..." }
  /// - { "error": "..." }
  /// - { "detail": [{ "msg": "...", "loc": [...] }] } (FastAPI validation errors)
  String _extractErrorMessage(dynamic responseData) {
    if (responseData == null) {
      return 'Terjadi kesalahan.';
    }

    // Handle Map responses
    if (responseData is Map<String, dynamic>) {
      // Try common error message keys
      if (responseData.containsKey('detail')) {
        final detail = responseData['detail'];

        // Handle FastAPI validation errors (list format)
        if (detail is List && detail.isNotEmpty) {
          final firstError = detail[0];
          if (firstError is Map<String, dynamic> &&
              firstError.containsKey('msg')) {
            return firstError['msg'] as String? ?? 'Data tidak valid.';
          }
          // If it's a list of strings
          if (detail[0] is String) {
            return detail[0] as String;
          }
        }

        // Handle string detail
        if (detail is String) {
          return detail;
        }
      }

      if (responseData.containsKey('message')) {
        final message = responseData['message'];
        if (message is String) {
          return message;
        }
      }

      if (responseData.containsKey('error')) {
        final error = responseData['error'];
        if (error is String) {
          return error;
        }
      }

      // Handle nested error objects
      if (responseData.containsKey('errors')) {
        final errors = responseData['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError[0] as String? ?? 'Data tidak valid.';
          }
        }
      }
    }

    // Handle string responses
    if (responseData is String) {
      return responseData;
    }

    return 'Data tidak valid. Periksa kembali.';
  }

  // ✅ Memory Cache for User Profile
  static ApiUser? _cachedUser;
  static DateTime? _lastUserFetch;
  static const Duration _userCacheTtl = Duration(
    minutes: 10,
  ); // 10 minutes cache

  /// Get current user profile from API.
  ///
  /// GET /api/v1/users/me
  Future<ApiUser> getCurrentUser({bool forceRefresh = false}) async {
    // ✅ 1. MEMORY CACHE (Instant)
    if (!forceRefresh && _cachedUser != null) {
      final isExpired =
          _lastUserFetch != null &&
          DateTime.now().difference(_lastUserFetch!) > _userCacheTtl;

      if (!isExpired) {
        return _cachedUser!;
      }
    }

    try {
      final response = await _dio.get('/users/me');

      // Handle nested response structure: { "success": true, "data": { ... } }
      final responseData = response.data as Map<String, dynamic>;
      final data =
          responseData['data'] as Map<String, dynamic>? ?? responseData;

      final user = ApiUser.fromJson(data);

      // Update cache
      _cachedUser = user;
      _lastUserFetch = DateTime.now();

      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await logout(); // Change to logout() to clear cache
        throw AuthException(
          'Sesi habis, silakan login kembali.',
          statusCode: 401,
        );
      }
      // Offline resilience
      if (_cachedUser != null) return _cachedUser!;

      throw AuthException(
        'Gagal memuat profil: ${e.message ?? "Terjadi kesalahan"}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      if (_cachedUser != null) return _cachedUser!;
      throw AuthException('Gagal memuat profil: ${e.toString()}');
    }
  }

  /// Google Sign-In via API.
  ///
  /// POST /api/v1/auth/google
  /// Body: { "id_token": "..." }
  /// Response: { "success": true, "data": { "access_token": "...", "token_type": "bearer", ... } }
  Future<AuthResponse> googleSignIn({required String idToken}) async {
    try {
      final response = await _dio.post(
        '/auth/google',
        data: {'id_token': idToken},
      );

      // Handle nested response structure: { "success": true, "data": { ... } }
      final responseData = response.data as Map<String, dynamic>;
      final data =
          responseData['data'] as Map<String, dynamic>? ?? responseData;

      final token = data['access_token'] as String;
      final tokenType = data['token_type'] as String? ?? 'bearer';

      // Save token
      await ApiDioProvider.saveToken(token, tokenType: tokenType);

      // Fetch user profile
      final user = await getCurrentUser();

      return AuthResponse(
        success: true,
        token: token,
        tokenType: tokenType,
        user: user,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;

      // Handle validation errors (422, 400)
      if (statusCode == 422 || statusCode == 400) {
        final errorMessage = _extractErrorMessage(e.response?.data);
        throw AuthException(errorMessage, statusCode: statusCode);
      }

      // Handle authentication errors (401)
      if (statusCode == 401) {
        throw AuthException(
          'Token Google tidak valid atau telah kedaluwarsa.',
          statusCode: statusCode,
        );
      }

      // Handle server errors (500+)
      if (statusCode != null && statusCode >= 500) {
        throw AuthException(
          'Terjadi kesalahan server. Silakan coba lagi nanti.',
          statusCode: statusCode,
        );
      }

      // Handle timeout/connection errors
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw AuthException(
          'Gagal terhubung ke server. Periksa koneksi internet Anda.',
        );
      }

      // Generic error
      throw AuthException(
        'Gagal login dengan Google: ${e.message ?? "Terjadi kesalahan"}',
        statusCode: statusCode,
      );
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Gagal terhubung ke server: ${e.toString()}');
    }
  }

  /// Invalidate memory cache so next getCurrentUser() returns fresh data from API.
  void invalidateCache() {
    _cachedUser = null;
    _lastUserFetch = null;
  }

  /// Logout: Clear JWT token, secure storage, and memory caches.
  Future<void> logout() async {
    _cachedUser = null;
    _lastUserFetch = null;
    await ApiDioProvider.clearToken();
    await SecureStorageService.clearAll();
  }
}

/// API User model (from backend).
class ApiUser {
  final String id;
  final String name;
  final String username;
  final String? pictureUrl;
  final bool isPro;
  final String? gugusDepan;

  ApiUser({
    required this.id,
    required this.name,
    required this.username,
    this.pictureUrl,
    this.isPro = false,
    this.gugusDepan,
  });

  factory ApiUser.fromJson(Map<String, dynamic> json) {
    // Defensive type casting: handle both int and String for id
    String id;
    if (json['id'] is int) {
      id = json['id'].toString();
    } else if (json['id'] is String) {
      id = json['id'] as String;
    } else if (json['user_id'] != null) {
      id = json['user_id'] is int
          ? json['user_id'].toString()
          : json['user_id'] as String;
    } else {
      id = '';
    }

    // Defensive type casting for other fields
    return ApiUser(
      id: id,
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      pictureUrl: json['picture_url']?.toString(),
      isPro: json['is_pro'] == true || json['isPro'] == true,
      gugusDepan: json['gugus_depan']?.toString(),
    );
  }
}

/// Auth response model.
class AuthResponse {
  final bool success;
  final String token;
  final String tokenType;
  final ApiUser user;

  AuthResponse({
    required this.success,
    required this.token,
    required this.tokenType,
    required this.user,
  });
}
