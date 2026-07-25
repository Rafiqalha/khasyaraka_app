import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../learning/infrastructure/dtos/learning_request_dtos.dart';
import '../../../learning/infrastructure/dtos/submission_response_dto.dart';
import '../../../../core/telemetry/telemetry.dart';
import '../../../../core/network/api_dio_provider.dart';
import '../../../../core/config/environment.dart';

enum WorkspaceState {
  idle,
  running,
  completed,
  failed,
}

class WorkspaceData {
  final WorkspaceState state;
  final List<String> consoleLogs;
  final String? analysisFeedback;
  final bool? isPassed;

  WorkspaceData({
    required this.state,
    this.consoleLogs = const [],
    this.analysisFeedback,
    this.isPassed,
  });

  WorkspaceData copyWith({
    WorkspaceState? state,
    List<String>? consoleLogs,
    String? analysisFeedback,
    bool? isPassed,
  }) {
    return WorkspaceData(
      state: state ?? this.state,
      consoleLogs: consoleLogs ?? this.consoleLogs,
      analysisFeedback: analysisFeedback ?? this.analysisFeedback,
      isPassed: isPassed ?? this.isPassed,
    );
  }
}

class WorkspaceController extends Notifier<WorkspaceData> {
  @override
  WorkspaceData build() {
    return WorkspaceData(state: WorkspaceState.idle);
  }

  Future<void> _postEvent(String sessionId, String event, String data) async {
    try {
      final dio = ApiDioProvider.getDio();
      final host = Environment.apiBaseUrl.replaceAll(RegExp(r'/api/v\d+$'), '');
      await dio.post('$host/api/v2/runtime/events', data: {
        'session_id': sessionId,
        'event': event,
        'data': data,
      });
    } catch (e) {
      // Ignore event posting errors in MVP
    }
  }

  void appendLog(String log) {
    state = state.copyWith(consoleLogs: [...state.consoleLogs, log]);
  }

  Future<void> runCode({
    required String code,
    required String language,
    required String sessionId,
    required String nodeId,
  }) async {
    final cmd = language == 'python' ? 'python3 main.py' : 'run main';
    state = WorkspaceData(
      state: WorkspaceState.running,
      consoleLogs: ['scout@sandbox:~\$ $cmd'],
    );
    
    // Simulate container build
    await Future.delayed(const Duration(milliseconds: 500));
    appendLog('[sandbox] Provisioning isolated container...');
    
    await Future.delayed(const Duration(milliseconds: 300));
    appendLog('[sandbox] Executing code...');
    
    final request = MissionSubmissionRequestDto(
      learningSessionId: sessionId,
      nodeId: nodeId,
      language: language, 
      code: code,
      clientVersion: '1.0.0',
      attempt: 1,
    );

    await _postEvent(sessionId, 'CODE_EXECUTED', 'language=$language');
    
    // Telemetry: ActivityStarted
    Telemetry.track(
      event: CognitiveEvent.run,
      payload: {'codeLength': code.length, 'language': language},
    );

    final useCase = ref.read(completeMissionUseCaseProvider);
    final (statusDto, failure) = await useCase.call(request);
    
    if (failure != null || statusDto == null) {
      appendLog('\n[sandbox] Execution failed: ${failure?.message ?? 'Unknown error'}');
      state = state.copyWith(
        state: WorkspaceState.failed,
        analysisFeedback: 'Failed to communicate with sandbox.',
        isPassed: false,
      );
      return;
    }

    // YC Sprint: Backend evaluates synchronously and returns COMPLETED immediately
    if (statusDto.status == 'COMPLETED' && statusDto.result != null) {
      final passed = statusDto.result!.verdict == 'PASSED';
      
      if (passed) {
        appendLog('\n[sandbox] Process exited gracefully with code 0.');
      } else {
        appendLog('\n[sandbox] Process returned non-zero exit code.');
      }
      
      String feedback = statusDto.result!.feedback;
      if (!passed && statusDto.result!.aiAnalysis != null) {
        final ai = statusDto.result!.aiAnalysis!;
        // Print the raw traceback first!
        if (feedback.isNotEmpty) {
          appendLog(feedback);
        }
        appendLog('\n[pradigi-os] DIAGNOSIS: ${ai.diagnosis}');
        appendLog('[pradigi-os] SUGGESTION: ${ai.suggestion}');
        await _postEvent(sessionId, 'AI_ANALYZED', '');
      } else if (passed) {
        appendLog('\n[pradigi-os] Pradigi Evaluation: All tests passed successfully.');
      } else {
        appendLog('\n[pradigi-os] $feedback');
      }

      if (passed) {
        await _postEvent(sessionId, 'NODE_COMPLETED', '');
      }

      state = state.copyWith(
        state: WorkspaceState.completed,
        isPassed: passed,
        analysisFeedback: passed ? 'All tests passed successfully.' : feedback,
      );
      
      Telemetry.track(
        event: passed ? CognitiveEvent.testPassed : CognitiveEvent.testFailed,
      );
    } else {
       // Fallback in case of polling needed (ideally backend is sync)
       state = state.copyWith(
         state: WorkspaceState.failed,
         analysisFeedback: 'Execution timed out or backend returned pending status in sync mode.',
         isPassed: false,
       );
    }
  }

  void reset() {
    state = WorkspaceData(state: WorkspaceState.idle);
  }
}

final workspaceProvider = NotifierProvider<WorkspaceController, WorkspaceData>(() {
  return WorkspaceController();
});
