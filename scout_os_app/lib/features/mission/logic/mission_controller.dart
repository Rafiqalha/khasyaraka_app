import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:dio/dio.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';
import 'package:scout_os_app/core/config/environment.dart';

class MissionController extends ChangeNotifier {
  final Dio _dio = ApiDioProvider.getDio();

  String? _missionId;
  Map<String, dynamic>? _state;
  final List<Map<String, dynamic>> _events = [];
  final List<Map<String, dynamic>> _logs = [];
  String _searchQuery = '';
  WebSocketChannel? _wsChannel;
  int _timeRemaining = 300;
  int _score = 0;
  bool _isLoading = false;
  String? _error;

  String? get missionId => _missionId;
  Map<String, dynamic>? get state => _state;
  List<Map<String, dynamic>> get events => _events;
  List<Map<String, dynamic>> get filteredLogs {
    if (_searchQuery.isEmpty) return _logs;
    return _logs.where((l) {
      final msg = (l['message'] ?? '').toString().toLowerCase();
      final ip = (l['source_ip'] ?? '').toString().toLowerCase();
      final svc = (l['service'] ?? '').toString().toLowerCase();
      final status = (l['status'] ?? '').toString();
      final q = _searchQuery.toLowerCase();
      return msg.contains(q) || ip.contains(q) || svc.contains(q) || status.contains(q);
    }).toList();
  }
  int get timeRemaining => _timeRemaining;
  int get score => _score;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  int get serverHealth => _state?['server_health'] as int? ?? 100;
  int get cpuLoad => 100 - serverHealth;
  List<String> get activeThreats => (_state?['active_threats'] as List?)?.cast<String>() ?? [];
  List<String> get breachedServers => (_state?['breached_servers'] as List?)?.cast<String>() ?? [];
  List<String> get blockedIPs => (_state?['blocked_ips'] as List?)?.cast<String>() ?? [];
  String get phase => _state?['phase'] as String? ?? 'recon';
  List<Map<String, dynamic>> get servers => (_state?['servers'] as List?)?.cast<Map<String, dynamic>>() ?? [];
  List<Map<String, dynamic>> get processes => (_state?['processes'] as List?)?.cast<Map<String, dynamic>>() ?? [];
  String get latestAIEvent => events.isNotEmpty ? (events.first['message']?.toString() ?? '') : '';

  bool isServerBreached(String id) => breachedServers.contains(id);
  int serverCpu(String id) {
    if (isServerBreached(id)) return 85 + (15 - (serverHealth ~/ 7)).clamp(0, 15);
    if (id == 'server-01') return cpuLoad.clamp(10, 98);
    return (cpuLoad - (id == 'server-02' ? 10 : 20)).clamp(5, 95);
  }
  String serverStatus(String id) {
    if (isServerBreached(id)) return 'BREACHED';
    if (serverHealth < 30) return 'DEGRADED';
    return 'ONLINE';
  }

  Future<void> generateMission(String persona) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final resp = await _dio.post('/missions/generate', data: {'persona': persona});
      final data = resp.data['data'];
      _missionId = data['mission_id'];
      _state = Map<String, dynamic>.from(data);
      _logs.clear();
      _logs.addAll((data['logs'] as List).map((e) => Map<String, dynamic>.from(e)));
      _timeRemaining = data['time_remaining'] ?? 300;
      _score = 0;
      _events.clear();

      _connectWS();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _connectWS() {
    if (_missionId == null) return;
    _wsChannel?.sink.close();

    final host = Environment.apiBaseUrl
        .replaceFirst('http://', '')
        .replaceFirst('https://', '')
        .replaceAll('/api/v1', '')
        .split('/')
        .first;

    final token = ApiDioProvider.cachedToken;
    if (token == null || token.isEmpty) {
      debugPrint('[MISSION] No cached token for WS connection');
      return;
    }

    try {
      final uri = Uri.parse('ws://$host/api/v1/missions/$_missionId/stream?token=$token');
      debugPrint('[MISSION] Connecting WS: $host');
      _wsChannel = WebSocketChannel.connect(uri);
      _wsChannel!.stream.listen((data) {
        final msg = jsonDecode(data);
        if (msg['type'] == 'state') _onStateUpdate(msg['data']);
        if (msg['type'] == 'event') _onEvent(msg['data']);
      }, onError: (e) {
        debugPrint('[MISSION] WS stream error: $e');
      }, onDone: () {
        debugPrint('[MISSION] WS stream closed');
      });
      debugPrint('[MISSION] WS connected successfully');
    } catch (e) {
      debugPrint('[MISSION] WS connect failed: $e');
    }
  }

  void _onStateUpdate(dynamic stateData) {
    if (stateData is Map<String, dynamic>) {
      _state = stateData;
      _timeRemaining = stateData['time_remaining'] ?? _timeRemaining;
      _score = stateData['score'] ?? _score;
      notifyListeners();
    }
  }

  void _onEvent(dynamic eventData) {
    if (eventData is Map<String, dynamic>) {
      _events.insert(0, eventData);
      if (_events.length > 50) _events.removeLast();

      final msg = eventData['message']?.toString() ?? '';
      if (msg.contains('RANSOMWARE') || msg.contains('MISSION TIME')) {
        _timeRemaining = 0;
      }
      notifyListeners();
    }
  }

  Future<void> sendAction(String type, Map<String, dynamic> payload) async {
    if (_missionId == null) return;
    try {
      final resp = await _dio.post('/missions/$_missionId/action', data: {'type': type, 'payload': payload});
      final data = resp.data['data'];
      if (data['new_state'] != null) {
        _state = Map<String, dynamic>.from(data['new_state']);
        _timeRemaining = _state!['time_remaining'] ?? _timeRemaining;
        _score = _state!['score'] ?? _score;

        _logs.clear();
        final logs = _state!['logs'];
        if (logs is List) _logs.addAll(logs.cast<Map<String, dynamic>>());
      }
      if (data['score_change'] != null) {
        _score += (data['score_change'] as num).toInt();
      }
      if (data['message'] != null) {
        _events.insert(0, {'type': 'action_result', 'severity': 'info', 'message': data['message']});
      }
      notifyListeners();
    } catch (e) {
      _events.insert(0, {'type': 'error', 'severity': 'error', 'message': 'Action failed: $e'});
    }
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  @override
  void dispose() {
    _wsChannel?.sink.close();
    super.dispose();
  }
}
