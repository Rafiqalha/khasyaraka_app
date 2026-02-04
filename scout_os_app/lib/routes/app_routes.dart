import 'package:flutter/material.dart';
import 'package:scout_os_app/features/home/presentation/pages/training_map_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/sku/views/sku_main_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/sku/views/sku_list_view.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/cyber_boot_screen.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/cyber_dashboard_screen.dart';
import 'package:scout_os_app/features/mission/subfeatures/survival/presentation/pages/survival_tools_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/survival/presentation/pages/tools/clinometer_tool_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/survival/presentation/pages/tools/compass_tool_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/survival/presentation/pages/tools/gps_tracker_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/survival/presentation/pages/tools/river_tool_page.dart';

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

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case trainingMap:
        return MaterialPageRoute(
          builder: (_) => const TrainingMapPage(),
        );
      case skuMap:
        return MaterialPageRoute(
          builder: (_) => const SkuMainPage(),
        );
      case skuList:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final level = args["level"] as String? ?? "bantara";
        return MaterialPageRoute(
          builder: (_) => SkuListView(level: level),
        );
      case cyberMissionControl:
        return MaterialPageRoute(
          builder: (_) => const CyberBootScreen(),
        );
      case cyberDashboard:
        return MaterialPageRoute(
          builder: (_) => const CyberDashboardScreen(),
        );
      case survivalTools:
        return MaterialPageRoute(
          builder: (_) => const SurvivalToolsPage(),
        );
      case survivalCompass:
        return MaterialPageRoute(
          builder: (_) => const CompassToolPage(),
        );
      case survivalClinometer:
        return MaterialPageRoute(
          builder: (_) => const ClinometerToolPage(),
        );
      case survivalGpsTracker:
        return MaterialPageRoute(
          builder: (_) => const GpsTrackerPage(),
        );
      case survivalRiver:
        return MaterialPageRoute(
          builder: (_) => const RiverToolPage(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
