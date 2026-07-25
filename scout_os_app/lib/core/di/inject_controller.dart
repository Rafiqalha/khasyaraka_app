import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/learning/presentation/controllers/journey_controller.dart';
import '../../features/learning/presentation/controllers/mission_controller.dart';
import '../../features/learning/presentation/controllers/thinking_controller.dart';

final journeyProvider = NotifierProvider<JourneyNotifier, JourneyState>(JourneyNotifier.new);
final missionProvider = NotifierProvider<MissionNotifier, MissionState>(MissionNotifier.new);
final thinkingProvider = NotifierProvider<ThinkingNotifier, ThinkingState>(ThinkingNotifier.new);
