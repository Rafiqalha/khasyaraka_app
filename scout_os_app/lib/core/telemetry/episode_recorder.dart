import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../features/learning/infrastructure/sources/telemetry_api_client.dart';
import 'telemetry.dart';

class EpisodeRecorder {
  static final EpisodeRecorder instance = EpisodeRecorder._internal();
  
  EpisodeRecorder._internal();

  TelemetryApiClient? _apiClient;
  Timer? _idleTimer;
  
  String? _currentEpisodeId;
  String? _currentActivityId;
  String? _currentMissionId;
  Map<String, dynamic> _intentEvolution = {};
  
  List<RawInteractionEvent> _eventsBuffer = [];
  List<Map<String, dynamic>> _snapshotsBuffer = [];
  List<Map<String, dynamic>> _reflectionsBuffer = [];

  void init(TelemetryApiClient apiClient) {
    _apiClient = apiClient;
  }

  void startEpisode({required String activityId, required String missionId}) {
    if (_currentEpisodeId != null) {
      flush(); // Flush previous if exists
    }
    _currentEpisodeId = const Uuid().v4();
    _currentActivityId = activityId;
    _currentMissionId = missionId;
    _intentEvolution = {};
    _eventsBuffer.clear();
    _snapshotsBuffer.clear();
    _reflectionsBuffer.clear();
    _resetIdleTimer();
  }

  void updateIntent(String newIntent) {
    _intentEvolution[DateTime.now().toIso8601String()] = newIntent;
  }

  void recordEvent(RawInteractionEvent event) {
    if (_currentEpisodeId == null) return;
    _eventsBuffer.add(event);
    _resetIdleTimer();
    
    // Smart flush on specific boundaries
    if (event.eventType == CognitiveEvent.compile.name || 
        event.eventType == CognitiveEvent.activityCompleted.name ||
        event.eventType == CognitiveEvent.focusLost.name) {
      flush();
    }
  }

  void recordSnapshot(String type, Map<String, dynamic> data) {
    if (_currentEpisodeId == null) return;
    _snapshotsBuffer.add({
      'snapshot_type': type,
      'data': data,
    });
  }

  void recordReflection(String question, String answer) {
    if (_currentEpisodeId == null) return;
    _reflectionsBuffer.add({
      'question': question,
      'answer': answer,
    });
    flush(); // Usually reflect is at the end
  }

  void _resetIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(seconds: 10), () {
      if (_eventsBuffer.isNotEmpty) {
        // Record an idle/thinking paused event
        _eventsBuffer.add(RawInteractionEvent(
          eventType: CognitiveEvent.thinkingPaused.name,
          durationMs: 10000,
        ));
        flush();
      }
    });
  }

  Future<void> flush() async {
    if (_currentEpisodeId == null) return;
    if (_eventsBuffer.isEmpty && _snapshotsBuffer.isEmpty && _reflectionsBuffer.isEmpty) return;

    final payload = {
      'episode_id': _currentEpisodeId,
      'activity_id': _currentActivityId,
      'mission_id': _currentMissionId,
      'schema_version': '1.0.0',
      'intent_evolution': _intentEvolution,
      'events': _eventsBuffer.map((e) => e.toJson()).toList(),
      'snapshots': List.from(_snapshotsBuffer),
      'reflections': List.from(_reflectionsBuffer),
    };

    // Keep the buffers empty after capturing payload
    _eventsBuffer.clear();
    _snapshotsBuffer.clear();
    _reflectionsBuffer.clear();

    if (_apiClient != null) {
      try {
        await _apiClient!.sendEpisode(payload);
        // ignore: avoid_print
        print("[EPISODE FLUSHED] Flushed episode to backend");
      } catch (e) {
        // ignore: avoid_print
        print("[EPISODE FLUSH FAILED] Error: $e");
        // In a real app we would persist to Hive here on failure
      }
    }
  }
}
