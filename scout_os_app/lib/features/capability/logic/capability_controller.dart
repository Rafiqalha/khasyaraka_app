import 'package:flutter/foundation.dart';
import '../../../core/domain/models/capability_model.dart';
import '../../../core/domain/repositories/capability_repository.dart';

enum CapabilityEngineState { syncing, ready, error }

class CapabilityController extends ChangeNotifier {
  final CapabilityRepository _capabilityRepository;
  final String _userId; // Injected from AuthController

  CapabilityEngineState _state = CapabilityEngineState.syncing;
  CapabilityModel? _currentCapability;
  String? _errorMessage;

  CapabilityController(this._capabilityRepository, this._userId) {
    _syncCapability();
  }

  CapabilityEngineState get state => _state;
  CapabilityModel? get currentCapability => _currentCapability;
  String? get errorMessage => _errorMessage;

  Future<void> _syncCapability() async {
    _state = CapabilityEngineState.syncing;
    notifyListeners();

    try {
      _currentCapability = await _capabilityRepository.getCapabilityProfile(_userId);
      _state = CapabilityEngineState.ready;
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to sync telemetry: \$e";
      _state = CapabilityEngineState.error;
      notifyListeners();
    }
  }

  Future<void> refresh() => _syncCapability();
}
