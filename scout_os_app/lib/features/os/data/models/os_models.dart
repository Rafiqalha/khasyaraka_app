import 'package:flutter/material.dart';

class IconMapper {
  static IconData fromString(String name) {
    switch (name) {
      case 'psychology_outlined':
      case 'psychology':
        return Icons.psychology_outlined;
      case 'security_outlined':
        return Icons.security_outlined;
      case 'security':
        return Icons.security;
      case 'code_outlined':
        return Icons.code_outlined;
      case 'code':
        return Icons.code;
      case 'phone_iphone_outlined':
        return Icons.phone_iphone_outlined;
      case 'rocket_launch_outlined':
        return Icons.rocket_launch_outlined;
      case 'insights_outlined':
        return Icons.insights_outlined;
      case 'cloud_queue_outlined':
        return Icons.cloud_queue_outlined;
      case 'palette_outlined':
        return Icons.palette_outlined;
      case 'calculate_outlined':
        return Icons.calculate_outlined;
      case 'workspace_premium_outlined':
        return Icons.workspace_premium_outlined;
      case 'picture_as_pdf_outlined':
        return Icons.picture_as_pdf_outlined;
      case 'table_chart_outlined':
        return Icons.table_chart_outlined;
      case 'person':
        return Icons.person;
      case 'email':
        return Icons.email;
      case 'speed':
        return Icons.speed;
      case 'tune':
        return Icons.tune;
      case 'dark_mode_outlined':
        return Icons.dark_mode_outlined;
      case 'notifications_none':
        return Icons.notifications_none;
      case 'shield_outlined':
        return Icons.shield_outlined;
      default:
        return Icons.help_outline;
    }
  }
}

class RegistrySpecializationModel {
  final String id;
  final String title;
  final List<String> packFiles;

  RegistrySpecializationModel({
    required this.id,
    required this.title,
    required this.packFiles,
  });

  factory RegistrySpecializationModel.fromJson(Map<String, dynamic> json) {
    return RegistrySpecializationModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      packFiles: (json['pack_files'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class RegistryDomainModel {
  final String id;
  final String title;
  final IconData icon;
  final List<RegistrySpecializationModel> specializations;

  RegistryDomainModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.specializations,
  });

  factory RegistryDomainModel.fromJson(Map<String, dynamic> json) {
    return RegistryDomainModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      icon: IconMapper.fromString(json['icon'] as String? ?? ''),
      specializations: (json['specializations'] as List<dynamic>?)
              ?.map((e) => RegistrySpecializationModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class PortfolioItemModel {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? tag;
  final String? actionText;

  PortfolioItemModel({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.tag,
    this.actionText,
  });

  factory PortfolioItemModel.fromJson(Map<String, dynamic> json) {
    return PortfolioItemModel(
      icon: IconMapper.fromString(json['icon'] as String? ?? ''),
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      tag: json['tag'] as String?,
      actionText: json['action_text'] as String?,
    );
  }
}

class PortfolioDataModel {
  final List<PortfolioItemModel> projects;
  final List<PortfolioItemModel> certificates;
  final List<PortfolioItemModel> exports;

  PortfolioDataModel({
    required this.projects,
    required this.certificates,
    required this.exports,
  });

  factory PortfolioDataModel.fromJson(Map<String, dynamic> json) {
    return PortfolioDataModel(
      projects: (json['projects'] as List<dynamic>?)
              ?.map((e) => PortfolioItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      certificates: (json['certificates'] as List<dynamic>?)
              ?.map((e) => PortfolioItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      exports: (json['exports'] as List<dynamic>?)
              ?.map((e) => PortfolioItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ProfileItemModel {
  final IconData icon;
  final String title;
  final String subtitle;

  ProfileItemModel({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  factory ProfileItemModel.fromJson(Map<String, dynamic> json) {
    return ProfileItemModel(
      icon: IconMapper.fromString(json['icon'] as String? ?? ''),
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
    );
  }
}

class ProfileDataModel {
  final List<ProfileItemModel> identity;
  final List<ProfileItemModel> preferences;
  final List<ProfileItemModel> settings;

  ProfileDataModel({
    required this.identity,
    required this.preferences,
    required this.settings,
  });

  factory ProfileDataModel.fromJson(Map<String, dynamic> json) {
    return ProfileDataModel(
      identity: (json['identity'] as List<dynamic>?)
              ?.map((e) => ProfileItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      preferences: (json['preferences'] as List<dynamic>?)
              ?.map((e) => ProfileItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      settings: (json['settings'] as List<dynamic>?)
              ?.map((e) => ProfileItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
