
import '../../../../core/error/result.dart';
import '../../../../core/error/failures.dart' as app_failures;
import '../entities/learning_entities.dart';
import '../repositories/journey_repository.dart';
import '../../infrastructure/dtos/learning_request_dtos.dart';



class LoadJourneyUseCase {
  final JourneyRepository _repository;

  LoadJourneyUseCase(this._repository);

  Future<(Journey?, app_failures.Failure?)> getCachedJourney(String journeyId) async {
    try {
      final result = await _repository.getCachedJourney(journeyId);
      if (result is Success<Journey?>) {
        return (result.value, null);
      } else if (result is Failure<Journey?>) {
        return (null, app_failures.FatalFailure(result.error.toString()));
      }
      return (null, app_failures.FatalFailure("Unknown result type"));
    } catch (e) {
      return (null, app_failures.FatalFailure(e.toString()));
    }
  }

  Future<(Journey?, app_failures.Failure?)> refreshJourney(JourneyRequest request) async {
    try {
      final result = await _repository.refreshJourney(request);
      if (result is Success<Journey>) {
        return (result.value, null);
      } else if (result is Failure<Journey>) {
        return (null, app_failures.FatalFailure(result.error.toString()));
      }
      return (null, app_failures.FatalFailure("Unknown result type"));
    } catch (e) {
      return (null, app_failures.FatalFailure(e.toString()));
    }
  }

}
