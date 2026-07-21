import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';

class ChatMessage {
  final int id;
  final int roomId;
  final int senderId;
  final String senderName;
  final String? senderAvatar;
  final String senderType; // user / bot / system
  final String content;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.senderType,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      roomId: json['room_id'],
      senderId: json['sender_id'] ?? 0,
      senderName: json['sender_name'] ?? 'System',
      senderAvatar: json['sender_avatar'],
      senderType: json['sender_type'] ?? 'user',
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['created_at']).toLocal(),
    );
  }
}

class ChatRoom {
  final int id;
  final String type;
  final String name;

  ChatRoom({required this.id, required this.type, required this.name});

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      type: json['type'],
      name: json['name'],
    );
  }
}

class ChatWebSocketService {
  WebSocketChannel? _channel;
  final StreamController<ChatMessage> _messageController = StreamController<ChatMessage>.broadcast();
  
  Stream<ChatMessage> get messageStream => _messageController.stream;

  Future<void> connect() async {
    if (_channel != null) return;
    
    final token = await ApiDioProvider.getToken();
    if (token == null) return;
    
    final wsUrl = Uri.parse('ws://127.0.0.1:8000/api/v1/chat/ws?token=$token'); // Adjust depending on env
    
    try {
      _channel = WebSocketChannel.connect(wsUrl);
      _channel!.stream.listen(
        (data) {
          final jsonMap = jsonDecode(data);
          if (jsonMap['type'] == 'message') {
            final msg = ChatMessage.fromJson(jsonMap['data']);
            _messageController.add(msg);
          }
        },
        onError: (e) {
          debugPrint('WebSocket error: $e');
        },
        onDone: () {
          debugPrint('WebSocket closed');
          _channel = null;
        }
      );
    } catch (e) {
      debugPrint('Failed to connect to WebSocket: $e');
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
