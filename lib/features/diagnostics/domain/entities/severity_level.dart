enum SeverityLevel {
  low,
  medium,
  high,
  critical,
}

extension SeverityLevelExtension on SeverityLevel {
  String get displayName {
    switch (this) {
      case SeverityLevel.low:
        return 'Low';
      case SeverityLevel.medium:
        return 'Medium';
      case SeverityLevel.high:
        return 'High';
      case SeverityLevel.critical:
        return 'Critical';
    }
  }

  String get color {
    switch (this) {
      case SeverityLevel.low:
        return '#4CAF50'; // Green
      case SeverityLevel.medium:
        return '#FF9800'; // Orange
      case SeverityLevel.high:
        return '#FF5722'; // Deep Orange
      case SeverityLevel.critical:
        return '#F44336'; // Red
    }
  }
}
