class ChatMessage {
  final int id;
  final int userId;
  final String fullName;
  final String message;
  final String? roomCode;
  final String msgType;
  final String createdAt;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.message,
    this.roomCode,
    required this.msgType,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      fullName: json['full_name'] ?? 'User',
      message: json['message'] ?? '',
      roomCode: json['room_code'],
      msgType: json['msg_type'] ?? 'text',
      createdAt: json['created_at'] ?? '',
    );
  }
}
