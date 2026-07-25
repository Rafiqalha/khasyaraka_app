import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:scout_os_app/core/config/environment.dart';

// ===========================
// Workbench Controller (GetX) + SSE Client
// Connects to Backend GET /stream, receives WorkspaceRuntimeState updates.
// NEVER uses Future.delayed internally. Reacts purely to SSE patches.
// ===========================

class WorkbenchController extends GetxController {
  // --- Reactive State ---
  
  // Mission
  final missionId = ''.obs;
  final missionTitle = 'Loading Mission...'.obs;
  final missionNarrative = ''.obs;
  final aiBudget = 0.obs;
  final isMissionComplete = false.obs;

  // Editor
  late CodeController codeController;
  final currentFile = 'main.py'.obs;
  
  // Terminal
  final terminalOutput = <String>[].obs;
  final isRunning = false.obs;

  // Mentor
  final chatHistory = <ChatMessage>[].obs;
  final isMentorTyping = false.obs;

  // Timeline
  final timelineEvents = <TimelineEvent>[].obs;

  // Connection
  final connectionStatus = 'Connecting...'.obs;
  
  http.Client? _httpClient;
  String _lastEventId = '';

  @override
  void onInit() {
    super.onInit();
    codeController = CodeController(
      text: '# Write your code here\n',
      language: null,
    );
  }

  void loadMission(String id) {
    missionId.value = id;
    _connectSSE(id);
  }

  // --- SSE Connection (The only source of truth) ---
  void _connectSSE(String sessionId) async {
    _httpClient = http.Client();
    final request = http.Request('GET', Uri.parse('${Environment.apiBaseUrl}/workbench/sessions/$sessionId/stream'));
    if (_lastEventId.isNotEmpty) {
      request.headers['Last-Event-ID'] = _lastEventId;
    }

    try {
      final response = await _httpClient!.send(request);
      connectionStatus.value = 'Connected';

      response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        if (line.startsWith('data:')) {
          final data = line.substring(5).trim();
          _handleStatePatch(data);
        }
      }, onError: (err) {
        connectionStatus.value = 'Reconnecting...';
        Future.delayed(const Duration(seconds: 2), () => _connectSSE(sessionId));
      }, onDone: () {
        connectionStatus.value = 'Disconnected';
      });
    } catch (e) {
      connectionStatus.value = 'Reconnecting...';
      Future.delayed(const Duration(seconds: 2), () => _connectSSE(sessionId));
    }
  }

  void _handleStatePatch(String jsonString) {
    try {
      final patch = jsonDecode(jsonString);
      // In a real implementation, 'patch' would contain only deltas.
      // For this slice, we assume backend sends the full state representation payload in 'delta' or 'state'
      final state = patch['delta'] ?? patch; 

      // 1. Mission Update
      if (state['mission'] != null) {
        missionTitle.value = state['mission']['objective'] ?? missionTitle.value;
        aiBudget.value = state['mission']['ai_budget'] ?? aiBudget.value;
        isMissionComplete.value = state['mission']['status'] == 'COMPLETED';
      }

      // 2. Terminal Update
      if (state['terminal'] != null) {
        final List<dynamic> out = state['terminal']['output'] ?? [];
        terminalOutput.value = out.map((e) => e.toString()).toList();
        
        // Infer running status from runtime state
        if (state['runtime'] != null) {
          isRunning.value = state['runtime']['status'] == 'RUNNING';
        }
      }

      // 3. Timeline Update
      if (state['timeline'] != null) {
        final List<dynamic> tl = state['timeline'] ?? [];
        timelineEvents.value = tl.map((e) => TimelineEvent(
          timestamp: DateTime.parse(e['timestamp']),
          summary: e['summary'],
        )).toList();
      }

      // 4. Mentor Update
      if (state['mentor'] != null) {
        isMentorTyping.value = state['mentor']['is_typing'] ?? false;
        final List<dynamic> history = state['mentor']['chat_history'] ?? [];
        chatHistory.value = history.map((e) => ChatMessage(
          sender: e['sender'],
          text: e['text'],
        )).toList();
      }

    } catch (e) {
      print('Error parsing SSE data: \$e');
    }
  }

  // --- Actions (CQRS Commands sent to backend via HTTP POST) ---

  void runCode() async {
    if (isRunning.value) return;
    
    // Optimistic UI state is minimal. We just tell backend we want to run.
    try {
      await http.post(
        Uri.parse('${Environment.apiBaseUrl}/workbench/sessions/${missionId.value}/commands'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'type': 'RUN_CODE',
          'payload': {
            'source_code': codeController.text,
            'language': 'python'
          }
        }),
      );
    } catch (e) {
      print('Failed to send command: \$e');
    }
  }

  void askMentor(String question) async {
    try {
      await http.post(
        Uri.parse('${Environment.apiBaseUrl}/workbench/sessions/${missionId.value}/commands'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'type': 'ASK_MENTOR',
          'payload': {
            'message': question,
          }
        }),
      );
    } catch (e) {
      print('Failed to send command: \$e');
    }
  }

  @override
  void onClose() {
    _httpClient?.close();
    codeController.dispose();
    super.onClose();
  }
}

// --- DTOs ---

class ChatMessage {
  final String sender;
  final String text;
  ChatMessage({required this.sender, required this.text});
}

class TimelineEvent {
  final DateTime timestamp;
  final String summary;
  TimelineEvent({required this.timestamp, required this.summary});
}
