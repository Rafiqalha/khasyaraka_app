import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scout_os_app/features/learning/presentation/controllers/mission_controller.dart';
import 'package:scout_os_app/features/learning/domain/usecases/complete_mission_usecase.dart';
import 'package:scout_os_app/features/learning/domain/usecases/check_submission_status_usecase.dart';
import 'package:scout_os_app/core/di/providers.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'package:scout_os_app/core/error/failures.dart';
import 'package:scout_os_app/features/learning/infrastructure/dtos/submission_response_dto.dart';
import 'package:scout_os_app/features/learning/infrastructure/dtos/learning_request_dtos.dart';
import 'package:scout_os_app/core/di/inject_controller.dart';
import 'package:scout_os_app/features/learning/domain/entities/learning_entities.dart';
import 'package:scout_os_app/features/learning/presentation/controllers/journey_controller.dart';

class MockCompleteMissionUseCase extends Mock implements CompleteMissionUseCase {}
class MockCheckSubmissionStatusUseCase extends Mock implements CheckSubmissionStatusUseCase {}

class FakeMissionSubmissionRequestDto extends Fake implements MissionSubmissionRequestDto {}

class MockJourneyNotifier extends Notifier<JourneyState> with Mock implements JourneyNotifier {
  @override
  JourneyState build() => JourneyState(
        isLoading: false,
        journey: null,
        currentNodeId: 'n1',
        session: LearningSession(
          sessionId: 's1',
          userId: 'u1',
          learningGoalId: 'goal_1',
          activityId: 'node_1',
          startedAt: DateTime.now(),
          lastInteractionAt: DateTime.now(),
          elapsedTime: Duration.zero,
          attempt: 1,
          deviceId: 'd1',
          appVersion: '1.0',
          locale: 'en',
          platform: 'web',
          telemetrySessionId: 't1',
          status: LearningSessionStatus.active,
        ),
      );
}

void main() {
  late MockCompleteMissionUseCase mockUseCase;
  late MockCheckSubmissionStatusUseCase mockCheckUseCase;
  late ProviderContainer container;
  late Directory tempDir;

  setUpAll(() {
    registerFallbackValue(FakeMissionSubmissionRequestDto());
  });

  setUp(() async {
    mockUseCase = MockCompleteMissionUseCase();
    mockCheckUseCase = MockCheckSubmissionStatusUseCase();
    tempDir = await Directory.systemTemp.createTemp('hive_test_mission');
    Hive.init(tempDir.path);
    await Hive.openBox('mission_state');
    
    container = ProviderContainer(
      overrides: [
        completeMissionUseCaseProvider.overrideWithValue(mockUseCase),
        checkSubmissionStatusUseCaseProvider.overrideWithValue(mockCheckUseCase),
        journeyProvider.overrideWith(MockJourneyNotifier.new),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('MissionController Tests', () {
    test('Initial state is idle', () {
      final state = container.read(missionProvider);
      expect(state, MissionState.idle);
    });

    test('editCode transitions to editing', () {
      final notifier = container.read(missionProvider.notifier);
      notifier.editCode();
      expect(container.read(missionProvider), MissionState.editing);
    });

    test('runTests transitions to running then passed if success', () async {
      when(() => mockUseCase.call(any())).thenAnswer((_) async => (
            const SubmissionStatusResponseDto(
              submissionId: 's',
              status: 'QUEUED',
              progress: 5,
            ),
            null
          ));
          
      when(() => mockCheckUseCase.call(any())).thenAnswer((_) async => (
            const SubmissionStatusResponseDto(
              submissionId: 's',
              status: 'COMPLETED',
              progress: 100,
              result: SubmissionResponseDto(
                submissionId: 's',
                verdict: 'PASSED',
                feedback: 'Great!',
                evidence: [],
              )
            ),
            null
          ));

      final notifier = container.read(missionProvider.notifier);
      final sub = container.listen(missionProvider, (_, __) {});

      final future = notifier.runTests("mock_code");
      
      expect(container.read(missionProvider), MissionState.running);
      
      await future;
      
      expect(container.read(missionProvider), MissionState.passed);
      sub.close();
    });

    test('runTests transitions to failed if error', () async {
      when(() => mockUseCase.call(any())).thenAnswer((_) async => (null, const FatalFailure('error')));

      final notifier = container.read(missionProvider.notifier);
      final future = notifier.runTests("mock_code");
      
      await future;
      
      expect(container.read(missionProvider), MissionState.failed);
    });
    
    test('complete transitions to completed', () {
      final notifier = container.read(missionProvider.notifier);
      notifier.complete();
      expect(container.read(missionProvider), MissionState.completed);
    });
  });
}
