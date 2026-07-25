import 'package:uuid/uuid.dart';
import 'episode_recorder.dart';

enum CognitiveEvent {
  // Raw Interactions
  codeChanged,
  focusLost,
  focusGained,
  clipboardCopied,
  clipboardPasted,
  textSelected,
  
  // Cognitive Boundaries
  thinkingStarted,
  thinkingPaused,
  thinkingResumed,
  hintOpened,
  hintIgnored,
  
  // Actions
  undo,
  redo,
  compile,
  compileSuccess,
  compileFailed,
  run,
  testPassed,
  testFailed,
  
  // Activity Lifecycle
  activityStarted,
  activityCompleted,
}

class RawInteractionEvent {
  final String id;
  final String eventType;
  final DateTime timestamp;
  final int durationMs;
  final Map<String, dynamic> payload;

  RawInteractionEvent({
    String? id,
    required this.eventType,
    DateTime? timestamp,
    this.durationMs = 0,
    this.payload = const {},
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'event_type': eventType,
        'timestamp': timestamp.toIso8601String(),
        'duration_ms': durationMs,
        'payload': payload,
      };
}

class Telemetry {
  static void track({
    required CognitiveEvent event,
    Map<String, dynamic> payload = const {},
    int durationMs = 0,
  }) {
    final rawEvent = RawInteractionEvent(
      eventType: event.name,
      payload: payload,
      durationMs: durationMs,
    );
    
    EpisodeRecorder.instance.recordEvent(rawEvent);
  }

  static void trackSnapshot(String type, Map<String, dynamic> data) {
    EpisodeRecorder.instance.recordSnapshot(type, data);
  }

  static void trackReflection(String question, String answer) {
    EpisodeRecorder.instance.recordReflection(question, answer);
  }
}
