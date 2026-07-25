import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';
import 'package:scout_os_app/core/config/environment.dart';

class PackNode {
  final String id;
  final String title;
  final String description;
  final String initialCode;
  final String language;

  PackNode({
    required this.id,
    required this.title,
    required this.description,
    required this.initialCode,
    required this.language,
  });

  factory PackNode.fromJson(Map<String, dynamic> json) {
    return PackNode(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      initialCode: json['initialCode'] ?? '',
      language: json['language'] ?? 'python',
    );
  }
}

class RuntimeSession {
  final String id;
  final String status;
  final int progressPercentage;
  final String currentNodeId;

  RuntimeSession({
    required this.id,
    required this.status,
    required this.progressPercentage,
    required this.currentNodeId,
  });

  factory RuntimeSession.fromJson(Map<String, dynamic> json) {
    return RuntimeSession(
      id: json['id'] ?? '',
      status: json['status'] ?? 'NOT_STARTED',
      progressPercentage: json['progress_percentage'] ?? 0,
      currentNodeId: json['current_node_id'] ?? '',
    );
  }
}

class CurrentSessionResponse {
  final RuntimeSession? session;
  final PackNode? node;
  final int progress;

  CurrentSessionResponse({
    this.session,
    this.node,
    this.progress = 0,
  });

  factory CurrentSessionResponse.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty || json['session'] == null) {
      return CurrentSessionResponse();
    }
    return CurrentSessionResponse(
      session: RuntimeSession.fromJson(json['session']),
      node: json['node'] != null ? PackNode.fromJson(json['node']) : null,
      progress: json['progress'] ?? 0,
    );
  }
}

final currentSessionProvider = FutureProvider<CurrentSessionResponse>((ref) async {
  final dio = ApiDioProvider.getDio();
  final host = Environment.apiBaseUrl.replaceAll(RegExp(r'/api/v\d+$'), '');
  final response = await dio.get('$host/api/v2/runtime/current');
  return CurrentSessionResponse.fromJson(response.data);
});

final packNodeProvider = FutureProvider.family<PackNode, String>((ref, nodeId) async {
  final dio = ApiDioProvider.getDio();
  final host = Environment.apiBaseUrl.replaceAll(RegExp(r'/api/v\d+$'), '');
  final response = await dio.get('$host/api/v2/runtime/node/$nodeId');
  return PackNode.fromJson(response.data);
});
