import '../../../../core/error/result.dart' as result_type;
import '../../infrastructure/dtos/submission_response_dto.dart';
import '../../infrastructure/dtos/learning_request_dtos.dart';

abstract class MissionRepository {
  Future<result_type.Result<SubmissionStatusResponseDto>> submitMission(MissionSubmissionRequestDto request);
  Future<result_type.Result<SubmissionStatusResponseDto>> getSubmissionStatus(String submissionId);
}
