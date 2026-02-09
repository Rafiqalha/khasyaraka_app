import 'package:flutter/material.dart';
import 'package:scout_os_app/features/auth/data/auth_repository.dart';
import 'package:scout_os_app/features/auth/data/auth_exception.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';

/// AuthController - Manages authentication state
/// 
/// ✅ Google login only - uses JWT token stored via ApiDioProvider
/// Architecture: Flutter App -> FastAPI Backend -> PostgreSQL
class AuthController extends ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();

  bool _isLoading = false;
  String? _errorMessage;
  ApiUser? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ApiUser? get currentUser => _currentUser;

  // Initialize auth service
  AuthController() {
    _initAuthService();
  }

  Future<void> _initAuthService() async {
    // Check if user has saved session (JWT token exists)
    try {
      final token = await ApiDioProvider.getToken();
      if (token != null && token.isNotEmpty) {
        final user = await _authRepo.getCurrentUser();
        _currentUser = user;
        notifyListeners();
      }
    } catch (_) {
      // No valid token, user must login
      _currentUser = null;
    }
  }

  // ============ GOOGLE SIGN-IN (PRIMARY) ============
  Future<bool> signInWithGoogle(String idToken) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepo.googleSignIn(idToken: idToken);
      _currentUser = response.user;
      _errorMessage = null;
      debugPrint('✅ Google Sign-In Success: ${_currentUser?.username}');
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      debugPrint('❌ Google Sign-In Error: ${e.message}');
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan tidak terduga. Silakan coba lagi.';
      debugPrint('❌ Unexpected Google Sign-In Error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============ API LOGIN (FALLBACK) ============
  Future<bool> loginWithUsername(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepo.login(
        username: username,
        password: password,
      );
      _currentUser = response.user;
      _errorMessage = null;
      debugPrint('✅ API Login Success: ${_currentUser?.username}');
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      debugPrint('❌ Login Error: ${e.message}');
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan tidak terduga. Silakan coba lagi.';
      debugPrint('❌ Unexpected Login Error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============ API REGISTER (FALLBACK) ============
  Future<bool> register({
    required String name,
    required String username,
    required String password,
    String? gugusDepan,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepo.register(
        name: name,
        username: username,
        password: password,
        gugusDepan: gugusDepan,
      );
      _currentUser = response.user;
      _errorMessage = null;
      debugPrint('✅ API Register Success: ${_currentUser?.username}');
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      debugPrint('❌ Register Error: ${e.message}');
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan tidak terduga. Silakan coba lagi.';
      debugPrint('❌ Unexpected Register Error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============ LOGOUT ============
  /// Clear all state for logout - CRITICAL for preventing data leak between users
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('🧹 AuthController.logout() - Clearing authentication state');
      
      // Clear JWT token
      await _authRepo.logout();
      
      // Clear current user
      _currentUser = null;
      _errorMessage = null;
      
      debugPrint('✅ AuthController logout successful');
    } catch (e) {
      debugPrint('⚠️ Logout error: $e');
      // Even if logout fails, clear local state
      _currentUser = null;
      _errorMessage = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============ UTILITY METHODS ============
  Future<bool> isLoggedIn() async {
    try {
      final token = await ApiDioProvider.getToken();
      if (token == null || token.isEmpty) return false;
      await _authRepo.getCurrentUser();
      return true;
    } catch (_) {
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}