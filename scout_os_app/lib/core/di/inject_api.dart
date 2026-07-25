import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:scout_os_app/core/config/environment.dart';
import '../../features/learning/infrastructure/sources/journey_api_client.dart';
import '../../features/learning/infrastructure/sources/mission_api_client.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: Environment.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  return dio;
});

final journeyApiClientProvider = Provider<JourneyApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return DioJourneyApiClient(dio); // Switch to real API Client
});

final missionApiClientProvider = Provider<MissionApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return DioMissionApiClient(dio); // Switch back to real API for YC Metrics
});


