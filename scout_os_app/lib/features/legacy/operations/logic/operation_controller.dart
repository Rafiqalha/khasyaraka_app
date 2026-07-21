import 'package:flutter/foundation.dart';
import '../../../core/domain/models/operation_model.dart';
import '../../../core/domain/repositories/operation_repository.dart';

class OperationController extends ChangeNotifier {
  final OperationRepository _operationRepository;
  
  OperationState _currentState = OperationState.generating;
  OperationModel? _activeOperation;
  String? _errorMessage;

  OperationController(this._operationRepository);

  OperationState get currentState => _currentState;
  OperationModel? get activeOperation => _activeOperation;
  String? get errorMessage => _errorMessage;

  Future<void> startOperation(String missionId) async {
    _currentState = OperationState.generating;
    notifyListeners();

    try {
      _activeOperation = await _operationRepository.startOperation(missionId);
      _currentState = OperationState.running;
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to initialize operation workspace: \$e";
      _currentState = OperationState.failed;
      notifyListeners();
    }
  }

  Future<void> submitForEvaluation(Map<String, dynamic> artifacts) async {
    if (_activeOperation == null) return;
    
    _currentState = OperationState.evaluating;
    notifyListeners();

    try {
      final assessment = await _operationRepository.submitOperation(_activeOperation!.id, artifacts);
      _currentState = OperationState.completed;
      // Note: In a full implementation, we would broadcast the assessment to CapabilityController
      notifyListeners();
    } catch (e) {
      _errorMessage = "AI Evaluation failed: \$e";
      _currentState = OperationState.failed;
      notifyListeners();
    }
  }
}
