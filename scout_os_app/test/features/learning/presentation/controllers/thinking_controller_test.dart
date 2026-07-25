import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scout_os_app/features/learning/presentation/controllers/thinking_controller.dart';
import 'package:scout_os_app/core/di/inject_controller.dart';
import 'package:scout_os_app/features/learning/infrastructure/dtos/submission_response_dto.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('ThinkingController Tests', () {
    test('Initial state is idle and inactive', () {
      final state = container.read(thinkingProvider);
      expect(state.stage, ThinkingStage.idle);
      expect(state.isActive, isFalse);
      expect(state.response, isNull);
    });

    test('startSimulation() progressively updates state', () {
      final notifier = container.read(thinkingProvider.notifier);
      
      notifier.startSimulation();
      
      var state = container.read(thinkingProvider);
      expect(state.stage, ThinkingStage.uploading);
      expect(state.isActive, isTrue);
      expect(state.progress, 5);
      expect(state.statusText, 'QUEUED');

      notifier.updateProgress(50, 'EVALUATING');
      state = container.read(thinkingProvider);
      expect(state.progress, 50);
      expect(state.statusText, 'EVALUATING');
    });

    test('completeWithRealData() finishes animation', () async {
      final notifier = container.read(thinkingProvider.notifier);
      final sub = container.listen(thinkingProvider, (_, __) {});

      notifier.startSimulation();
      
      notifier.completeWithRealData(const SubmissionResponseDto(
        submissionId: 's',
        verdict: 'passed',
        feedback: 'fb',
        evidence: [],
      ));

      var state = container.read(thinkingProvider);
      expect(state.stage, ThinkingStage.updating_competency);
      expect(state.response, isNotNull);

      await Future.delayed(const Duration(milliseconds: 700));
      state = container.read(thinkingProvider);
      expect(state.stage, ThinkingStage.finished);
      expect(state.isActive, isFalse);
    });

    test('stop() deactivates thinking', () {
      final notifier = container.read(thinkingProvider.notifier);
      notifier.stop();
      
      final state = container.read(thinkingProvider);
      expect(state.isActive, isFalse);
    });
  });
}
