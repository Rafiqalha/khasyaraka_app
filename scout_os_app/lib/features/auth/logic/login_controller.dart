import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/core/services/google_sign_in_service.dart';
import 'package:scout_os_app/core/services/local_cache_service.dart';
import 'package:scout_os_app/features/auth/logic/auth_controller.dart';

class LoginController extends ChangeNotifier {
  final GoogleSignInService _googleService = GoogleSignInService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loginWithGoogle(BuildContext context) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('🔵 [LOGIN] Starting Google Sign-In flow...');

      // 1. Google Sign-In via centralized service (handles retry internally)
      final idToken = await _googleService.signIn();

      if (idToken == null) {
        // User cancelled
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (!context.mounted) return;

      // 2. Backend Auth
      debugPrint('🔵 [LOGIN] Authenticating with backend...');
      final authController = context.read<AuthController>();
      final success = await authController.signInWithGoogle(idToken);

      if (!success) {
        throw Exception(
          authController.errorMessage ?? 'Gagal autentikasi dengan server',
        );
      }

      debugPrint('✅ [LOGIN] Backend authentication successful');

      // 3. Cleanup cache untuk fresh data
      await LocalCacheService.clear();
      if (!context.mounted) return;

      // 4. Force refresh & navigate
      authController.notifyListeners();
      await Future.delayed(const Duration(milliseconds: 200));

      if (context.mounted) {
        debugPrint('🚀 [LOGIN] Navigating to home...');
        Navigator.pushReplacementNamed(context, '/penegak');
      }
    } catch (e) {
      debugPrint('❌ [LOGIN] Error: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'Login Gagal'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
