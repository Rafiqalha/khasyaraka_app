import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/core/services/local_cache_service.dart';
import 'package:scout_os_app/features/auth/logic/auth_controller.dart';
import 'package:scout_os_app/features/home/logic/training_controller.dart';

class LoginController extends ChangeNotifier {
  // Google OAuth Web Client ID
  // Get it from: https://console.cloud.google.com/apis/credentials
  static const String _webClientId = '890949539640-b6pggk05brv780fott32uq1leckbkg80.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: _webClientId,
    serverClientId: kIsWeb ? null : _webClientId,
    scopes: ['email', 'profile'],
  );

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

      // 1. Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        debugPrint('ℹ️ [LOGIN] User cancelled Google Sign-In');
        _isLoading = false;
        notifyListeners();
        return;
      }

      debugPrint('✅ [LOGIN] Google Sign-In successful: ${googleUser.email}');

      // 2. Get Tokens
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null) {
        throw Exception('Failed to get ID token from Google Sign-In');
      }

      if (!context.mounted) return;

      // 3. Backend Auth
      debugPrint('🔵 [LOGIN] Authenticating with backend...');
      final authController = context.read<AuthController>();
      final success = await authController.signInWithGoogle(googleAuth.idToken!);

      if (!success) {
        throw Exception(authController.errorMessage ?? 'Gagal autentikasi dengan server');
      }

      debugPrint('✅ [LOGIN] Backend authentication successful');

      // 4. Cleanup & Data Load
      await LocalCacheService.clear();
      if (!context.mounted) return;
      
      await context.read<TrainingController>().loadUserStats();

      // 5. Navigate
      if (context.mounted) {
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
