import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/models/game_modes_models.dart';
import '../data/repositories/game_modes_repository.dart';

class GameModesController extends ChangeNotifier {
  final GameModesRepository _repo = GameModesRepository();

  List<ModeCard> _modes = [];
  GameRoom? _room;
  GameState? _gameState;
  String _lobbyCode = '';
  String _selectedMode = '';
  int _myUserId = 0;
  bool _isLoading = false;
  String? _errorMsg;
  Timer? _pollTimer;
  Timer? _gamePollTimer;

  List<ModeCard> get modes => _modes;
  GameRoom? get room => _room;
  GameState? get gameState => _gameState;
  String get lobbyCode => _lobbyCode;
  String get selectedMode => _selectedMode;
  bool get isLoading => _isLoading;
  String? get errorMsg => _errorMsg;

  void init(int userId) {
    _myUserId = userId;
    _fetchModes();
  }

  Future<void> _fetchModes() async {
    _isLoading = true;
    notifyListeners();
    try {
      _modes = await _repo.getModes();
      _errorMsg = null;
    } catch (e) {
      _errorMsg = 'Gagal memuat mode: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createLobby() async {
    _isLoading = true;
    notifyListeners();
    try {
      final room = await _repo.createLobby(_myUserId);
      _room = room;
      _lobbyCode = room.code;
      _startLobbyPolling();
      _errorMsg = null;
    } catch (e) {
      _errorMsg = 'Gagal membuat lobby: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> joinLobby(String code) async {
    _isLoading = true;
    notifyListeners();
    try {
      final room = await _repo.joinLobby(code, _myUserId);
      _room = room;
      _lobbyCode = code;
      _startLobbyPolling();
      _errorMsg = null;
    } catch (e) {
      _errorMsg = 'Lobby tidak ditemukan atau sudah penuh';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectMode(String mode) async {
    try {
      await _repo.selectMode(_lobbyCode, mode);
      _selectedMode = mode;
      notifyListeners();
    } catch (e) {
      _errorMsg = 'Gagal memilih mode: $e';
      notifyListeners();
    }
  }

  Future<GameRoom?> startGame() async {
    _isLoading = true;
    notifyListeners();
    try {
      _room = await _repo.startGame(_lobbyCode);
      _stopLobbyPolling();
      _startGamePolling();
      _errorMsg = null;
    } catch (e) {
      _errorMsg = 'Gagal memulai game: $e';
    }
    _isLoading = false;
    notifyListeners();
    return _room;
  }

  Future<void> submitAction(String input) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repo.submitAction(_lobbyCode, input);
      _errorMsg = null;
      await _fetchGameState();
    } catch (e) {
      _errorMsg = 'Gagal mengirim aksi: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchGameState() async {
    try {
      _gameState = await _repo.getGameState(_lobbyCode);
      if (_gameState?.room.status == 'finished') {
        _stopGamePolling();
      }
      _errorMsg = null;
    } catch (e) {
      _errorMsg = 'Gagal memuat state: $e';
    }
    notifyListeners();
  }

  void _startLobbyPolling() {
    _stopLobbyPolling();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      try {
        final state = await _repo.getLobbyState(_lobbyCode);
        _room = state.room;
        if (_room?.status == 'playing') {
          _stopLobbyPolling();
          _startGamePolling();
        }
        notifyListeners();
      } catch (_) {}
    });
  }

  void _startGamePolling() {
    if (_lobbyCode.isEmpty) return;
    _stopGamePolling();
    _gamePollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      try {
        _gameState = await _repo.getGameState(_lobbyCode);
        if (_gameState?.room.status == 'finished') {
          _stopGamePolling();
        }
        notifyListeners();
      } catch (_) {}
    });
  }

  void _stopLobbyPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void _stopGamePolling() {
    _gamePollTimer?.cancel();
    _gamePollTimer = null;
  }

  void leaveRoom() {
    _stopLobbyPolling();
    _stopGamePolling();
    _room = null;
    _gameState = null;
    _lobbyCode = '';
    _selectedMode = '';
    _errorMsg = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopLobbyPolling();
    _stopGamePolling();
    super.dispose();
  }
}
