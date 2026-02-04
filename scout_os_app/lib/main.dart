import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/core/config/duo_theme.dart'; // Import Duolingo theme
// Import from features structure
import 'package:scout_os_app/features/home/logic/training_controller.dart';
import 'package:scout_os_app/features/mission/subfeatures/sku/controllers/sku_controller.dart';
import 'package:scout_os_app/features/auth/logic/auth_controller.dart';
import 'package:scout_os_app/features/auth/presentation/login_page.dart';
import 'package:scout_os_app/features/auth/presentation/register_page.dart';
import 'package:scout_os_app/core/widgets/duo_main_scaffold.dart';
import 'package:scout_os_app/features/intro/logic/intro_controller.dart';
import 'package:scout_os_app/features/intro/presentation/pages/onboarding_page.dart';
import 'package:scout_os_app/features/intro/presentation/pages/splash_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/survival/logic/survival_mastery_controller.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/logic/cyber_controller.dart';
import 'package:scout_os_app/features/profile/logic/profile_controller.dart';
import 'package:scout_os_app/features/leaderboard/controllers/leaderboard_controller.dart';
import 'package:scout_os_app/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();

  runApp(const ScoutOSApp());
}

/// Main Application Widget
/// 
/// Implements Duolingo-inspired UI/UX with:
/// - Bright, playful color scheme
/// - Bold typography (Nunito font)
/// - Smooth page transitions
/// - Consistent theme across all screens
class ScoutOSApp extends StatelessWidget {
  const ScoutOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Register controllers for state management
        ChangeNotifierProvider(create: (_) => TrainingController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => SkuController()),
        ChangeNotifierProvider(create: (_) => IntroController()),
        ChangeNotifierProvider(create: (_) => SurvivalMasteryController()),
        ChangeNotifierProvider(create: (_) => LeaderboardController()), // ✅ Add LeaderboardController to global providers
        ChangeNotifierProvider(create: (_) => CyberController()), // ✅ Add CyberController for Sandi tools
        ChangeNotifierProxyProvider<TrainingController, ProfileController>(
          create: (context) {
            final tc = Provider.of<TrainingController>(context, listen: false);
            return ProfileController(trainingController: tc);
          },
          update: (_, tc, previous) => previous ?? ProfileController(trainingController: tc),
        ),
      ],
      child: MaterialApp(
        // App Metadata
        title: 'Khasyaraka - Scout OS',
        debugShowCheckedModeBanner: false,
        
        // Duolingo Theme
        theme: DuoTheme.lightTheme,
        
        // Initial Route
        home: const SplashPage(),
        
        // Page Transitions (Duolingo-style: smooth and bouncy)
        themeAnimationDuration: const Duration(milliseconds: 300),
        themeAnimationCurve: Curves.easeInOut,
        
        // Routes Configuration
        routes: {
          '/splash': (context) => const SplashPage(),
          '/onboarding': (context) => const OnboardingPage(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/dashboard': (context) => const DuoMainScaffold(),
          '/penegak': (context) => const DuoMainScaffold(), // Main Duolingo-style learning path                                                                                                                                                                                                               
        },
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
  }                                                                                                                                                                                                                       
}