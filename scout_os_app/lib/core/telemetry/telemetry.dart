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

/// Core telemetry abstraction for G1.5 Validation.
///
/// Currently buffers events to standard output or temporary storage.
/// In G2 (Telemetry Dashboard), this will connect to the real backend.
class Telemetry {
  static void track({
    required JourneyEvent event,
    Map<String, dynamic>? metadata,
  }) {
    // In production, this pushes to the telemetry queue.
    // For G1.5 local validation, we log to help debugging and analysis.
    final timestamp = DateTime.now().toIso8601String();
    
    // ignore: avoid_print
    print("[TELEMETRY] [$timestamp] ${event.name} | Metadata: $metadata");
  }
}
