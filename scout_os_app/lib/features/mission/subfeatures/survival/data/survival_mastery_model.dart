class SurvivalMasteryModel {
  final String toolType;
  final int currentXp;
  final int currentLevel;
  final int totalActions;
  final int highestStreak;
  final double maxAltitude;
  final double totalDistanceTracked;
  final int xpToNextLevel;
  final String rankTitle;

  SurvivalMasteryModel({
    required this.toolType,
    required this.currentXp,
    required this.currentLevel,
    required this.totalActions,
    required this.highestStreak,
    required this.maxAltitude,
    required this.totalDistanceTracked,
    required this.xpToNextLevel,
    required this.rankTitle,
  });

  factory SurvivalMasteryModel.fromJson(Map<String, dynamic> json) {
    return SurvivalMasteryModel(
      toolType: json['tool_type'] as String,
      currentXp: json['current_xp'] as int,
      currentLevel: json['current_level'] as int,
      totalActions: json['total_actions'] as int,
      highestStreak: json['highest_streak'] as int,
      maxAltitude: (json['max_altitude'] as num).toDouble(),
      totalDistanceTracked: (json['total_distance_tracked'] as num).toDouble(),
      xpToNextLevel: json['xp_to_next_level'] as int,
      rankTitle: json['rank_title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tool_type': toolType,
      'current_xp': currentXp,
      'current_level': currentLevel,
      'total_actions': totalActions,
      'highest_streak': highestStreak,
      'max_altitude': maxAltitude,
      'total_distance_tracked': totalDistanceTracked,
      'xp_to_next_level': xpToNextLevel,
      'rank_title': rankTitle,
    };
  }

  /// Calculate progress percentage to next level (0.0 to 1.0)
  double get progressToNextLevel {
    if (xpToNextLevel <= 0) return 1.0;
    // Calculate XP required for current level
    final xpForCurrentLevel = ((currentLevel - 1) * (currentLevel - 1)) * 100;
    final xpForNextLevel = (currentLevel * currentLevel) * 100;
    final xpRange = xpForNextLevel - xpForCurrentLevel;
    final xpProgress = currentXp - xpForCurrentLevel;
    return (xpProgress / xpRange).clamp(0.0, 1.0);
  }
}

class AllMasteryResponse {
  final List<SurvivalMasteryModel> tools;

  AllMasteryResponse({required this.tools});

  factory AllMasteryResponse.fromJson(Map<String, dynamic> json) {
    return AllMasteryResponse(
      tools: (json['tools'] as List)
          .map((tool) => SurvivalMasteryModel.fromJson(tool))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tools': tools.map((tool) => tool.toJson()).toList(),
    };
  }

  /// Get mastery for a specific tool type
  SurvivalMasteryModel? getMasteryForTool(String toolType) {
    try {
      return tools.firstWhere((tool) => tool.toolType == toolType);
    } catch (e) {
      return null;
    }
  }
}

class RecordActionResponse {
  final bool success;
  final String toolType;
  final int newXp;
  final int newLevel;
  final bool isLevelUp;
  final int xpGained;
  final String rankTitle;

  RecordActionResponse({
    required this.success,
    required this.toolType,
    required this.newXp,
    required this.newLevel,
    required this.isLevelUp,
    required this.xpGained,
    required this.rankTitle,
  });

  factory RecordActionResponse.fromJson(Map<String, dynamic> json) {
    return RecordActionResponse(
      success: json['success'] as bool,
      toolType: json['tool_type'] as String,
      newXp: json['new_xp'] as int,
      newLevel: json['new_level'] as int,
      isLevelUp: json['is_level_up'] as bool,
      xpGained: json['xp_gained'] as int,
      rankTitle: json['rank_title'] as String,
    );
  }
}
