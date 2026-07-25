import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Server-Sent Events (SSE) client for real-time AI generation updates.
/// 
/// Why SSE over WebSocket:
/// - AI mission generation is unidirectional: Backend → Client.
/// - SSE uses standard HTTP, no handshake overhead.
/// - Automatic reconnect on disconnect (HTTP semantics).
/// - Better battery efficiency on mobile (no full-duplex socket).
/// - Works transparently through corporate proxies and firewalls.
class SseClient {
  final String url;
  final Map<String, String>? headers;

  StreamController<SseEvent>? _controller;
  http.Client? _httpClient;
  StreamSubscription<List<int>>? _subscription;
  bool _isConnected = false;

  SseClient({required this.url, this.headers});

  Stream<SseEvent> get stream {
    _controller = StreamController<SseEvent>.broadcast();
    _connect();
    return _controller!.stream;
  }

  Future<void> _connect() async {
    _isConnected = true;
    _httpClient = http.Client();

    final request = http.Request('GET', Uri.parse(url));
    request.headers.addAll({
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
      ...?headers,
    });

    try {
      final response = await _httpClient!.send(request);

      if (response.statusCode != 200) {
        _controller?.addError(
          Exception('SSE connection failed: HTTP ${response.statusCode}'),
        );
        return;
      }

      _subscription = response.stream.listen(
        (bytes) {
          final raw = utf8.decode(bytes);
          _parseAndEmit(raw);
        },
        onError: (error) {
          _controller?.addError(error);
          if (_isConnected) {
            // Auto-reconnect after 3 seconds
            Future.delayed(const Duration(seconds: 3), _connect);
          }
        },
        onDone: () {
          if (_isConnected) {
            // Auto-reconnect after 3 seconds
            Future.delayed(const Duration(seconds: 3), _connect);
          }
        },
      );
    } catch (e) {
      _controller?.addError(e);
      if (_isConnected) {
        Future.delayed(const Duration(seconds: 3), _connect);
      }
    }
  }

  void _parseAndEmit(String raw) {
    String? eventType;
    String dataBuffer = '';

    for (final line in raw.split('\n')) {
      if (line.startsWith('event:')) {
        eventType = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        dataBuffer += line.substring(5).trim();
      } else if (line.isEmpty && dataBuffer.isNotEmpty) {
        _controller?.add(SseEvent(type: eventType ?? 'message', data: dataBuffer));
        dataBuffer = '';
        eventType = null;
      }
    }
  }

  void close() {
    _isConnected = false;
    _subscription?.cancel();
    _httpClient?.close();
    _controller?.close();
  }
}

class SseEvent {
  final String type;
  final String data;
  const SseEvent({required this.type, required this.data});

  Map<String, dynamic> get json => jsonDecode(data) as Map<String, dynamic>;
}
