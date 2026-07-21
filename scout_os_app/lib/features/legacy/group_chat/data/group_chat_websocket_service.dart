import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';
import 'package:scout_os_app/core/config/environment.dart';
import 'package:scout_os_app/features/group_chat/data/group_chat_models.dart';

class GroupChatWebSocketService {
  WebSocketChannel? _channel;
  final StreamController<GroupChatMessage> _messageController = StreamController<GroupChatMessage>.broadcast();
  
  Stream<GroupChatMessage> get messageStream => _messageController.stream;

  Future<void> connect() async {
    if (_channel != null) return;
    
    final token = await ApiDioProvider.getToken();
    if (token == null) return;
    
    // Determine websocket URL from API base URL
    final wsBaseUrl = Environment.apiBaseUrl.replaceFirst('http', 'ws');
    final wsUrl = Uri.parse('$wsBaseUrl/chat/ws?token=$token');
    
    try {
      _channel = WebSocketChannel.connect(wsUrl);
      _channel!.stream.listen(
        (data) {
          final jsonMap = jsonDecode(data);
          // Backend sends raw ChatMessage object (has 'id', 'room_id', 'user_id', etc)
          if (jsonMap.containsKey('id') && jsonMap.containsKey('room_id')) {
            final msg = GroupChatMessage.fromJson(jsonMap);
            _messageController.add(msg);
          }
        },
        onError: (e) {
          debugPrint('GroupChat WebSocket error: $e');
        },
        onDone: () {
          debugPrint('GroupChat WebSocket closed');
          _channel = null;
        }
      );
    } catch (e) {
      debugPrint('Failed to connect to GroupChat WebSocket: $e');
    }
  }

  void sendMessage(int roomId, String content) {
    if (_channel != null) {
      final msg = {
        'type': 'send_message',
        'room_id': roomId,
        'content': content,
      };
      _channel!.sink.add(jsonEncode(msg));
    }
  }

  void subscribeRoom(int roomId) {
    if (_channel != null) {
      final msg = {
        'type': 'subscribe',
        'room_id': roomId,
      };
      _channel!.sink.add(jsonEncode(msg));
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}
