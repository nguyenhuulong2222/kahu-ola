enum SeverityLevel { info, watch, warning, critical }

SeverityLevel severityLevelFromWire(String value) {
  switch (value.toUpperCase()) {
    case 'INFO':
      return SeverityLevel.info;
    case 'WATCH':
      return SeverityLevel.watch;
    case 'WARNING':
      return SeverityLevel.warning;
    case 'CRITICAL':
      return SeverityLevel.critical;
    default:
      return SeverityLevel.info;
  }
}

extension SeverityLevelLabel on SeverityLevel {
  String get label {
    switch (this) {
      case SeverityLevel.info:
        return 'Info';
      case SeverityLevel.watch:
        return 'Watch';
      case SeverityLevel.warning:
        return 'Warning';
      case SeverityLevel.critical:
        return 'Critical';
    }
  }
}
