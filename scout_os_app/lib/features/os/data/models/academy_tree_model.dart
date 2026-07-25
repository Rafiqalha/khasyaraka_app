import 'package:equatable/equatable.dart';

class LearningGoalModel extends Equatable {
  final String id;
  final String specializationId;
  final String title;
  final String? description;
  final String? learningObjective;
  final String? goalType;
  final String? latestPackId;
  final DateTime createdAt;

  const LearningGoalModel({
    required this.id,
    required this.specializationId,
    required this.title,
    this.description,
    this.learningObjective,
    this.goalType,
    this.latestPackId,
    required this.createdAt,
  });

  factory LearningGoalModel.fromJson(Map<String, dynamic> json) {
    return LearningGoalModel(
      id: json['id'],
      specializationId: json['specialization_id'],
      title: json['title'],
      description: json['description'],
      learningObjective: json['learning_objective'],
      goalType: json['goal_type'],
      latestPackId: json['latest_pack_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        specializationId,
        title,
        description,
        learningObjective,
        goalType,
        latestPackId,
        createdAt,
      ];
}

class SpecializationModel {
  final String id;
  final String domainId;
  final String title;
  final String description;
  final List<LearningGoalModel> learningGoals;

  SpecializationModel({
    required this.id,
    required this.domainId,
    required this.title,
    required this.description,
    required this.learningGoals,
  });

  factory SpecializationModel.fromJson(Map<String, dynamic> json) {
    var goalsList = json['learning_goals'] as List? ?? [];
    return SpecializationModel(
      id: json['id'] ?? '',
      domainId: json['domain_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      learningGoals: goalsList.map((g) => LearningGoalModel.fromJson(g)).toList(),
    );
  }
}

class DomainModel {
  final String id;
  final String academyId;
  final String title;
  final String description;
  final List<SpecializationModel> specializations;

  DomainModel({
    required this.id,
    required this.academyId,
    required this.title,
    required this.description,
    required this.specializations,
  });

  factory DomainModel.fromJson(Map<String, dynamic> json) {
    var specList = json['specializations'] as List? ?? [];
    return DomainModel(
      id: json['id'] ?? '',
      academyId: json['academy_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      specializations: specList.map((s) => SpecializationModel.fromJson(s)).toList(),
    );
  }
}

class AcademyTreeModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String colorTheme;
  final List<DomainModel> domains;

  AcademyTreeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.colorTheme,
    required this.domains,
  });

  factory AcademyTreeModel.fromJson(Map<String, dynamic> json) {
    var domainsList = json['domains'] as List? ?? [];
    return AcademyTreeModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      colorTheme: json['color_theme'] ?? '',
      domains: domainsList.map((d) => DomainModel.fromJson(d)).toList(),
    );
  }
}
