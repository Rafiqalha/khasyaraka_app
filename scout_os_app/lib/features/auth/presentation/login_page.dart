import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:scout_os_app/features/home/logic/training_controller.dart';
import 'package:scout_os_app/features/auth/logic/auth_controller.dart';
import 'package:scout_os_app/core/services/local_cache_service.dart';
import 'package:scout_os_app/shared/theme/app_colors.dart';
import 'package:scout_os_app/shared/theme/app_text_styles.dart';

/// Login Page - Google Sign-In Only
/// 
/// NOTE: This implementation uses FastAPI backend with Google OAuth.
/// If you want to use Supabase OAuth instead:
/// 1. Add `supabase_flutter: ^2.x.x` to pubspec.yaml
/// 2. Initialize Supabase in main.dart
/// 3. Replace the _googleSignIn() method to use supabase.auth.signInWithIdToken()
/// 
/// TODO: Add your Google OAuth Web Client ID below
/// Get it from: https://console.cloud.google.com/apis/credentials
/// For Android: Use the Web Client ID (not Android Client ID)
/// For iOS: You may need a separate iOS Client ID
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Professional Enterprise Color Palette
  // constants removed in favor of AppColors
  
  // Google OAuth Web Client ID
  // Get it from: https://console.cloud.google.com/apis/credentials
  static const String _webClientId = '890949539640-b6pggk05brv780fott32uq1leckbkg80.apps.googleusercontent.com';
  
  // TODO: For iOS, you may need a separate iOS Client ID
  // static const String _iosClientId = 'YOUR_IOS_CLIENT_ID_HERE';
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  /// Check if user already has a valid session and auto-redirect
  Future<void> _checkExistingSession() async {
    try {
      final authController = Provider.of<AuthController>(context, listen: false);
      final isLoggedIn = await authController.isLoggedIn();
      
      if (isLoggedIn && mounted) {
        debugPrint('✅ [LOGIN_PAGE] User already logged in, redirecting to home');
        // User already logged in, redirect to home
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/penegak');
          }
        });
      } else {
        debugPrint('ℹ️ [LOGIN_PAGE] No valid session found, showing login page');
      }
    } catch (e) {
      // No valid session, stay on login page (this is expected)
      debugPrint('ℹ️ [LOGIN_PAGE] No valid session: ${e.toString()}');
    }
  }

  /// Perform Google Sign-In and authenticate with backend
  Future<void> _googleSignIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('🔵 [LOGIN_PAGE] Starting Google Sign-In flow...');
      
      // Step 1: Perform Google Sign In
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: _webClientId,
        scopes: ['email', 'profile'],
      );

      debugPrint('🔵 [LOGIN_PAGE] Opening Google Sign-In dialog...');
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        debugPrint('ℹ️ [LOGIN_PAGE] User cancelled Google Sign-In');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      debugPrint('✅ [LOGIN_PAGE] Google Sign-In successful: ${googleUser.email}');
      
      // Step 2: Get authentication tokens
      debugPrint('🔵 [LOGIN_PAGE] Getting authentication tokens...');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.idToken == null) {
        debugPrint('❌ [LOGIN_PAGE] ID token is null');
        throw Exception('Failed to get ID token from Google Sign-In. Please check your Web Client ID configuration.');
      }

      debugPrint('✅ [LOGIN_PAGE] ID token received, length: ${googleAuth.idToken!.length}');

      // Step 3: Sign in to backend (FastAPI)
      // The backend endpoint POST /api/v1/auth/google expects { "id_token": "..." }
      debugPrint('🔵 [LOGIN_PAGE] Authenticating with backend...');
      final authController = Provider.of<AuthController>(context, listen: false);
      
      // Call backend Google Sign-In endpoint via AuthController
      final success = await authController.signInWithGoogle(googleAuth.idToken!);
      
      if (!success) {
        debugPrint('❌ [LOGIN_PAGE] Backend authentication failed: ${authController.errorMessage}');
        throw Exception(authController.errorMessage ?? 'Gagal autentikasi dengan server');
      }

      debugPrint('✅ [LOGIN_PAGE] Backend authentication successful');
      
      // ✅ HARD RESET: Clear stale cache to prevent type errors
      await LocalCacheService.clear();
      debugPrint('🧹 [LOGIN_PAGE] Cleared stale cache');
      
      // Load user stats
      debugPrint('🔵 [LOGIN_PAGE] Loading user stats...');
      await context.read<TrainingController>().loadUserStats();
      
      debugPrint('✅ [LOGIN_PAGE] Login complete, navigating to home...');
      
      // Navigate to home
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/penegak');
      }

    } catch (e, stackTrace) {
      debugPrint('❌ [LOGIN_PAGE] Google Sign-In error: $e');
      debugPrint('❌ [LOGIN_PAGE] Stack trace: $stackTrace');
      
      // Parse error message for better user feedback
      String errorMessage = 'Gagal masuk dengan Google';
      String detailedError = '';
      
      if (e.toString().contains('ApiException: 10')) {
        errorMessage = 'Konfigurasi Google Sign-In belum lengkap';
        detailedError = 'Error 10: DEVELOPER_ERROR\n\n'
            'Langkah perbaikan:\n'
            '1. Clear app data: adb shell pm clear com.khasyaraka.scout_os\n'
            '2. Clear Google Play Services: adb shell pm clear com.google.android.gms\n'
            '3. Rebuild aplikasi: flutter clean && flutter run\n'
            '4. Pastikan SHA-1 sudah ditambahkan di Google Cloud Console\n'
            '5. Tunggu 10-15 menit setelah menambahkan SHA-1\n\n'
            'Lihat GOOGLE_SIGNIN_TROUBLESHOOTING.md untuk detail lengkap.';
      } else if (e.toString().contains('sign_in_failed')) {
        errorMessage = 'Gagal autentikasi dengan Google';
        detailedError = 'Silakan coba lagi atau periksa koneksi internet Anda.';
      } else {
        detailedError = e.toString().replaceAll('Exception: ', '').replaceAll('PlatformException: ', '');
      }
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  errorMessage,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (detailedError.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    detailedError,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Top Spacer - Push content to center
                    const Spacer(),
                    
                    // Logo Section
                    SvgPicture.asset(
                      'assets/images/logo/wosm_logo.svg',
                      height: 120,
                      fit: BoxFit.contain,
                      semanticsLabel: 'World Organization of the Scout Movement Logo',
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Welcome Text Section
                      Text(
                        'Selamat Datang',
                        style: AppTextStyles.h1.copyWith(
                          color: AppColors.primary,
                          height: 1.2,
                        ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                      Text(
                        'Satu akun untuk semua kegiatan Pramuka',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey[700], // Using grey for secondary text
                          height: 1.4,
                        ),
                      textAlign: TextAlign.center,
                    ),
                    
                    // Bottom Spacer - Push button to bottom
                    const Spacer(),
                    
                    // Google Sign-In Button Section
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _googleSignIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceLight,
                          foregroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.backgroundLight,
                          disabledForegroundColor: Colors.grey,
                          elevation: 2,
                          shadowColor: Colors.black.withValues(alpha: 0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Google Icon
                                  Icon(
                                    Icons.g_mobiledata,
                                    size: 24,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Lanjutkan dengan Google',
                                    style: AppTextStyles.button.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
