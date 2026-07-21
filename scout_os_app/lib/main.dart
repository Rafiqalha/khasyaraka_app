import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:scout_os_app/shared/theme/app_theme.dart';
import 'package:scout_os_app/features/auth/logic/auth_controller.dart';
import 'package:scout_os_app/features/auth/logic/login_controller.dart';
import 'package:scout_os_app/features/auth/presentation/login_screen.dart';
import 'package:scout_os_app/features/auth/presentation/register_page.dart';
import 'package:scout_os_app/features/auth/presentation/change_password_screen.dart';
import 'package:scout_os_app/features/intro/logic/intro_controller.dart';
import 'package:scout_os_app/features/intro/presentation/pages/onboarding_page.dart';
import 'package:scout_os_app/features/intro/presentation/pages/splash_page.dart';
import 'package:scout_os_app/features/profile/logic/profile_controller.dart';
import 'package:scout_os_app/routes/app_routes.dart';
import 'package:scout_os_app/core/services/local_cache_service.dart';
import 'package:scout_os_app/core/services/in_app_update_service.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';
import 'package:scout_os_app/shared/theme/theme_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:scout_os_app/core/services/analytics_service.dart';
import 'package:intl/date_symbol_data_local.dart';
// ── AI Academy (Active — Core Loop) ──
import 'package:scout_os_app/features/ai_academy/logic/academy_controller.dart';
import 'package:scout_os_app/features/ai_academy/presentation/pages/academy_home_page.dart';
import 'package:scout_os_app/features/ai_academy/presentation/pages/experiment_workspace_page.dart';
import 'package:scout_os_app/features/ai_academy/presentation/pages/mission_summary_page.dart';
import 'package:scout_os_app/features/ai_academy/presentation/pages/capability_dashboard_page.dart';

// ── FROZEN: Noise Controllers ──────────────────────────────────
// These imports are kept so the codebase compiles. The controllers
// are NOT registered in the Provider tree. See migration plan v3.
// import 'package:scout_os_app/features/home/logic/training_controller.dart';
// import 'package:scout_os_app/features/mission/subfeatures/sku/controllers/sku_controller.dart';
// import 'package:scout_os_app/features/mission/logic/mission_controller.dart';
// import 'package:scout_os_app/features/group_chat/logic/group_chat_controller.dart';
// import 'package:scout_os_app/features/mission/subfeatures/survival/logic/survival_mastery_controller.dart';
// import 'package:scout_os_app/features/mission/subfeatures/survival/logic/survival_tools_controller.dart';
// import 'package:scout_os_app/features/mission/subfeatures/cyber/logic/cyber_controller.dart';
// import 'package:scout_os_app/features/leaderboard/controllers/leaderboard_controller.dart';
// import 'package:scout_os_app/features/mission/logic/mission_state_controller.dart';
// import 'package:scout_os_app/features/capability/logic/capability_controller.dart';
// import 'package:scout_os_app/features/operations/logic/operation_controller.dart';
// import 'package:scout_os_app/core/data/repositories/mock/mock_mission_repository.dart';
// import 'package:scout_os_app/core/data/repositories/mock/mock_capability_repository.dart';
// import 'package:scout_os_app/core/data/repositories/mock/mock_operation_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb || (!Platform.isLinux && !Platform.isWindows)) {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Firebase initialization skipped: $e');
  }

  await LocalCacheService.init();
  await InAppUpdateService.checkForUpdate();
  await initializeDateFormatting();

  final navigatorKey = GlobalKey<NavigatorState>();
  ApiDioProvider.setNavigatorKey(navigatorKey);

  runApp(PradigiApp(navigatorKey: navigatorKey));
}

class PradigiApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const PradigiApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ── Core Infrastructure Controllers ──
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => LoginController()),
        ChangeNotifierProvider(create: (_) => IntroController()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(
          create: (_) => ProfileController(
            authController: null,
          ),
        ),

        // ── AI Academy Controller (Core Loop) ──
        ChangeNotifierProvider(create: (_) => AcademyController()),

        // ── FROZEN: Noise Controllers ────────────────────────
        // These are NOT registered. Zero runtime impact.
        // Kept as import comments above for compilation safety.
        // TrainingController, SkuController, MissionController,
        // GroupChatController, SurvivalMasteryController,
        // SurvivalToolsController, LeaderboardController,
        // CyberController, MissionStateController,
        // CapabilityController, OperationController (all frozen)
      ],
      child: Consumer2<AuthController, ThemeController>(
        builder: (context, authController, themeController, child) {
          return MaterialApp(
            title: 'Pradigi — AI Academy',
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode,

            home: FutureBuilder<bool>(
              future: authController.tryAutoLogin(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SplashPage();
                }

                final isLoggedIn = snapshot.data!;
                if (isLoggedIn) {
                  if (authController.mustChangePassword) {
                    return const ChangePasswordScreen();
                  }
                  if (authController.currentUser != null &&
                      !authController.currentUser!.locationSet) {
                  }
                  return const AcademyHomePage();
                } else {
                  return const LoginScreen();
                }
              },
            ),

            routes: {
              '/splash': (context) => const SplashPage(),
              '/onboarding': (context) => const OnboardingPage(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterPage(),
              '/change-password': (context) =>
                  const ChangePasswordScreen(),
              '/location-setup': (context) =>
              '/experiment-workspace': (context) =>
                  const ExperimentWorkspacePage(),
              '/mission-summary': (context) =>
                  const MissionSummaryPage(),
              '/capability-dashboard': (context) =>
                  const CapabilityDashboardPage(),
            },

            navigatorObservers: [
              if (AnalyticsService.observer != null)
                AnalyticsService.observer!,
            ],
            onGenerateRoute: AppRoutes.generateRoute,
          );
        },
      ),
    );
  }
}
