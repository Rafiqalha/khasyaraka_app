/// Training Part Model
/// 
/// Represents a Part (Bagian) in the training map.
/// Each Part contains multiple Units and maps to a backend Section.
/// 
/// Example:
/// - BAGIAN 1: Pengetahuan Umum (PUK) → Units 1-5
/// - BAGIAN 2: Pertolongan Pertama (PPGD) → Units 1-5
import 'training_path.dart';

class TrainingPart {
  final String sectionId;     // Backend section ID (e.g., "puk")
  final String title;         // Section title (e.g., "Pengetahuan Umum")
  final String? description;  // Optional description
  final int order;            // Display order (1, 2, 3...)
  final List<UnitModel> units;

  TrainingPart({
    required this.sectionId,
    required this.title,
    this.description,
    required this.order,
    required this.units,
  });

  /// Get display name (e.g., "BAGIAN 1")
  String get partLabel => 'BAGIAN $order';

  /// Get full title (e.g., "BAGIAN 1 • Pengetahuan Umum")
  String get fullTitle => '$partLabel • $title';

  /// Check if this part has any units
  bool get hasUnits => units.isNotEmpty;

  /// Total levels in this part
  int get totalLevels => units.fold(0, (sum, unit) => sum + unit.lessons.length);

  /// Create from Section and Units
  factory TrainingPart.fromSectionAndUnits({
    required String sectionId,
    required String title,
    String? description,
    required int order,
    required List<UnitModel> units,
  }) {
    return TrainingPart(
      sectionId: sectionId,
      title: title,
      description: description,
      order: order,
      units: units,
    );
  }
}
