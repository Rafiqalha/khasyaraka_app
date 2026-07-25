import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Consumer;
import 'package:hive_flutter/hive_flutter.dart';
import 'design_system/theme/app_theme.dart';
import 'features/mission/presentation/pages/home_page.dart';
import 'features/auth/presentation/login_screen.dart';
import 'core/telemetry/episode_recorder.dart';
import 'features/learning/infrastructure/sources/telemetry_api_client.dart';
import 'core/network/api_dio_provider.dart';
import 'package:provider/provider.dart';
import 'features/auth/logic/auth_controller.dart';
import 'features/auth/logic/login_controller.dart';
import 'features/mission/logic/mission_controller.dart';
import 'features/os/presentation/shell/os_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Open boxes
  await Hive.openBox('journey_cache');
  await Hive.openBox('mission_state');
  
  EpisodeRecorder.instance.init(DioTelemetryApiClient(ApiDioProvider.getDio()));

  runApp(
    ProviderScope(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthController()),
          ChangeNotifierProvider(create: (_) => LoginController()),
          ChangeNotifierProvider(create: (_) => MissionController()),
        ],
        child: const PradigiApp(),
      ),
    ),
  );
}
class PradigiApp extends StatelessWidget {
  const PradigiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pradigi OS',
      theme: PradigiTheme.lightTheme,
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        if (!authController.isInitialized) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(color: Colors.black),
            ),
          );
        }

        if (authController.currentUser != null) {
          return const OSLauncher();
        }

        return const LoginScreen();
      },
    );
  }
}
