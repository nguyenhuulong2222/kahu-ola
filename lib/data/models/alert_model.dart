import 'package:equatable/equatable.dart';

/// NWS alert data model (A1 — Alert Buddy)
class AlertModel extends Equatable {
  final String id;
  final String headline;
  final String description;
  final String area;
  final String severity; // Extreme | Severe | Moderate | Minor
  final String urgency;
  final String certainty;
  final DateTime? effective;
  final DateTime? expires;
  final String source;
  final bool isStale;

  const AlertModel({
    required this.id,
    required this.headline,
    required this.description,
    required this.area,
    required this.severity,
    required this.urgency,
    required this.certainty,
    this.effective,
    this.expires,
    this.source = 'NWS',
    this.isStale = false,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] as String? ?? '',
      headline: json['headline'] as String? ?? '',
      description: json['description'] as String? ?? '',
      area: json['areaDesc'] as String? ?? '',
      severity: json['severity'] as String? ?? 'Unknown',
      urgency: json['urgency'] as String? ?? 'Unknown',
      certainty: json['certainty'] as String? ?? 'Unknown',
      effective: json['effective'] != null
          ? DateTime.tryParse(json['effective'] as String)
          : null,
      expires: json['expires'] != null
          ? DateTime.tryParse(json['expires'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'headline': headline,
        'description': description,
        'areaDesc': area,
        'severity': severity,
        'urgency': urgency,
        'certainty': certainty,
        'effective': effective?.toIso8601String(),
        'expires': expires?.toIso8601String(),
      };

  AlertModel copyWith({bool? isStale}) => AlertModel(
        id: id,
        headline: headline,
        description: description,
        area: area,
        severity: severity,
        urgency: urgency,
        certainty: certainty,
        effective: effective,
        expires: expires,
        source: source,
        isStale: isStale ?? this.isStale,
      );

  @override
  List<Object?> get props => [id, headline, area, severity, expires, isStale];
}
