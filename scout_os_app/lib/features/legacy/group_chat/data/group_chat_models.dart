class GroupChatMessage {
  final int id;
  final int roomId;
  final int senderId;
  final String senderName;
  final String? senderAvatar;
  final String senderType; // user / bot / system
  final String content;
  final DateTime createdAt;

  GroupChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.senderType,
    required this.content,
    required this.createdAt,
  });

  factory GroupChatMessage.fromJson(Map<String, dynamic> json) {
    return GroupChatMessage(
      id: json['id'],
      roomId: json['room_id'],
      senderId: json['user_id'] ?? 0,
      senderName: json['user_name'] ?? 'System',
      senderAvatar: json['sender_avatar'],
      senderType: json['sender_type'] ?? 'user',
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['created_at']).toLocal(),
    );
  }
}

class GroupChatRoom {
  final int id;
  final String type;
  final String name;
  final String? description;

  GroupChatRoom({
    required this.id,
    required this.type,
    required this.name,
    this.description,
  });

  factory GroupChatRoom.fromJson(Map<String, dynamic> json) {
    return GroupChatRoom(
      id: json['id'],
      type: json['room_type'] ?? 'nasional',
      name: json['name'],
      description: json['description'],
    );
  }

  int get levelOrder {
    switch (type) {
      case 'kecamatan':
        return 0;
      case 'kabupaten':
        return 1;
      case 'provinsi':
        return 2;
      case 'negara':
        return 3;
      case 'nasional':
      case 'global':
        return 4;
      default:
        return 5;
    }
  }

  String get tabLabel {
    switch (type) {
      case 'kecamatan':
        return 'Kecamatan';
      case 'kabupaten':
        return 'Kota';
      case 'provinsi':
        return 'Provinsi';
      case 'negara':
        return 'Negara';
      case 'nasional':
      case 'global':
        return 'Global';
      default:
        return 'Lainnya';
    }
  }
}
