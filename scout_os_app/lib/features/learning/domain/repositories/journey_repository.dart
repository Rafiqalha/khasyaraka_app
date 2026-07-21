import '../../../../core/error/result.dart';
import '../entities/learning_entities.dart';

abstract class JourneyRepository {
  /// Loads the entire journey structure for the given user/course.
  Future<Result<Journey>> loadJourney(String journeyId);

  /// Completes a node, sending evidence to the backend and returning updated competency deltas.
  Future<Result<List<CompetencyDelta>>> completeNode(String nodeId, Evidence evidence);

  /// Loads the final passport containing all accumulated deltas and the next recommendation.
  Future<Result<Passport>> loadPassport(String studentId);
}
