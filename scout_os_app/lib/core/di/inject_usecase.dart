import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'inject_repository.dart';
import '../../features/learning/domain/usecases/load_journey_usecase.dart';
import '../../features/learning/domain/usecases/complete_mission_usecase.dart';
import '../../features/learning/domain/usecases/check_submission_status_usecase.dart';
import '../../features/learning/domain/usecases/process_thinking_usecase.dart';

final loadJourneyUseCaseProvider = Provider<LoadJourneyUseCase>((ref) {
  final repository = ref.watch(journeyRepositoryProvider);
  return LoadJourneyUseCase(repository);
});

final completeMissionUseCaseProvider = Provider<CompleteMissionUseCase>((ref) {
  final repository = ref.watch(missionRepositoryProvider);
  return CompleteMissionUseCase(repository);
});

final checkSubmissionStatusUseCaseProvider = Provider<CheckSubmissionStatusUseCase>((ref) {
  final repository = ref.watch(missionRepositoryProvider);
  return CheckSubmissionStatusUseCase(repository);
});

final processThinkingUseCaseProvider = Provider<ProcessThinkingUseCase>((ref) {
  return ProcessThinkingUseCase();
});
