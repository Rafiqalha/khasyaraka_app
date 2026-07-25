import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/learning_entities.dart';
import '../../../../core/error/failures.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/telemetry/telemetry.dart';
import '../../infrastructure/dtos/learning_request_dtos.dart';
import '../../domain/usecases/load_journey_usecase.dart';

class JourneyState {
  final bool isLoading;
  final Failure? failure;
  final Journey? journey;
  final String? currentNodeId;
  final LearningSession? session;
  final NodeLifecycle lifecycle;

  JourneyNode? get currentNode {
    if (journey == null || currentNodeId == null) return null;
    try {
      return journey!.activities.firstWhere((n) => n.id == currentNodeId);
    } catch (_) {
      return null;
    }
  }

  bool get hasNext {
    if (journey == null || currentNodeId == null) return false;
    final index = journey!.activities.indexWhere((n) => n.id == currentNodeId);
    return index != -1 && index < journey!.activities.length - 1;
  }

  const JourneyState({
    this.isLoading = true,
    this.failure,
    this.journey,
    this.currentNodeId,
    this.session,
    this.lifecycle = NodeLifecycle.enter,
  });

  JourneyState copyWith({
    bool? isLoading,
    Failure? failure,
    Journey? journey,
    String? currentNodeId,
    LearningSession? session,
    NodeLifecycle? lifecycle,
  }) {
    return JourneyState(
      isLoading: isLoading ?? this.isLoading,
      failure: failure, // passing null unsets the failure
      journey: journey ?? this.journey,
      currentNodeId: currentNodeId ?? this.currentNodeId,
      session: session ?? this.session,
      lifecycle: lifecycle ?? this.lifecycle,
    );
  }
}

class JourneyNotifier extends Notifier<JourneyState> {
  late final LoadJourneyUseCase _loadJourneyUseCase;

  @override
  JourneyState build() {
    _loadJourneyUseCase = ref.watch(loadJourneyUseCaseProvider);
    final box = Hive.box('journey_cache');
    final restoredNodeId = box.get('currentNodeId') as String?;

    Future.microtask(() => _loadJourney(restoredNodeId));
    
    return JourneyState(
      currentNodeId: restoredNodeId,
    );
  }

  Future<void> _loadJourney(String? initialNodeId) async {
    state = state.copyWith(isLoading: true, failure: null);

    // 1. Try to load from Cache
    final (cachedJourney, cacheFailure) = await _loadJourneyUseCase.getCachedJourney("soc_fundamentals");
    
    if (cachedJourney != null) {
      state = state.copyWith(
        isLoading: false,
        journey: cachedJourney,
        currentNodeId: initialNodeId ?? (cachedJourney.activities.isNotEmpty ? cachedJourney.activities.first.id : null),
        session: LearningSession(
          sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
          userId: 'u_1', // Hardcoded for now
          learningGoalId: cachedJourney.id,
          activityId: initialNodeId ?? (cachedJourney.activities.isNotEmpty ? cachedJourney.activities.first.id : ''),
          startedAt: DateTime.now(),
          lastInteractionAt: DateTime.now(),
          deviceId: 'device_dummy',
          appVersion: '1.0.0',
          platform: 'linux',
          locale: 'en',
          elapsedTime: Duration.zero,
          attempt: 1,
          telemetrySessionId: 'telemetry_${DateTime.now().millisecondsSinceEpoch}',
          status: LearningSessionStatus.active,
        ),
        lifecycle: NodeLifecycle.enter, // Keep simple for now
      );
      
      Telemetry.track(event: CognitiveEvent.activityStarted);
      if (state.currentNode != null && initialNodeId == null) { // Only auto-enter if not restoring
        enterNode(state.currentNode!.id);
      }
    }

    // 2. Refresh from Network
    final (remoteJourney, remoteFailure) = await _loadJourneyUseCase.refreshJourney(
      const JourneyRequest(academyId: "cyber", curriculumId: "soc_fundamentals")
    );

    if (remoteFailure != null) {
      // If we don't have a cached journey, show failure.
      if (state.journey == null) {
        state = state.copyWith(
          isLoading: false,
          failure: remoteFailure,
        );
      }
    } else if (remoteJourney != null) {
      // Update UI with latest from network quietly
      state = state.copyWith(
        isLoading: false,
        journey: remoteJourney,
        currentNodeId: state.currentNodeId ?? (remoteJourney.activities.isNotEmpty ? remoteJourney.activities.first.id : null),
      );
      
      if (state.currentNodeId == null && state.currentNode != null) {
        enterNode(state.currentNode!.id);
      }
    }
  }

  void enterNode(String nodeId) {
    final box = Hive.box('journey_cache');
    box.put('currentNodeId', nodeId);

    state = state.copyWith(
      currentNodeId: nodeId,
      session: state.session?.copyWith(
        activityId: nodeId,
        lastInteractionAt: DateTime.now(),
      ),
      lifecycle: NodeLifecycle.enter
    );
    
    // Auto interact if passive node
    if (state.currentNode?.type == NodeType.notebook || state.currentNode?.type == NodeType.journeyMap) {
      interactNode();
    }

    final node = state.currentNode;
    if (node != null) {
      Telemetry.track(
        event: CognitiveEvent.activityStarted,
        payload: {'nodeId': node.id, 'telemetryKey': node.telemetryKey},
      );
    }
  }

  void interactNode() {
    if (state.lifecycle == NodeLifecycle.enter || state.lifecycle == NodeLifecycle.build) {
      state = state.copyWith(lifecycle: NodeLifecycle.interact);
    }
  }

  void completeNode() {
    state = state.copyWith(lifecycle: NodeLifecycle.complete);
  }

  void exitNode() {
    state = state.copyWith(lifecycle: NodeLifecycle.exit);
    final node = state.currentNode;
    if (node != null) {
      Telemetry.track(
        event: CognitiveEvent.activityCompleted,
        payload: {'nodeId': node.id, 'telemetryKey': node.telemetryKey},
      );
    }
  }

  void nextNode() {
    if (state.hasNext && state.currentNode != null) {
      exitNode();
      
      final index = state.journey!.activities.indexWhere((n) => n.id == state.currentNodeId);
      final nextNode = state.journey!.activities[index + 1];
      
      enterNode(nextNode.id);
    } else {
      Telemetry.track(
        event: CognitiveEvent.activityCompleted,
      );
    }
  }

  void resetJourney() {
    _loadJourney(null);
  }
}


