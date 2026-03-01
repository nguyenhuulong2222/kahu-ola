import 'dart:math' as math;

/// Bearing from A -> B in degrees:
/// 0 = North, 90 = East, 180 = South, 270 = West.
double bearingDegrees({
  required double latA,
  required double lonA,
  required double latB,
  required double lonB,
}) {
  final phi1 = latA * math.pi / 180.0;
  final phi2 = latB * math.pi / 180.0;
  final dLon = (lonB - lonA) * math.pi / 180.0;

  final y = math.sin(dLon) * math.cos(phi2);
  final x = math.cos(phi1) * math.sin(phi2) -
      math.sin(phi1) * math.cos(phi2) * math.cos(dLon);

  final theta = math.atan2(y, x);
  return (theta * 180.0 / math.pi + 360.0) % 360.0;
}

double _angularDiff(double a, double b) {
  final diff = (a - b).abs() % 360.0;
  return diff > 180.0 ? 360.0 - diff : diff;
}

/// Returns true when wind direction suggests smoke can move from A (fire)
/// toward B (community).
///
/// [windDirFromDeg] follows meteo standard (wind is coming FROM this direction).
/// Example: 270 means wind from West to East.
bool isSmokeBlowingFromAToB({
  required double fireLat,
  required double fireLon,
  required double communityLat,
  required double communityLon,
  required double windDirFromDeg,
  double? windSpeedMps,
  double minWindSpeedMps = 1.0,
  double toleranceDeg = 30.0,
}) {
  if (windSpeedMps != null && windSpeedMps < minWindSpeedMps) {
    return false;
  }

  final bearingAToB = bearingDegrees(
    latA: fireLat,
    lonA: fireLon,
    latB: communityLat,
    lonB: communityLon,
  );

  final windToDeg = (windDirFromDeg + 180.0) % 360.0;
  final diff = _angularDiff(windToDeg, bearingAToB);
  return diff <= toleranceDeg;
}

