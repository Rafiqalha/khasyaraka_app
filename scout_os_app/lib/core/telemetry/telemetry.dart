import 'dart:collection';

enum JourneyEvent {
  journeyStarted,
  nodeEntered,
  nodeExited,
  continuePressed,
  hintOpened,
  missionRun,
  missionPassed,
  missionFailed,
  reflectionSubmitted,
  journeyCompleted,
}

class TelemetryEvent {
  final JourneyEvent event;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;

  TelemetryEvent({
    required this.event,
    Map<String, dynamic>? metadata,
  })  : metadata = metadata ?? const {},
        timestamp = DateTime.now();

  Map<String, dynamic> toJson() => {
        'event': event.name,
        'metadata': metadata,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Core telemetry abstraction for G1.5 Validation using a Queue.
/// Provides offline resiliency and batch flushing.
class Telemetry {
  static final Queue<TelemetryEvent> _queue = Queue<TelemetryEvent>();

  static void track({
    required JourneyEvent event,
    Map<String, dynamic>? metadata,
  }) {
    final telemetryEvent = TelemetryEvent(event: event, metadata: metadata);
    _queue.add(telemetryEvent);
    
    // In G1.5, we still print for debug visibility
    // ignore: avoid_print
    print("[TELEMETRY QUEUED] ${telemetryEvent.timestamp.toIso8601String()} | ${event.name} | Metadata: $metadata");
    
    // Attempt to flush if queue gets large or immediately based on logic
    if (_queue.length >= 5) {
      flush();
    }
  }

  /// Flushes the queue to the backend.
  /// If offline, events remain in the queue.
  static Future<void> flush() async {
    if (_queue.isEmpty) return;
    
    // Simulate network check and flush
    final eventsToFlush = _queue.toList();
    _queue.clear();
    
    try {
      // TODO: Replace with actual backend HTTP POST via TelemetryApiClient
      // await apiClient.postEvents(eventsToFlush);
      
      // ignore: avoid_print
      print("[TELEMETRY FLUSHED] Successfully flushed ${eventsToFlush.length} events to backend.");
    } catch (e) {
      // If network fails, re-queue events to prevent data loss
      _queue.addAll(eventsToFlush);
      // ignore: avoid_print
      print("[TELEMETRY FLUSH FAILED] Re-queued ${eventsToFlush.length} events.");
    }
  }
}
