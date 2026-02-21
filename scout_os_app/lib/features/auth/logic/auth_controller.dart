import 'package:flutter/material.dart';
import 'package:scout_os_app/features/auth/data/auth_repository.dart';
import 'package:scout_os_app/features/auth/data/auth_exception.dart';
import 'package:scout_os_app/core/services/secure_storage_service.dart';
import 'package:scout_os_app/core/services/google_sign_in_service.dart';

/// AuthController - Manages authentication state
///
/// ✅ PERSISTENT LOGIN: Uses secure storage for auto-login
/// Architecture: Flutter App -> FastAPI Backend -> PostgreSQL
/// Features: Auto-login, secure token storage, Google Sign-In integration
class AuthController extends ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();

  bool _isLoading = false;
  String? _errorMessage;
  ApiUser? _currentUser;
  bool _isInitialized = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ApiUser? get currentUser => _currentUser;
  bool get isInitialized => _isInitialized;

  // Initialize auth service with auto-login check
  AuthController() {
    _initializeAuth();
  }

  /// Initialize authentication state with auto-login
  Future<void> _initializeAuth() async {
    debugPrint('🔐 [AUTH] Initializing authentication service...');

    try {
      // Check if we have a valid session
      final hasValidSession = await SecureStorageService.hasValidSession();

      if (hasValidSession) {
        debugPrint('✅ [AUTH] Valid session found, attempting auto-login...');

        // Try to get current user from API to validate token
        try {
          final user = await _authRepo.getCurrentUser();
          _currentUser = user;
          debugPrint(
            '✅ [AUTH] Auto-login successful: ${_currentUser?.username}',
          );
        } catch (e) {
          debugPrint(
            '⚠️ [AUTH] Auto-login failed, clearing invalid session: $e',
          );
          await _authRepo.logout();
        }
      } else {
        debugPrint('ℹ️ [AUTH] No valid session found, user must login');
      }
    } catch (e) {
      debugPrint('❌ [AUTH] Initialization error: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
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

      // Save user data to secure storage for persistence
      await SecureStorageService.saveUserData(_currentUser!);

      // CRITICAL: Force state update and notify all listeners
      _errorMessage = null;
      debugPrint('✅ Google Sign-In Success: ${_currentUser?.username}');
      debugPrint('🔄 [AUTH] Forcing state update for all listeners...');

      // Notify listeners multiple times to ensure UI updates
      notifyListeners();

      // Additional notification after a small delay to ensure all widgets update
      await Future.delayed(const Duration(milliseconds: 100));
      notifyListeners();

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

      // Save user data to secure storage for persistence
      await SecureStorageService.saveUserData(_currentUser!);

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

      // Save user data to secure storage for persistence
      await SecureStorageService.saveUserData(_currentUser!);

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

  /// Complete logout with Google Sign-In disconnect
  /// Uses GoogleSignInService for centralized cache clearing
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint(
        '🧹 AuthController.logout() - Starting complete logout process',
      );

      // 1. Clear JWT token and secure storage
      await _authRepo.logout();

      // 2. Clear current user state
      _currentUser = null;
      _errorMessage = null;

      // 3. Sign out of Google via centralized service
      await GoogleSignInService().signOut();

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
  /// Check if user is logged in (has valid session)
  Future<bool> isLoggedIn() async {
    return await SecureStorageService.hasValidSession() && _currentUser != null;
  }

  /// Try auto-login (called from main.dart)
  Future<bool> tryAutoLogin() async {
    if (!_isInitialized) {
      await _initializeAuth();
    }
    return _currentUser != null;
  }

  /// Force refresh user data from API
  Future<void> refreshUser() async {
    if (_currentUser != null) {
      try {
        final user = await _authRepo.getCurrentUser(forceRefresh: true);
        _currentUser = user;
        await SecureStorageService.saveUserData(_currentUser!);
        notifyListeners();
        debugPrint('✅ [AUTH] User data refreshed');
      } catch (e) {
        debugPrint('⚠️ [AUTH] Failed to refresh user: $e');
      }
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
