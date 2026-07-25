import 'package:dio/dio.dart';
import '../dtos/learning_request_dtos.dart';
import '../dtos/submission_response_dto.dart';

/// Mission API client for submitting missions and checking status.
abstract class MissionApiClient {
  Future<SubmissionStatusResponseDto> submitMission(MissionSubmissionRequestDto request);
  Future<SubmissionStatusResponseDto> getSubmissionStatus(String submissionId);
}

class DioMissionApiClient implements MissionApiClient {
  final Dio dio;

  DioMissionApiClient(this.dio);

  @override
  Future<SubmissionStatusResponseDto> submitMission(MissionSubmissionRequestDto request) async {
    final response = await dio.post('/submissions', data: request.toJson());
    return SubmissionStatusResponseDto.fromJson(response.data);
  }

  @override
  Future<SubmissionStatusResponseDto> getSubmissionStatus(String submissionId) async {
    final response = await dio.get('/submissions/$submissionId');
    return SubmissionStatusResponseDto.fromJson(response.data);
  }
}
