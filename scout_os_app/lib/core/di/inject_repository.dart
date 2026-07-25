import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'inject_api.dart';
import '../../features/learning/domain/repositories/journey_repository.dart';
import '../../features/learning/domain/repositories/mission_repository.dart';
import '../../features/learning/infrastructure/repositories/journey_repository_impl.dart';
import '../../features/learning/infrastructure/repositories/mission_repository_impl.dart';

final journeyRepositoryProvider = Provider<JourneyRepository>((ref) {
  final apiClient = ref.watch(journeyApiClientProvider);
  return JourneyRepositoryImpl(apiClient);
});

final missionRepositoryProvider = Provider<MissionRepository>((ref) {
  final apiClient = ref.watch(missionApiClientProvider);
  return MissionRepositoryImpl(apiClient);
});
