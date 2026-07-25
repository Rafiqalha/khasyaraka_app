import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart' as result_type;
import '../repositories/mission_repository.dart';
import '../../infrastructure/dtos/submission_response_dto.dart';
import '../../infrastructure/dtos/learning_request_dtos.dart';

class CompleteMissionUseCase {
  final MissionRepository _repository;

  CompleteMissionUseCase(this._repository);
  
  Future<(SubmissionStatusResponseDto?, Failure?)> call(MissionSubmissionRequestDto request) async {
    try {
      final result = await _repository.submitMission(request);
      if (result is result_type.Success<SubmissionStatusResponseDto>) {
        return (result.value, null);
      } else if (result is result_type.Failure<SubmissionStatusResponseDto>) {
        return (null, result.error as Failure);
      }
      return (null, const FatalFailure("Unknown result type"));
    } catch (e) {
      return (null, FatalFailure(e.toString()));
    }
  }
}
