import '../../../../core/error/result.dart';
import '../entities/learning_entities.dart';
import '../../infrastructure/dtos/learning_request_dtos.dart';

abstract class JourneyRepository {
  /// Loads the cached journey structure if it exists.
  Future<Result<Journey?>> getCachedJourney(String journeyId);

  /// Fetches the journey from the network and saves it to cache.
  Future<Result<Journey>> refreshJourney(JourneyRequest request);

  /// Completes a node, sending evidence to the backend and returning updated competency deltas.
  Future<Result<List<CompetencyDelta>>> completeNode(String nodeId, Evidence evidence);

  /// Loads the final passport containing all accumulated deltas and the next recommendation.
  Future<Result<Passport>> loadPassport(String studentId);
}
