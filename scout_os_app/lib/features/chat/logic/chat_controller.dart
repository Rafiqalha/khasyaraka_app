import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scout_os_app/features/chat/data/models/chat_models.dart';
import 'package:scout_os_app/features/chat/data/repositories/chat_repository.dart';

class ChatController extends ChangeNotifier {
  final ChatRepository _repository = ChatRepository();
  
  List<ChatMessage> messages = [];
  Timer? _pollingTimer;
  bool isLoading = false;
  String? errorMsg;

  void startPolling() {
    stopPolling();
    fetchMessages();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchMessages();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> fetchMessages() async {
    try {
      final newMessages = await _repository.getMessages();
      // Only notify if there's a difference to avoid UI flicker
      if (messages.isEmpty || newMessages.isNotEmpty && newMessages.first.id != messages.first.id) {
        messages = newMessages;
        notifyListeners();
      }
    } catch (e) {
      // Ignore polling errors
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await _repository.sendMessage(text);
      await fetchMessages();
    } catch (e) {
      errorMsg = e.toString();
      notifyListeners();
    }
  }

  Future<void> sendRoomInvite(String roomCode) async {
    try {
      await _repository.sendRoomInvite(roomCode);
      await fetchMessages();
    } catch (e) {
      errorMsg = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
