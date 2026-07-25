import 'package:dio/dio.dart';

/// Telemetry API client for sending learning event batches to backend.
abstract class TelemetryApiClient {
  Future<void> sendBatch(List<Map<String, dynamic>> batch);
  Future<void> sendEpisode(Map<String, dynamic> episodePayload);
}

class DioTelemetryApiClient implements TelemetryApiClient {
  final Dio dio;

  DioTelemetryApiClient(this.dio);

  @override
  Future<void> sendBatch(List<Map<String, dynamic>> batch) async {
    await dio.post('/telemetry/batch', data: {'events': batch});
  }

  @override
  Future<void> sendEpisode(Map<String, dynamic> episodePayload) async {
    await dio.post('/telemetry/batch', data: episodePayload);
  }
}
