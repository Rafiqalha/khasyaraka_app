import 'package:dio/dio.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';
import 'package:scout_os_app/core/data/base_repository.dart';
import 'package:scout_os_app/features/chat/data/models/chat_models.dart';

class ChatRepository extends BaseRepository {
  final Dio _dio;

  ChatRepository({Dio? dio}) : _dio = dio ?? ApiDioProvider.getDio();

  Future<List<ChatMessage>> getMessages() async {
    final response = await _dio.get('/chat/messages');
    return (response.data['data'] as List<dynamic>)
        .map((m) => ChatMessage.fromJson(m))
        .toList();
  }

  Future<void> sendMessage(String message) async {
    await _dio.post('/chat/messages', data: {
      'message': message,
    });
  }

  Future<void> sendRoomInvite(String roomCode) async {
    await _dio.post('/chat/messages/invite', data: {
      'room_code': roomCode,
    });
  }
}
