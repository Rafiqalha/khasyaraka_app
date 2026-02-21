import 'package:flutter/material.dart';
import 'package:scout_os_app/features/intro/presentation/pages/splash_page.dart';
import 'package:scout_os_app/features/intro/presentation/pages/onboarding_page.dart';
import 'package:scout_os_app/features/auth/presentation/login_screen.dart';
import 'package:scout_os_app/features/auth/presentation/register_page.dart';
import 'package:scout_os_app/core/widgets/duo_main_scaffold.dart';
import 'package:scout_os_app/features/profile/presentation/pages/profile_page.dart';
import 'package:scout_os_app/core/services/secure_storage_service.dart';
import 'package:scout_os_app/features/billing/views/subscription_page.dart';

/// Senior Flutter Architect & Backend Specialist Implementation
/// AppRouter untuk navigation management dengan auth guards dan deep linking
class AppRouter {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String leaderboard = '/leaderboard';
  static const String missions = '/missions';
  static const String subscription = '/subscription';

  /// Generate route with auth guard
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashPage(),
          settings: settings,
        );

      case onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingPage(),
          settings: settings,
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
          settings: settings,
        );

      case home:
      case '/penegak':
        return _authGuard(
          builder: (_) => const DuoMainScaffold(),
          settings: settings,
        );

      case profile:
        return _authGuard(
          builder: (_) => const ProfilePage(),
          settings: settings,
        );

      // TODO: Add leaderboard and mission pages when they exist
      // case leaderboard:
      //   return _authGuard(
      //     builder: (_) => const LeaderboardPage(),
      //     settings: settings,
      //     authService: authService,
      //   );
      //
      // case missions:
      //   return _authGuard(
      //     builder: (_) => const MissionPage(),
      //     settings: settings,
      //     authService: authService,
      //   );

      case subscription:
        return _authGuard(
          builder: (_) => const SubscriptionPage(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const SplashPage(),
          settings: settings,
        );
    }
  }

  /// Auth guard - redirect to login if not authenticated
  static Route<dynamic> _authGuard({
    required Widget Function(BuildContext) builder,
    required RouteSettings settings,
  }) {
    return MaterialPageRoute(
      builder: (context) => FutureBuilder<bool>(
        future: SecureStorageService.hasValidSession(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashPage();
          }

          if (snapshot.hasData && snapshot.data == true) {
            return builder(context);
          }

          // Not authenticated, redirect to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(login, (route) => false);
          });

          return const SplashPage();
        },
      ),
      settings: settings,
    );
  }

  /// Navigate with auth check
  static Future<void> navigateWithAuth(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool replace = false,
    bool clearStack = false,
  }) async {
    final isAuthenticated = await SecureStorageService.hasValidSession();

    if (!isAuthenticated && _isProtectedRoute(routeName)) {
      // Redirect to login for protected routes
      if (clearStack) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          login,
          (route) => false,
          arguments: {'redirect_to': routeName},
        );
      } else {
        Navigator.of(
          context,
        ).pushNamed(login, arguments: {'redirect_to': routeName});
      }
      return;
    }

    // Navigate to requested route
    if (clearStack) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        routeName,
        (route) => false,
        arguments: arguments,
      );
    } else if (replace) {
      Navigator.of(
        context,
      ).pushReplacementNamed(routeName, arguments: arguments);
    } else {
      Navigator.of(context).pushNamed(routeName, arguments: arguments);
    }
  }

  /// Check if route requires authentication
  static bool _isProtectedRoute(String routeName) {
    final protectedRoutes = [
      home,
      profile,
      subscription,
      '/penegak',
      // TODO: Add leaderboard and missions when they exist
      // leaderboard,
      // missions,
    ];

    return protectedRoutes.contains(routeName);
  }

  /// Handle deep linking
  static Future<void> handleDeepLink(
    BuildContext context,
    String deepLink, {
    bool clearStack = false,
  }) async {
    try {
      final uri = Uri.parse(deepLink);
      final routeName = uri.path;
      final arguments = uri.queryParameters;

      await navigateWithAuth(
        context,
        routeName,
        arguments: arguments,
        clearStack: clearStack,
      );
    } catch (e) {
      debugPrint('❌ [APP_ROUTER] Deep link error: $e');
      // Fallback to home
      await navigateWithAuth(context, home, clearStack: clearStack);
    }
  }

  /// Logout and navigate to login
  static Future<void> logoutAndNavigateToLogin(
    BuildContext context, {
    bool clearStack = true,
  }) async {
    await SecureStorageService.clearAll();

    if (clearStack) {
      Navigator.of(context).pushNamedAndRemoveUntil(login, (route) => false);
    } else {
      Navigator.of(context).pushReplacementNamed(login);
    }
  }

  /// Get initial route based on auth state
  static Future<String> getInitialRoute() async {
    final isAuthenticated = await SecureStorageService.hasValidSession();

    return isAuthenticated ? home : onboarding;
  }

  /// Navigate back with safety check
  static bool navigateBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return true;
    }
    return false;
  }

  /// Show dialog with navigation
  static Future<T?> showDialogWithNavigation<T>({
    required BuildContext context,
    required Widget dialog,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => dialog,
      barrierDismissible: barrierDismissible,
    );
  }

  /// Show bottom sheet with navigation
  static Future<T?> showBottomSheetWithNavigation<T>({
    required BuildContext context,
    required Widget bottomSheet,
    bool isScrollControlled = false,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      builder: (context) => bottomSheet,
      isScrollControlled: isScrollControlled,
      enableDrag: enableDrag,
    );
  }
}

/// Route arguments constants
class RouteArgs {
  static const String redirectTo = 'redirect_to';
  static const String userId = 'user_id';
  static const String missionId = 'mission_id';
  static const String levelId = 'level_id';
  static const String tab = 'tab';
}

/// Navigation observer for analytics
class NavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _logNavigation('push', route.settings.name);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _logNavigation('pop', route.settings.name);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _logNavigation('replace', newRoute?.settings.name);
  }

  void _logNavigation(String action, String? routeName) {
    debugPrint('🧭 [NAVIGATION] $action: $routeName');
    // Add analytics logging here if needed
  }
}

/// Custom route transitions
class CustomRouteTransitions {
  /// Slide transition from right to left
  static PageRouteBuilder slideTransition({
    required Widget page,
    required RouteSettings settings,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  /// Fade transition
  static PageRouteBuilder fadeTransition({
    required Widget page,
    required RouteSettings settings,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  /// Scale transition
  static PageRouteBuilder scaleTransition({
    required Widget page,
    required RouteSettings settings,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          ),
          child: child,
        );
      },
    );
  }
}
