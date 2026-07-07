import 'dart:convert';

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
}

void main() {
  final jsonString = '''
{"data":{"kecamatan":{"id":5,"room_type":"kecamatan","wilayah_id":"3273010","name":"Pramuka SUKASARI","member_count":0},"kabupaten":{"id":6,"room_type":"kabupaten","wilayah_id":"3273","name":"Pramuka KOTA BANDUNG","member_count":0},"provinsi":{"id":7,"room_type":"provinsi","wilayah_id":"32","name":"Pramuka JAWA BARAT","member_count":0},"nasional":{"id":1,"room_type":"nasional","wilayah_id":null,"name":"Pramuka Indonesia 🇮🇩","member_count":0}}}
  ''';
  final res = jsonDecode(jsonString);
  final data = res['data'] as Map<String, dynamic>;
  final parsedRooms = <GroupChatRoom>[];
  if (data['kecamatan'] != null) parsedRooms.add(GroupChatRoom.fromJson(data['kecamatan']));
  if (data['kabupaten'] != null) parsedRooms.add(GroupChatRoom.fromJson(data['kabupaten']));
  if (data['provinsi'] != null) parsedRooms.add(GroupChatRoom.fromJson(data['provinsi']));
  if (data['nasional'] != null) parsedRooms.add(GroupChatRoom.fromJson(data['nasional']));
  print(parsedRooms.length);
}
