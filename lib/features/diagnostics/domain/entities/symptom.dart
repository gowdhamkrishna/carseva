enum SymptomCategory {
  sounds,
  smells,
  visual,
  performance,
  handling,
  electrical,
}

extension SymptomCategoryExtension on SymptomCategory {
  String get displayName {
    switch (this) {
      case SymptomCategory.sounds:
        return 'Sounds';
      case SymptomCategory.smells:
        return 'Smells';
      case SymptomCategory.visual:
        return 'Visual';
      case SymptomCategory.performance:
        return 'Performance';
      case SymptomCategory.handling:
        return 'Handling';
      case SymptomCategory.electrical:
        return 'Electrical';
    }
  }

  String get icon {
    switch (this) {
      case SymptomCategory.sounds:
        return '🔊';
      case SymptomCategory.smells:
        return '👃';
      case SymptomCategory.visual:
        return '👁️';
      case SymptomCategory.performance:
        return '🏎️';
      case SymptomCategory.handling:
        return '🎯';
      case SymptomCategory.electrical:
        return '⚡';
    }
  }
}

class Symptom {
  final String id;
  final SymptomCategory category;
  final String description;
  final String? location; // e.g., "front left wheel", "engine bay"
  final DateTime reportedAt;
  final Map<String, dynamic>? additionalDetails;

  const Symptom({
    required this.id,
    required this.category,
    required this.description,
    this.location,
    required this.reportedAt,
    this.additionalDetails,
  });
}
