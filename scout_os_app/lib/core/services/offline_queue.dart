import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Offline Telemetry Queue using SharedPreferences.
/// 
/// Architecture Note:
/// When the user has no network (field operations, camping areas), 
/// telemetry (Operation submissions, Assessment results) is queued locally.
/// On reconnect, the SyncEngine drains the queue to the Go backend.
///
/// In Phase 8 production, this should be upgraded to Hive or Isar 
/// for larger, structured offline storage and better query performance.
class OfflineQueue {
  static const String _queueKey = 'offline_telemetry_queue';

  /// Enqueue a telemetry event to persist locally
  static Future<void> enqueue(TelemetryEvent event) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = _loadQueue(prefs);
    queue.add(event.toJson());
    await prefs.setString(_queueKey, jsonEncode(queue));
  }

  /// Peek at all queued events without removing them
  static Future<List<TelemetryEvent>> peek() async {
    final prefs = await SharedPreferences.getInstance();
    return _loadQueue(prefs).map(TelemetryEvent.fromJson).toList();
  }

  /// Drain events that have been successfully synced to backend
  static Future<void> removeIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = _loadQueue(prefs);
    queue.removeWhere((e) => ids.contains(e['id']));
    await prefs.setString(_queueKey, jsonEncode(queue));
  }

  /// Clear the entire queue (after full sync)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_queueKey);
  }

  static List<Map<String, dynamic>> _loadQueue(SharedPreferences prefs) {
    final raw = prefs.getString(_queueKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }
}

/// A serializable telemetry event for offline queueing
class TelemetryEvent {
  final String id;
  final String type;         // e.g. 'operation_submit', 'mission_start'
  final Map<String, dynamic> payload;
  final DateTime timestamp;

  TelemetryEvent({
    required this.id,
    required this.type,
    required this.payload,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'payload': payload,
    'timestamp': timestamp.toIso8601String(),
  };

  factory TelemetryEvent.fromJson(Map<String, dynamic> json) => TelemetryEvent(
    id: json['id'] as String,
    type: json['type'] as String,
    payload: json['payload'] as Map<String, dynamic>,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}
