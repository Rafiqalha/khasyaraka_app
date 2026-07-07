import 'package:dio/dio.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';
import 'package:scout_os_app/core/data/base_repository.dart';
import 'package:scout_os_app/features/arena/data/models/arena_models.dart';

class ArenaRepository extends BaseRepository {
  final Dio _dio;
  
  ArenaRepository({Dio? dio}) : _dio = dio ?? ApiDioProvider.getDio();

  Future<ArenaRoom> createRoom() async {
    final response = await _dio.post('/arena/rooms', data: {});
    return ArenaRoom.fromJson(response.data['data']);
  }

  Future<ArenaRoom> getRoomStatus(String code) async {
    final response = await _dio.get('/arena/rooms/$code');
    return ArenaRoom.fromJson(response.data['data']);
  }

  Future<void> createTeam(String code, String name) async {
    await _dio.post('/arena/rooms/$code/teams', data: {
      'name': name,
    });
  }

  Future<void> joinTeam(String code, int slot) async {
    await _dio.post('/arena/rooms/$code/teams/$slot/join', data: {});
  }

  Future<void> startRoom(String code) async {
    await _dio.post('/arena/rooms/$code/start', data: {});
  }

  Future<RoomState> getRoomState(String code) async {
    final response = await _dio.get('/arena/rooms/$code/state');
    return RoomState.fromJson(response.data['data']);
  }

  Future<void> submitAnswer(String code, String answer) async {
    await _dio.post('/arena/rooms/$code/answer', data: {
      'answer': answer,
    });
  }

  Future<void> matchmakeJoin() async {
    await _dio.post('/arena/matchmake/join', data: {});
  }

  Future<String?> getMatchmakeStatus() async {
    final response = await _dio.get('/arena/matchmake/status');
    return response.data['data']?['room_code'];
  }

  Future<void> matchmakeCancel() async {
    await _dio.delete('/arena/matchmake/cancel', data: {});
  }

  Future<String> createBotMatch(String difficulty) async {
    final response = await _dio.post('/arena/matchmake/bot', data: {
      'difficulty': difficulty,
    });
    return response.data['data']['room_code'];
  }
}
