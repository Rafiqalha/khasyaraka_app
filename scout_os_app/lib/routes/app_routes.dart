import 'package:flutter/material.dart';
import 'package:scout_os_app/features/home/presentation/pages/training_path_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/sku/views/sku_main_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/sku/views/sku_list_view.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/cyber_boot_screen.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/cyber_dashboard_screen.dart';
import 'package:scout_os_app/features/mission/subfeatures/survival/presentation/pages/survival_tools_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/survival/presentation/pages/tools/clinometer_tool_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/survival/presentation/pages/tools/compass_tool_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/survival/presentation/pages/tools/gps_tracker_tool_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/survival/presentation/pages/tools/river_tool_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/survival/presentation/pages/tools/pedometer_pro_screen.dart';
import 'package:scout_os_app/features/mission/subfeatures/survival/presentation/pages/tools/morse_touch_screen.dart';
import 'package:scout_os_app/features/billing/views/subscription_page.dart';
import 'package:scout_os_app/features/profile/presentation/pages/profile_page.dart';
import 'package:scout_os_app/features/profile/models/public_profile_model.dart';

class AppRoutes {
  static const trainingMap = '/training-map';
  static const skuMap = '/sku-map';
  static const skuList = '/sku-list';
  static const cyberMissionControl = '/cyber/mission-control';
  static const cyberDashboard = '/cyber/dashboard';
  static const cyberBriefing = '/cyber/briefing';
  static const cyberLevelSelection = '/cyber/levels';
  static const cyberDecryption = '/cyber/decryption';
  static const survivalTools = '/survival/tools';
  static const survivalClinometer = '/survival/clinometer';
  static const survivalCompass = '/survival/compass';
  static const survivalGpsTracker = '/survival/gps';
  static const survivalRiver = '/survival/river';
  static const survivalPedometer = '/survival/pedometer';
  static const survivalMorse = '/survival/morse';
  static const subscription = '/subscription';
  static const publicProfile = '/public-profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case trainingMap:
        return MaterialPageRoute(builder: (_) => const TrainingPathPage());
      case skuMap:
        return MaterialPageRoute(builder: (_) => const SkuMainPage());
      case skuList:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final level = args["level"] as String? ?? "bantara";
        return MaterialPageRoute(builder: (_) => SkuListView(level: level));
      case cyberMissionControl:
        return MaterialPageRoute(builder: (_) => const CyberBootScreen());
      case cyberDashboard:
        return MaterialPageRoute(builder: (_) => const CyberDashboardScreen());
      case survivalTools:
        return MaterialPageRoute(builder: (_) => const SurvivalToolsPage());
      case survivalCompass:
        return MaterialPageRoute(builder: (_) => const CompassToolPage());
      case survivalClinometer:
        return MaterialPageRoute(builder: (_) => const ClinometerToolPage());
      case survivalGpsTracker:
        return MaterialPageRoute(builder: (_) => const GpsTrackerToolPage());
      case survivalRiver:
        return MaterialPageRoute(builder: (_) => const RiverToolPage());
      case survivalPedometer:
        return MaterialPageRoute(builder: (_) => const PedometerProScreen());
      case survivalMorse:
        return MaterialPageRoute(builder: (_) => const MorseTouchScreen());
      case subscription:
        return MaterialPageRoute(builder: (_) => const SubscriptionPage());
      case publicProfile:
        final publicProfileData = settings.arguments as PublicProfileModel?;
        return MaterialPageRoute(
          builder: (_) =>
              ProfilePage(publicProfile: publicProfileData, isReadOnly: true),
        );
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
