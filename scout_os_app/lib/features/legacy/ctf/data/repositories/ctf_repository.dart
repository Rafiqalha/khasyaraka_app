import 'package:dio/dio.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';
import 'package:scout_os_app/features/ctf/data/models/ctf_models.dart';
import 'package:scout_os_app/features/ai/data/models/chat_response.dart';

class CTFRepository {
  CTFRepository({Dio? dio}) : _dio = dio ?? ApiDioProvider.getDio();

  final Dio _dio;

  Future<CTFRoom> initializeRoom(int roomId) async {
    final response = await _dio.post('/ctf/rooms/$roomId/init');
    return CTFRoom.fromJson(response.data);
  }

  Future<void> startDefensePhase(int roomId) async {
    await _dio.post('/ctf/rooms/$roomId/start-defense');
  }

  Future<void> submitDefense(
    int roomId, 
    int teamId, 
    String method, 
    String key, 
    String imageId,
  ) async {
    await _dio.post(
      '/ctf/rooms/$roomId/defense',
      options: Options(headers: {'X-Team-ID': teamId.toString()}),
      data: {
        'cipher_method': method,
        'cipher_key': key,
        'cultural_image_id': imageId,
      },
    );
  }

  Future<void> startAttackPhase(int roomId) async {
    await _dio.post('/ctf/rooms/$roomId/start-attack');
  }

  Future<ChatResponse> attackWithAI(int roomId, int teamId, String prompt) async {
    final response = await _dio.post(
      '/ctf/rooms/$roomId/attack/ai',
      options: Options(headers: {'X-Team-ID': teamId.toString()}),
      data: {'prompt': prompt},
    );
    return ChatResponse.fromJson(response.data);
  }

  Future<Map<String, dynamic>> submitFlag(int roomId, int teamId, String flag) async {
    final response = await _dio.post(
      '/ctf/rooms/$roomId/attack/flag',
      options: Options(headers: {'X-Team-ID': teamId.toString()}),
      data: {'flag': flag},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> submitPatch(int roomId, int teamId, String answer, int timeTaken) async {
    final response = await _dio.post(
      '/ctf/rooms/$roomId/patch',
      options: Options(headers: {'X-Team-ID': teamId.toString()}),
      data: {
        'answer': answer,
        'time_taken_sec': timeTaken,
      },
    );
    return response.data;
  }

  Future<CTFStateResponse> getState(int roomId, int teamId) async {
    final response = await _dio.get(
      '/ctf/rooms/$roomId/state',
      options: Options(headers: {'X-Team-ID': teamId.toString()}),
    );
    return CTFStateResponse.fromJson(response.data);
  }

  Future<List<CTFTeam>> getFinalScores(int roomId) async {
    final response = await _dio.get('/ctf/rooms/$roomId/finish');
    final list = response.data as List;
    return list.map((e) => CTFTeam.fromJson(e)).toList();
  }
}
