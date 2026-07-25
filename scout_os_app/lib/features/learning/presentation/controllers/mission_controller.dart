import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/usecases/complete_mission_usecase.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/di/inject_controller.dart';
import '../../infrastructure/dtos/learning_request_dtos.dart';
import '../../infrastructure/dtos/submission_response_dto.dart';
import 'thinking_controller.dart';
import '../../../../core/telemetry/telemetry.dart';

enum MissionState {
  idle,
  editing,
  running,
  passed,
  failed,
  completed
}

class MissionNotifier extends Notifier<MissionState> {
  late final CompleteMissionUseCase _useCase;

  @override
  MissionState build() {
    _useCase = ref.watch(completeMissionUseCaseProvider);
    final box = Hive.box('mission_state');
    final restoredString = box.get('state') as String?;
    
    if (restoredString != null) {
      return MissionState.values.firstWhere(
        (e) => e.name == restoredString,
        orElse: () => MissionState.idle,
      );
    }
    
    return MissionState.idle;
  }

  void _saveState(MissionState newState) {
    state = newState;
    Hive.box('mission_state').put('state', newState.name);
  }

  void editCode() {
    _saveState(MissionState.editing);
  }

  Future<void> runTests(String code) async {
    _saveState(MissionState.running);
    
    // For Sprint YC Demo: We bypass the strict journeyState session check
    // to allow standalone demoing of the MissionPage.
    final sessionId = ref.read(journeyProvider).session?.sessionId ?? 'demo_session_1';
    final nodeId = 'demo_node_1';
    
    final request = MissionSubmissionRequestDto(
      learningSessionId: sessionId,
      nodeId: nodeId,
      language: 'python', 
      code: code,
      clientVersion: '1.0.0',
      attempt: 1,
    );
    
    // Telemetry: MissionStarted (also acts as MissionRun)
    Telemetry.track(
      event: CognitiveEvent.run,
      payload: {
        'code': code,
        'language': 'python',
        'nodeId': nodeId,
      },
    );// Tell ThinkingController to start progressive simulation
    ref.read(thinkingProvider.notifier).startSimulation();
    
    final (statusDto, failure) = await _useCase.call(request);
    
    if (failure != null || statusDto == null) {
      _saveState(MissionState.failed);
      ref.read(thinkingProvider.notifier).failSimulation();
      return;
    }

    String submissionId = statusDto.submissionId;
    
    // Polling loop
    int attempts = 0;
    int maxAttempts = 30; // Max 60s
    SubmissionStatusResponseDto currentStatus = statusDto;

    while (currentStatus.status != 'COMPLETED' && currentStatus.status != 'FAILED' && attempts < maxAttempts) {
      // Adaptive delay: 1s, 2s, then 3s
      int delaySec = attempts == 0 ? 1 : (attempts == 1 ? 2 : 3);
      await Future.delayed(Duration(seconds: delaySec));
      
      final checkUseCase = ref.read(checkSubmissionStatusUseCaseProvider);
      final (pollStatus, pollFailure) = await checkUseCase.call(submissionId);
      
      if (pollFailure == null && pollStatus != null) {
         currentStatus = pollStatus;
         ref.read(thinkingProvider.notifier).updateProgress(currentStatus.progress, currentStatus.step);
      }
      
      attempts++;
    }

    if (currentStatus.status == 'COMPLETED' && currentStatus.result != null) {
      if (currentStatus.result!.verdict == 'PASSED') {
        _saveState(MissionState.passed);
        
        Telemetry.track(
          event: CognitiveEvent.testPassed,
        );
      } else {
        _saveState(MissionState.failed);
        
        Telemetry.track(
          event: CognitiveEvent.testFailed,
          payload: {'error': currentStatus.result!.feedback},
        );
      }
      ref.read(thinkingProvider.notifier).completeWithRealData(currentStatus.result!);
    } else if (attempts >= maxAttempts) {
      ref.read(thinkingProvider.notifier).switchToBackground();
    } else {
      _saveState(MissionState.failed);
      ref.read(thinkingProvider.notifier).failSimulation();
    }
  }
  
  void complete() {
    _saveState(MissionState.completed);
    
    // For Sprint YC demo, complete acts as Goal Completed
    final sessionId = ref.read(journeyProvider).session?.sessionId ?? 'demo_session_1';
    Telemetry.track(
      event: CognitiveEvent.activityCompleted,
    );
  }

  void reset() {
    _saveState(MissionState.idle);
  }
}
