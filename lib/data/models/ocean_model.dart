import 'package:equatable/equatable.dart';

/// Ocean safety model — PacIOOS / ALOHA (A5)
class OceanModel extends Equatable {
  final String stationId;
  final String stationName;
  final double waterTemperature; // Celsius
  final double waveHeight; // Meters
  final double wavePeriod; // Seconds
  final double currentSpeed; // m/s
  final String currentDirection;
  final double tidalHeight; // Meters above datum
  final bool tsunamiSignalDetected;
  final DateTime? observedAt;
  final bool isStale;

  const OceanModel({
    required this.stationId,
    required this.stationName,
    required this.waterTemperature,
    required this.waveHeight,
    required this.wavePeriod,
    required this.currentSpeed,
    required this.currentDirection,
    required this.tidalHeight,
    this.tsunamiSignalDetected = false,
    this.observedAt,
    this.isStale = false,
  });

  factory OceanModel.fromJson(Map<String, dynamic> json) {
    return OceanModel(
      stationId: json['station_id'] as String? ?? '',
      stationName: json['station_name'] as String? ?? '',
      waterTemperature:
          (json['water_temp_c'] as num?)?.toDouble() ?? 0.0,
      waveHeight: (json['wave_height_m'] as num?)?.toDouble() ?? 0.0,
      wavePeriod: (json['wave_period_s'] as num?)?.toDouble() ?? 0.0,
      currentSpeed: (json['current_speed_ms'] as num?)?.toDouble() ?? 0.0,
      currentDirection: json['current_direction'] as String? ?? 'N',
      tidalHeight: (json['tidal_height_m'] as num?)?.toDouble() ?? 0.0,
      tsunamiSignalDetected:
          json['tsunami_signal'] as bool? ?? false,
      observedAt: json['observed_at'] != null
          ? DateTime.tryParse(json['observed_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props =>
      [stationId, waveHeight, currentSpeed, tsunamiSignalDetected, isStale];
}

/// Deep-sea pressure model — ALOHA buoy (Abyss layer)
class DeepSeaPressureModel extends Equatable {
  final String buoyId;
  final double depthMeters; // e.g. 4800 m
  final double pressurePsi;
  final double pressureAnomaly; // deviation from baseline
  final bool isTsunamiCandidate;
  final DateTime? recordedAt;

  const DeepSeaPressureModel({
    required this.buoyId,
    required this.depthMeters,
    required this.pressurePsi,
    required this.pressureAnomaly,
    required this.isTsunamiCandidate,
    this.recordedAt,
  });

  factory DeepSeaPressureModel.fromJson(Map<String, dynamic> json) {
    return DeepSeaPressureModel(
      buoyId: json['buoy_id'] as String? ?? '',
      depthMeters: (json['depth_m'] as num?)?.toDouble() ?? 4800.0,
      pressurePsi: (json['pressure_psi'] as num?)?.toDouble() ?? 0.0,
      pressureAnomaly: (json['anomaly'] as num?)?.toDouble() ?? 0.0,
      isTsunamiCandidate: json['tsunami_candidate'] as bool? ?? false,
      recordedAt: json['recorded_at'] != null
          ? DateTime.tryParse(json['recorded_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props =>
      [buoyId, depthMeters, pressurePsi, isTsunamiCandidate];
}
