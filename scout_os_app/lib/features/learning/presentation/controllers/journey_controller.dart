import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/learning_entities.dart';
import '../../domain/repositories/journey_repository.dart';
import '../../infrastructure/sources/journey_api_client.dart';
import '../../infrastructure/repositories/journey_repository_impl.dart';
import '../../../../core/telemetry/telemetry.dart';

// Providers for dependencies (Clean Architecture injection)
final journeyApiClientProvider = Provider<JourneyApiClient>((ref) {
  return JourneyApiClient();
});

final journeyRepositoryProvider = Provider<JourneyRepository>((ref) {
  final apiClient = ref.watch(journeyApiClientProvider);
  return JourneyRepositoryImpl(apiClient);
});

class JourneyState {
  final bool isLoading;
  final String? errorMessage;
  final Journey? journey;
  final int currentIndex;

  JourneyNode? get currentNode => journey != null && journey!.nodes.isNotEmpty ? journey!.nodes[currentIndex] : null;
  bool get hasNext => journey != null && currentIndex < journey!.nodes.length - 1;

  const JourneyState({
    this.isLoading = true,
    this.errorMessage,
    this.journey,
    this.currentIndex = 0,
  });

  JourneyState copyWith({
    bool? isLoading,
    String? errorMessage,
    Journey? journey,
    int? currentIndex,
  }) {
    return JourneyState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      journey: journey ?? this.journey,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class JourneyNotifier extends StateNotifier<JourneyState> {
  final JourneyRepository _repository;

  JourneyNotifier(this._repository) : super(const JourneyState()) {
    _loadJourney();
  }

  Future<void> _loadJourney() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    // Using Result<T> functional pattern
    final result = await _repository.loadJourney("j_1");

    result.fold(
      (journey) {
        state = state.copyWith(
          isLoading: false,
          journey: journey,
          currentIndex: 0,
        );
        
        Telemetry.track(event: JourneyEvent.journeyStarted);
        if (state.currentNode != null) {
          _emitNodeEntered(state.currentNode!);
        }
      },
      (error, stackTrace) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        );
      },
    );
  }

  void nextNode() {
    if (state.hasNext && state.currentNode != null) {
      final oldNode = state.currentNode!;
      
      Telemetry.track(
        event: JourneyEvent.nodeExited,
        metadata: {'nodeId': oldNode.id, 'telemetryKey': oldNode.telemetryKey},
      );
      
      state = state.copyWith(currentIndex: state.currentIndex + 1);
      
      if (state.currentNode != null) {
        _emitNodeEntered(state.currentNode!);
      }
    } else {
      Telemetry.track(
        event: JourneyEvent.journeyCompleted,
      );
    }
  }
  
  void _emitNodeEntered(JourneyNode node) {
    Telemetry.track(
      event: JourneyEvent.nodeEntered,
      metadata: {'nodeId': node.id, 'telemetryKey': node.telemetryKey},
    );
  }
}

final journeyProvider = StateNotifierProvider<JourneyNotifier, JourneyState>((ref) {
  final repo = ref.watch(journeyRepositoryProvider);
  return JourneyNotifier(repo);
});
