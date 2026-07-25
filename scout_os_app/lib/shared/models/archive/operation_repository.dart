import 'operation_model.dart';
import 'assessment_model.dart';

abstract class OperationRepository {
  /// Starts a new operation session for a mission
  Future<OperationModel> startOperation(String missionId);

  /// Updates the state of an active operation (e.g., to 'evaluating')
  Future<void> updateOperationState(String operationId, OperationState state);

  /// Submits the final artifacts/answers for AI evaluation
  Future<AssessmentModel> submitOperation(String operationId, Map<String, dynamic> artifacts);

  /// Gets active or historical operations for the user
  Future<List<OperationModel>> getOperations(String userId);
}
