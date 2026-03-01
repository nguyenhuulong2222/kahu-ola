import 'package:flutter/material.dart';
import '../widgets/wildfire_summary_card.dart';

/// Wildfire & Air Quality — Module A3
/// Sources: NASA FIRMS · MesoWest · RAWS · AirNow
/// Monitors fire hotspots and wind direction on Haleakalā.
class WildfireAirPage extends StatelessWidget {
  const WildfireAirPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Wildfire & Air'),
            Text(
              'NASA FIRMS · MesoWest · AirNow',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const WildfireSummaryCard(expanded: true),
          const SizedBox(height: 16),

          // Data layers
          _DataLayerCard(
            tier: 'SPACE',
            icon: Icons.satellite_alt_rounded,
            source: 'GOES-West / Sentinel-2',
            description:
                'Wildfire detection from geostationary orbit. Thermal anomaly scanning every 5 minutes.',
            color: cs.primaryContainer,
          ),
          _DataLayerCard(
            tier: 'SUMMIT',
            icon: Icons.terrain_rounded,
            source: 'MesoWest / RAWS',
            description:
                'Haleakalā wind gusts & fuel moisture index. Critical for fire spread prediction.',
            color: cs.secondaryContainer,
          ),
          _DataLayerCard(
            tier: 'LAND',
            icon: Icons.local_fire_department_rounded,
            source: 'NASA FIRMS + AirNow',
            description:
                'Real-time fire hotspots & AQI / Vog level monitoring across all islands.',
            color: cs.tertiaryContainer,
          ),
        ],
      ),
    );
  }
}

class _DataLayerCard extends StatelessWidget {
  final String tier;
  final IconData icon;
  final String source;
  final String description;
  final Color color;

  const _DataLayerCard({
    required this.tier,
    required this.icon,
    required this.source,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Card(
      color: color,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tier,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5)),
                  Text(source,
                      style: tt.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(description, style: tt.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
