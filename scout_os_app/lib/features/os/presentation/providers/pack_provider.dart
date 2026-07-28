import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';
import 'package:scout_os_app/core/config/environment.dart';

class PackDescriptor {
  final String id;
  final String title;
  final String description;
  final String version;

  PackDescriptor({
    required this.id,
    required this.title,
    required this.description,
    required this.version,
  });

  factory PackDescriptor.fromJson(Map<String, dynamic> json) {
    return PackDescriptor(
      id: json['id'] ?? '',
      title: json['title'] ?? json['id'] ?? '',
      description: json['description'] ?? '',
      version: json['version'] ?? '1.0.0',
    );
  }
}

class MissionItem {
  final String id;
  final String title;
  final String description;
  final int order;
  final String language;

  MissionItem({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.language,
  });

  factory MissionItem.fromJson(Map<String, dynamic> json) {
    return MissionItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      order: json['order'] ?? 1,
      language: json['language'] ?? 'bash',
    );
  }
}

class PackDetail {
  final String id;
  final String title;
  final String description;
  final String persona;
  final List<MissionItem> missions;
  final List<String> rules;

  PackDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.persona,
    required this.missions,
    required this.rules,
  });

  factory PackDetail.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final aiRules = data['ai_rules'] as Map<String, dynamic>? ?? {};
    final rawMissions = data['missions'] as List<dynamic>? ?? [];

    return PackDetail(
      id: data['descriptor']?['id'] ?? 'cyber_fundamentals',
      title: data['title'] ?? 'Pack',
      description: data['description'] ?? '',
      persona: aiRules['persona'] ?? 'AI Instructor',
      rules: (aiRules['rules'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      missions: rawMissions.map((m) => MissionItem.fromJson(m as Map<String, dynamic>)).toList(),
    );
  }
}

final packListProvider = FutureProvider<List<PackDescriptor>>((ref) async {
  final dio = ApiDioProvider.getDio();
  final host = Environment.apiBaseUrl.replaceAll(RegExp(r'/api/v\d+$'), '');
  final response = await dio.get('$host/api/v2/packs');

  if (response.statusCode == 200 && response.data['data'] != null) {
    final list = response.data['data'] as List<dynamic>;
    return list.map((item) => PackDescriptor.fromJson(item as Map<String, dynamic>)).toList();
  }
  return [];
});

final packDetailProvider = FutureProvider.family<PackDetail, String>((ref, packId) async {
  final dio = ApiDioProvider.getDio();
  final host = Environment.apiBaseUrl.replaceAll(RegExp(r'/api/v\d+$'), '');
  final response = await dio.get('$host/api/v2/packs/$packId');

  if (response.statusCode == 200) {
    return PackDetail.fromJson(response.data as Map<String, dynamic>);
  } else {
    throw Exception('Failed to load pack detail for $packId');
  }
});
