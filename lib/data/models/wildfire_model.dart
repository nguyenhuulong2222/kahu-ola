import 'package:equatable/equatable.dart';

/// Wildfire hotspot model — NASA FIRMS (A3)
class WildfireModel extends Equatable {
  final String id;
  final double latitude;
  final double longitude;
  final double brightness; // Kelvin
  final double frp; // Fire Radiative Power (MW)
  final String instrument; // MODIS / VIIRS
  final DateTime? acquisitionTime;
  final bool isStale;

  const WildfireModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.brightness,
    required this.frp,
    required this.instrument,
    this.acquisitionTime,
    this.isStale = false,
  });

  factory WildfireModel.fromJson(Map<String, dynamic> json) {
    return WildfireModel(
      id: json['id'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      brightness: (json['brightness'] as num?)?.toDouble() ?? 0.0,
      frp: (json['frp'] as num?)?.toDouble() ?? 0.0,
      instrument: json['instrument'] as String? ?? 'VIIRS',
      acquisitionTime: json['acq_datetime'] != null
          ? DateTime.tryParse(json['acq_datetime'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, latitude, longitude, frp, isStale];
}

/// Air Quality model — AirNow (A3)
class AirQualityModel extends Equatable {
  final int aqi;
  final String category; // Good | Moderate | Unhealthy | Hazardous
  final String pollutant; // PM2.5 | SO2 (Vog)
  final String stationName;
  final DateTime? reportingTime;
  final bool isStale;

  const AirQualityModel({
    required this.aqi,
    required this.category,
    required this.pollutant,
    required this.stationName,
    this.reportingTime,
    this.isStale = false,
  });

  factory AirQualityModel.fromJson(Map<String, dynamic> json) {
    return AirQualityModel(
      aqi: (json['AQI'] as num?)?.toInt() ?? 0,
      category: json['Category']?['Name'] as String? ?? 'Unknown',
      pollutant: json['ParameterName'] as String? ?? 'PM2.5',
      stationName: json['ReportingArea'] as String? ?? '',
      reportingTime: json['DateObserved'] != null
          ? DateTime.tryParse(json['DateObserved'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [aqi, category, pollutant, stationName, isStale];
}
