/// Sandi Pramuka Model
///
/// Represents a Scout Cipher (Sandi) type from the backend API.
class SandiModel {
  final int id;
  final String codename;
  final String name;
  final String? description;
  final int difficulty; // 1-4
  final String category; // encoding, substitution, transposition, visual
  final DateTime createdAt;
  final DateTime updatedAt;

  SandiModel({
    required this.id,
    required this.codename,
    required this.name,
    this.description,
    required this.difficulty,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SandiModel.fromJson(Map<String, dynamic> json) {
    // Helper for safe int parsing
    int safeInt(String key, int defaultValue) {
      final value = json[key];
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      if (value is num) return value.toInt();
      return defaultValue;
    }

    // Helper for safe DateTime parsing
    DateTime safeDateTime(String key) {
      final value = json[key];
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          return DateTime.now();
        }
      }
      if (value is DateTime) return value;
      return DateTime.now();
    }

    return SandiModel(
      id: safeInt('id', 0),
      codename: json['codename']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      difficulty: safeInt('difficulty', 1),
      category: json['category']?.toString() ?? 'encoding',
      createdAt: safeDateTime('created_at'),
      updatedAt: safeDateTime('updated_at'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codename': codename,
      'name': name,
      'description': description,
      'difficulty': difficulty,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Response model for Sandi List API
class SandiListResponse {
  final int total;
  final List<SandiModel> sandiTypes;

  SandiListResponse({required this.total, required this.sandiTypes});

  factory SandiListResponse.fromJson(Map<String, dynamic> json) {
    final sandiTypesList = json['sandi_types'] as List<dynamic>? ?? [];
    return SandiListResponse(
      total: json['total'] as int? ?? sandiTypesList.length,
      sandiTypes: sandiTypesList
          .map((item) => SandiModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
