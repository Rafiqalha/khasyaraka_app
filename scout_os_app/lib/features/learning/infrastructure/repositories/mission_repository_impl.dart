import '../../../../core/error/result.dart' as result_type;
import '../../domain/repositories/mission_repository.dart';
import '../sources/mission_api_client.dart';
import '../dtos/learning_request_dtos.dart';
import '../dtos/submission_response_dto.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/failures.dart';

class MissionRepositoryImpl implements MissionRepository {
  final MissionApiClient apiClient;

  MissionRepositoryImpl(this.apiClient);

  @override
  Future<result_type.Result<SubmissionStatusResponseDto>> submitMission(MissionSubmissionRequestDto request) async {
    try {
      final responseDto = await apiClient.submitMission(request);
      return result_type.Success(responseDto);
    } on DioException catch (e) {
      return result_type.Failure(ErrorMapper.mapDioExceptionToFailure(e), StackTrace.current);
    } catch (e, stackTrace) {
      return result_type.Failure(ServerFailure(e.toString()), stackTrace);
    }
  }

  @override
  Future<result_type.Result<SubmissionStatusResponseDto>> getSubmissionStatus(String submissionId) async {
    try {
      final responseDto = await apiClient.getSubmissionStatus(submissionId);
      return result_type.Success(responseDto);
    } on DioException catch (e) {
      return result_type.Failure(ErrorMapper.mapDioExceptionToFailure(e), StackTrace.current);
    } catch (e, stackTrace) {
      return result_type.Failure(ServerFailure(e.toString()), stackTrace);
    }
  }
}
