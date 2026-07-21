import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';
import 'package:scout_os_app/features/group_chat/data/group_chat_websocket_service.dart';
import 'package:scout_os_app/features/group_chat/data/group_chat_models.dart';

class GroupChatController extends ChangeNotifier {
  final Dio _dio = ApiDioProvider.getDio();
  final GroupChatWebSocketService _wsService = GroupChatWebSocketService();
  
  List<GroupChatRoom> _rooms = [];
  List<GroupChatRoom> get rooms => _rooms;

  bool _isLoadingRooms = false;
  bool get isLoadingRooms => _isLoadingRooms;

  // room_id -> messages
  final Map<int, List<GroupChatMessage>> _messages = {};
  
  StreamSubscription? _msgSub;

  GroupChatController() {
    _msgSub = _wsService.messageStream.listen((msg) {
      if (!_messages.containsKey(msg.roomId)) {
        _messages[msg.roomId] = [];
      }
      _messages[msg.roomId]!.insert(0, msg);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    _wsService.disconnect();
    super.dispose();
  }

  Future<void> initChat() async {
    await _wsService.connect();
    await fetchRooms();
    // Subscribe to all rooms
    for (final r in _rooms) {
      _wsService.subscribeRoom(r.id);
    }
  }

  Future<void> fetchRooms() async {
    _isLoadingRooms = true;
    notifyListeners();

    try {
      final res = await _dio.get('/chat/rooms');
      final data = res.data['data'] as Map<String, dynamic>;
      
      final parsedRooms = <GroupChatRoom>[];
      if (data['kecamatan'] != null) parsedRooms.add(GroupChatRoom.fromJson(data['kecamatan']));
      if (data['kabupaten'] != null) parsedRooms.add(GroupChatRoom.fromJson(data['kabupaten']));
      if (data['provinsi'] != null) parsedRooms.add(GroupChatRoom.fromJson(data['provinsi']));
      if (data['negara'] != null) parsedRooms.add(GroupChatRoom.fromJson(data['negara']));
      if (data['global'] != null) parsedRooms.add(GroupChatRoom.fromJson(data['global']));
      if (data['nasional'] != null) parsedRooms.add(GroupChatRoom.fromJson(data['nasional']));

      _rooms = parsedRooms;

    } catch (e, stack) {
      debugPrint('Failed to fetch rooms: $e');
      debugPrint(stack.toString());
    } finally {
      _isLoadingRooms = false;
      notifyListeners();
    }
  }

  List<GroupChatMessage> getMessages(int roomId) {
    return _messages[roomId] ?? [];
  }

  Future<void> fetchMessages(int roomId, {int? beforeId}) async {
    try {
      final query = beforeId != null ? '?before_id=$beforeId&limit=50' : '?limit=50';
      final res = await _dio.get('/chat/rooms/$roomId/messages$query');
      final dataMap = res.data['data'] as Map<String, dynamic>;
      final msgsList = dataMap['messages'] as List? ?? [];
      final newMsgs = msgsList.map((e) => GroupChatMessage.fromJson(e)).toList();
      
      if (!_messages.containsKey(roomId)) {
        _messages[roomId] = [];
      }
      
      if (beforeId == null) {
        _messages[roomId] = newMsgs;
      } else {
        _messages[roomId]!.addAll(newMsgs);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch messages: $e');
    }
  }

  Future<void> sendMessage(int roomId, String content) async {
    if (content.trim().isEmpty) return;
    
    // Optimistic UI update could be added here, but backend broadcasts it via WS anyway
    try {
      await _dio.post('/chat/rooms/$roomId/messages', data: {
        'content': content,
      });
    } catch (e) {
      debugPrint('Failed to send message: $e');
    }
  }

  Map<String, List<GroupChatRoom>> get roomsByLevel {
    final map = <String, List<GroupChatRoom>>{};
    for (final room in _rooms) {
      map.putIfAbsent(room.tabLabel, () => []).add(room);
    }
    return map;
  }

  List<String> get availableTabs {
    final tabs = _rooms.map((r) => r.tabLabel).toSet().toList();
    tabs.sort((a, b) {
      final orderA = _rooms.firstWhere((r) => r.tabLabel == a).levelOrder;
      final orderB = _rooms.firstWhere((r) => r.tabLabel == b).levelOrder;
      return orderA.compareTo(orderB);
    });
    return tabs;
  }
}
