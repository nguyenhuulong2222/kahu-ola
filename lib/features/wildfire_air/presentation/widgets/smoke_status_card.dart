import 'package:flutter/material.dart';
import 'package:kahu_ola/core/utils/geo_helper.dart';

/// Shows smoke risk status from Haleakala -> Kihei based on wind direction.
///
/// MesoWest wind convention:
/// [windDirFromDeg] means wind blows FROM that direction.
class SmokeStatusCard extends StatelessWidget {
  const SmokeStatusCard({
    super.key,
    required this.windDirFromDeg,
    this.windSpeedMps,
    this.minWindSpeedMps = 1.0,
    this.toleranceDeg = 30.0,
  });

  final double windDirFromDeg;
  final double? windSpeedMps;
  final double minWindSpeedMps;
  final double toleranceDeg;

  // Approx coordinates
  static const double _haleakalaLat = 20.7097;
  static const double _haleakalaLon = -156.2533;
  static const double _kiheiLat = 20.7850;
  static const double _kiheiLon = -156.4656;

  @override
  Widget build(BuildContext context) {
    final smokeRisk = isSmokeBlowingFromAToB(
      fireLat: _haleakalaLat,
      fireLon: _haleakalaLon,
      communityLat: _kiheiLat,
      communityLon: _kiheiLon,
      windDirFromDeg: windDirFromDeg,
      windSpeedMps: windSpeedMps,
      minWindSpeedMps: minWindSpeedMps,
      toleranceDeg: toleranceDeg,
    );

    // Chỉ hiển thị card khi có nguy cơ khói thổi về Kihei.
    if (!smokeRisk) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      color: cs.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.air_rounded, color: cs.onErrorContainer),
                const SizedBox(width: 8),
                Text(
                  'Smoke Risk (Kihei)',
                  style: tt.titleMedium?.copyWith(
                    color: cs.onErrorContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'HIGH',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Gió hiện tại có khả năng thổi khói từ Haleakala về phía Kihei.',
              style: tt.bodyMedium?.copyWith(color: cs.onErrorContainer),
            ),
            const SizedBox(height: 6),
            Text(
              'Wind dir: ${windDirFromDeg.toStringAsFixed(0)}°, '
              'speed: ${windSpeedMps?.toStringAsFixed(1) ?? 'n/a'} m/s',
              style: tt.bodySmall?.copyWith(
                color: cs.onErrorContainer.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

