import 'package:flutter/material.dart';
import 'package:scout_os_app/features/mission/subfeatures/survival/data/survival_mastery_model.dart';
import 'package:scout_os_app/features/mission/subfeatures/survival/data/survival_repository.dart';

class SurvivalMasteryController extends ChangeNotifier {
  final SurvivalRepository _repository = SurvivalRepository();
  bool _isInitialized = false;

  AllMasteryResponse? _masteryData;
  bool _isLoading = false;
  String? _errorMessage;

  AllMasteryResponse? get masteryData => _masteryData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  /// Load mastery data from API
  Future<void> loadMastery() async {
    await _ensureInitialized();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _masteryData = await _repository.fetchMastery();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Record a tool action and update mastery
  Future<RecordActionResponse?> recordAction({
    required String toolType,
    int xpGained = 10,
    Map<String, dynamic>? metadata,
  }) async {
    await _ensureInitialized();
    try {
      final response = await _repository.recordAction(
        toolType: toolType,
        xpGained: xpGained,
        metadata: metadata,
      );

      // Reload mastery data to get updated stats
      await loadMastery();

      return response;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Get mastery for a specific tool
  SurvivalMasteryModel? getMasteryForTool(String toolType) {
    return _masteryData?.getMasteryForTool(toolType);
  }

  /// Get the highest level tool
  SurvivalMasteryModel? get highestLevelTool {
    if (_masteryData == null || _masteryData!.tools.isEmpty) {
      return null;
    }
    return _masteryData!.tools.reduce((a, b) => 
      a.currentLevel > b.currentLevel ? a : b
    );
  }

  /// Get total XP across all tools
  int get totalXp {
    if (_masteryData == null) return 0;
    return _masteryData!.tools.fold(0, (sum, tool) => sum + tool.currentXp);
  }

  /// Get average level across all tools
  double get averageLevel {
    if (_masteryData == null || _masteryData!.tools.isEmpty) return 1.0;
    final totalLevel = _masteryData!.tools.fold(0, (sum, tool) => sum + tool.currentLevel);
    return totalLevel / _masteryData!.tools.length;
  }
}
