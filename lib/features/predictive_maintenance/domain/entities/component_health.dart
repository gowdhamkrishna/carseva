enum ComponentType {
  engine,
  brakes,
  transmission,
  battery,
  tires,
  fluids,
  suspension,
  cooling,
  electrical,
  exhaust;

  String get displayName {
    switch (this) {
      case ComponentType.engine:
        return 'Engine';
      case ComponentType.brakes:
        return 'Brakes';
      case ComponentType.transmission:
        return 'Transmission';
      case ComponentType.battery:
        return 'Battery';
      case ComponentType.tires:
        return 'Tires';
      case ComponentType.fluids:
        return 'Fluids';
      case ComponentType.suspension:
        return 'Suspension';
      case ComponentType.cooling:
        return 'Cooling System';
      case ComponentType.electrical:
        return 'Electrical';
      case ComponentType.exhaust:
        return 'Exhaust System';
    }
  }
}

extension ComponentTypeExtension on ComponentType {
  String get icon {
    switch (this) {
      case ComponentType.engine:
        return '🔧';
      case ComponentType.brakes:
        return '🛑';
      case ComponentType.transmission:
        return '⚙️';
      case ComponentType.battery:
        return '🔋';
      case ComponentType.tires:
        return '🛞';
      case ComponentType.fluids:
        return '💧';
      case ComponentType.suspension:
        return '🔩';
      case ComponentType.cooling:
        return '❄️';
      case ComponentType.electrical:
        return '⚡';
      case ComponentType.exhaust:
        return '💨';
    }
  }
}

class ComponentHealth {
  final ComponentType component;
  final double healthScore; // 0.0 to 100.0
  final String status; // e.g., "Excellent", "Good", "Fair", "Poor"
  final List<String> issues;
  final DateTime lastChecked;
  final DateTime? nextCheckDue;

  const ComponentHealth({
    required this.component,
    required this.healthScore,
    required this.status,
    required this.issues,
    required this.lastChecked,
    this.nextCheckDue,
  });

  String get healthColor {
    if (healthScore >= 80) return '#4CAF50'; // Green
    if (healthScore >= 60) return '#8BC34A'; // Light Green
    if (healthScore >= 40) return '#FF9800'; // Orange
    if (healthScore >= 20) return '#FF5722'; // Deep Orange
    return '#F44336'; // Red
  }
}
