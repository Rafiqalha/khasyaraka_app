import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scout_os_app/features/arena/data/models/arena_models.dart';
import 'package:scout_os_app/features/arena/data/repositories/arena_repository.dart';

class ArenaController extends ChangeNotifier {
  final ArenaRepository _repository = ArenaRepository();
  
  ArenaRoom? currentRoom;
  RoomState? currentState;
  
  Timer? _pollingTimer;
  bool isLoading = false;
  String? errorMsg;
  
  bool get isInRoom => currentRoom != null;
  bool get isPlaying => currentRoom?.status == 'playing';

  Future<void> createRoom() async {
    isLoading = true;
    errorMsg = null;
    notifyListeners();
    
    try {
      currentRoom = await _repository.createRoom();
      startPollingLobby();
    } catch (e) {
      errorMsg = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> joinRoom(String code) async {
    isLoading = true;
    errorMsg = null;
    notifyListeners();
    
    try {
      currentRoom = await _repository.getRoomStatus(code);
      startPollingLobby();
    } catch (e) {
      errorMsg = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> createTeam(String name) async {
    if (currentRoom == null) return;
    try {
      await _repository.createTeam(currentRoom!.code, name);
      await fetchRoomStatus();
    } catch (e) {
      errorMsg = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> joinTeamSlot(int slot) async {
    if (currentRoom == null) return;
    try {
      await _repository.joinTeam(currentRoom!.code, slot);
      await fetchRoomStatus();
    } catch (e) {
      errorMsg = e.toString();
      notifyListeners();
    }
  }

  Future<void> startRoom() async {
    if (currentRoom == null) return;
    try {
      await _repository.startRoom(currentRoom!.code);
      // Let the polling timer pick up the status change
    } catch (e) {
      errorMsg = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchRoomStatus() async {
    if (currentRoom == null) return;
    try {
      currentRoom = await _repository.getRoomStatus(currentRoom!.code);
      if (currentRoom!.status == 'playing') {
        stopPolling();
        startPollingGameplay();
      }
      notifyListeners();
    } catch (e) {
      // Ignore network errors on polling to prevent UI flicker
    }
  }

  Future<void> fetchRoomState() async {
    if (currentRoom == null) return;
    try {
      currentState = await _repository.getRoomState(currentRoom!.code);
      if (currentState!.status == 'finished') {
        stopPolling();
      }
      notifyListeners();
    } catch (e) {
      // Ignore network errors on polling
    }
  }

  Future<void> submitAnswer(String answer) async {
    if (currentRoom == null) return;
    try {
      await _repository.submitAnswer(currentRoom!.code, answer);
      await fetchRoomState(); // Force update state to show "alreadyAnswered"
    } catch (e) {
      errorMsg = e.toString();
      notifyListeners();
    }
  }

  void startPollingLobby() {
    stopPolling();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      fetchRoomStatus();
    });
    fetchRoomStatus(); // immediate fetch
  }

  void startPollingGameplay() {
    stopPolling();
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      fetchRoomState();
    });
    fetchRoomState(); // immediate fetch
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }
  
  void leaveRoom() {
    stopPolling();
    currentRoom = null;
    currentState = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
