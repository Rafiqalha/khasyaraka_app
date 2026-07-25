import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../infrastructure/dtos/submission_response_dto.dart';

enum ThinkingStage {
  idle,
  uploading,
  evaluating,
  updating_competency,
  background_processing,
  finished
}

class ThinkingState {
  final ThinkingStage stage;
  final bool isActive;
  final SubmissionResponseDto? response;
  final bool hasFailed;
  final int progress;
  final String statusText;

  const ThinkingState({
    this.stage = ThinkingStage.idle,
    this.isActive = false,
    this.response,
    this.hasFailed = false,
    this.progress = 0,
    this.statusText = '',
  });
  
  ThinkingState copyWith({
    ThinkingStage? stage,
    bool? isActive,
    SubmissionResponseDto? response,
    bool? hasFailed,
    int? progress,
    String? statusText,
  }) {
    return ThinkingState(
      stage: stage ?? this.stage,
      isActive: isActive ?? this.isActive,
      response: response ?? this.response,
      hasFailed: hasFailed ?? this.hasFailed,
      progress: progress ?? this.progress,
      statusText: statusText ?? this.statusText,
    );
  }
}

class ThinkingNotifier extends Notifier<ThinkingState> {
  Timer? _timer;

  @override
  ThinkingState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return const ThinkingState();
  }

  void startSimulation() {
    _timer?.cancel();
    state = const ThinkingState(
      stage: ThinkingStage.uploading, 
      isActive: true, 
      progress: 5, 
      statusText: 'QUEUED'
    );
  }

  void updateProgress(int progress, String statusText) {
    state = state.copyWith(progress: progress, statusText: statusText);
  }

  void failSimulation() {
    _timer?.cancel();
    state = state.copyWith(isActive: false, hasFailed: true);
  }

  void switchToBackground() {
    _timer?.cancel();
    state = state.copyWith(stage: ThinkingStage.background_processing, isActive: true);
  }

  void completeWithRealData(SubmissionResponseDto response) {
    _timer?.cancel();
    state = state.copyWith(
      stage: ThinkingStage.updating_competency,
      response: response,
      progress: 100,
      statusText: 'COMPLETED',
    );
    
    // Finish animation
    _timer = Timer(const Duration(milliseconds: 600), () {
      state = state.copyWith(stage: ThinkingStage.finished, isActive: false);
    });
  }

  void stop() {
    _timer?.cancel();
    state = const ThinkingState(stage: ThinkingStage.idle, isActive: false);
  }
}


