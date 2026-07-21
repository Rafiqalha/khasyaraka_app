import 'package:dio/dio.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';
import '../models/game_modes_models.dart';

class GameModesRepository {
  final Dio _dio;

  GameModesRepository() : _dio = ApiDioProvider.getDio();

  static const _base = '/game-modes';

  Future<List<ModeCard>> getModes() async {
    final res = await _dio.get('$_base/modes');
    return (res.data['modes'] as List)
        .map((m) => ModeCard.fromJson(m))
        .toList();
  }

  Future<GameRoom> createLobby(int userId) async {
    final res = await _dio.post('$_base/lobby/create', data: {'user_id': userId});
    return GameRoom.fromJson(res.data['room']);
  }

  Future<GameRoom> joinLobby(String code, int userId) async {
    final res = await _dio.post('$_base/lobby/join', data: {
      'code': code,
      'user_id': userId,
    });
    return GameRoom.fromJson(res.data['room']);
  }

  Future<LobbyState> getLobbyState(String code) async {
    final res = await _dio.get('$_base/lobby', queryParameters: {'code': code});
    return LobbyState.fromJson(res.data);
  }

  Future<void> selectMode(String code, String mode) async {
    await _dio.post('$_base/lobby/mode', data: {'code': code, 'mode': mode});
  }

  Future<GameRoom> startGame(String code) async {
    final res = await _dio.post('$_base/lobby/start', data: {'code': code});
    return GameRoom.fromJson(res.data['room']);
  }

  Future<Map<String, dynamic>> submitAction(String code, String input) async {
    final res = await _dio.post('$_base/action', data: {
      'code': code,
      'input': input,
    });
    return res.data;
  }

  Future<GameState> getGameState(String code) async {
    final res = await _dio.get('$_base/state', queryParameters: {'code': code});
    return GameState.fromJson(res.data);
  }
}
