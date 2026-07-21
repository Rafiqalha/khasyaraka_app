import 'package:flutter/foundation.dart';
import '../../../core/domain/models/mission_model.dart';
import '../../../core/domain/repositories/mission_repository.dart';

enum MissionEngineState { generating, ready, empty, error }

class MissionStateController extends ChangeNotifier {
  final MissionRepository _missionRepository;

  MissionEngineState _state = MissionEngineState.generating;
  MissionModel? _currentMission;
  String? _errorMessage;

  MissionStateController(this._missionRepository) {
    _initMission();
  }

  MissionEngineState get state => _state;
  MissionModel? get currentMission => _currentMission;
  String? get errorMessage => _errorMessage;

  Future<void> _initMission() async {
    _setGenerating();
    try {
      final mission = await _missionRepository.getTodayMission();
      if (mission != null) {
        _currentMission = mission;
        _state = MissionEngineState.ready;
      } else {
        _state = MissionEngineState.empty;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = "AI Core failed to generate mission: \$e";
      _state = MissionEngineState.error;
      notifyListeners();
    }
  }

  void _setGenerating() {
    _state = MissionEngineState.generating;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> refreshMission() async {
    await _initMission();
  }
}
