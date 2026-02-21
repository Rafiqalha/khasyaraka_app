import 'package:flutter/material.dart'; // Force Rebuild 2
import 'package:provider/provider.dart';
import 'package:scout_os_app/shared/theme/app_theme.dart';
// Import from features structure
import 'package:scout_os_app/features/home/logic/training_controller.dart';
import 'package:scout_os_app/features/mission/subfeatures/sku/controllers/sku_controller.dart';
import 'package:scout_os_app/features/auth/logic/auth_controller.dart';
import 'features/auth/logic/login_controller.dart';

import 'package:scout_os_app/features/auth/presentation/login_screen.dart';
import 'package:scout_os_app/features/auth/presentation/register_page.dart';
import 'package:scout_os_app/core/widgets/duo_main_scaffold.dart';
import 'package:scout_os_app/features/intro/logic/intro_controller.dart';
import 'package:scout_os_app/features/intro/presentation/pages/onboarding_page.dart';
import 'package:scout_os_app/features/intro/presentation/pages/splash_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/survival/logic/survival_mastery_controller.dart';
import 'package:scout_os_app/features/mission/subfeatures/survival/logic/survival_tools_controller.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/logic/cyber_controller.dart';
import 'package:scout_os_app/features/profile/logic/profile_controller.dart';
import 'package:scout_os_app/features/leaderboard/controllers/leaderboard_controller.dart';
import 'package:scout_os_app/routes/app_routes.dart';
import 'package:scout_os_app/core/services/local_cache_service.dart';
import 'package:scout_os_app/core/services/in_app_update_service.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';
import 'package:scout_os_app/shared/theme/theme_controller.dart'; // [NEW]

void main() async {
  // Force rebuild
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local cache (Hive) for SWR pattern
  await LocalCacheService.init();

  // Check for Google Play updates (forces immediate update if available)
  await InAppUpdateService.checkForUpdate();

  // Set up global navigation for Dio interceptor
  final navigatorKey = GlobalKey<NavigatorState>();
  ApiDioProvider.setNavigatorKey(navigatorKey);

  runApp(ScoutOSApp(navigatorKey: navigatorKey));
}

/// Main Application Widget
///
/// Implements Duolingo-inspired UI/UX with:
/// - Bright, playful color scheme
/// - Bold typography (Nunito font)
/// - Smooth page transitions
/// - Consistent theme across all screens
class ScoutOSApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const ScoutOSApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Register controllers for state management
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => LoginController()),
        ChangeNotifierProxyProvider<AuthController, TrainingController>(
          create: (context) {
            final ac = Provider.of<AuthController>(context, listen: false);
            return TrainingController(authController: ac);
          },
          update: (context, ac, previous) {
            // Reuse previous instance to avoid disposing while async ops are in flight
            return previous ?? TrainingController(authController: ac);
          },
        ),
        ChangeNotifierProvider(create: (_) => SkuController()),
        ChangeNotifierProvider(create: (_) => IntroController()),

        ChangeNotifierProvider(create: (_) => SurvivalMasteryController()),
        ChangeNotifierProvider(create: (_) => SurvivalToolsController()),
        ChangeNotifierProvider(create: (_) => LeaderboardController()),
        ChangeNotifierProvider(create: (_) => CyberController()),
        ChangeNotifierProvider(create: (_) => ThemeController()), // [NEW]
        ChangeNotifierProxyProvider3<
          TrainingController,
          LeaderboardController,
          AuthController,
          ProfileController
        >(
          create: (context) {
            final tc = Provider.of<TrainingController>(context, listen: false);
            final lc = Provider.of<LeaderboardController>(
              context,
              listen: false,
            );
            final ac = Provider.of<AuthController>(context, listen: false);
            return ProfileController(
              trainingController: tc,
              leaderboardController: lc,
              authController: ac,
            );
          },
          update: (context, tc, lc, ac, previous) {
            if (previous != null) {
              // Keep references up to date
              previous.leaderboardController ??= lc;
              return previous;
            }
            return ProfileController(
              trainingController: tc,
              leaderboardController: lc,
              authController: ac,
            );
          },
        ),
      ],
      child: Consumer2<AuthController, ThemeController>(
        builder: (context, authController, themeController, child) {
          return MaterialApp(
            // App Metadata
            title: 'Khasyaraka - Scout OS',
            debugShowCheckedModeBanner: false,

            // Global navigator key for Dio interceptor
            navigatorKey: navigatorKey,

            // App Theme
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode,

            // Initial Route — uses AuthController.tryAutoLogin()
            home: FutureBuilder<bool>(
              future: authController.tryAutoLogin(),
              builder: (context, snapshot) {
                // Show splash while checking auth state
                if (!snapshot.hasData) {
                  return const SplashPage();
                }

                // Route based on auth state
                final isLoggedIn = snapshot.data!;
                if (isLoggedIn) {
                  return const DuoMainScaffold();
                } else {
                  return const OnboardingPage();
                }
              },
            ),

            // Page Transitions
            themeAnimationDuration: const Duration(milliseconds: 300),
            themeAnimationCurve: Curves.easeInOut,

            // Routes Configuration
            routes: {
              '/splash': (context) => const SplashPage(),
              '/onboarding': (context) => const OnboardingPage(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterPage(),
              '/dashboard': (context) => const DuoMainScaffold(),
              '/penegak': (context) => const DuoMainScaffold(),
            },
            onGenerateRoute: AppRoutes.generateRoute,
          );
        },
      ),
    );
  }
}
