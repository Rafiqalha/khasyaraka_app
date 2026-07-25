import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart' as result_type;
import '../repositories/mission_repository.dart';
import '../../infrastructure/dtos/submission_response_dto.dart';

class CheckSubmissionStatusUseCase {
  final MissionRepository _repository;

  CheckSubmissionStatusUseCase(this._repository);
  
  Future<(SubmissionStatusResponseDto?, Failure?)> call(String submissionId) async {
    try {
      final result = await _repository.getSubmissionStatus(submissionId);
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
