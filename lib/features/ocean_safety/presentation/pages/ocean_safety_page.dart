import 'package:flutter/material.dart';
import '../widgets/ocean_summary_card.dart';

/// Ocean Safety — Module A5
/// Sources: PacIOOS · ALOHA · USGS
/// Monitors rip currents, tidal surge, harbor inundation, and tsunami signals.
class OceanSafetyPage extends StatelessWidget {
  const OceanSafetyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ocean Safety'),
            Text(
              'PacIOOS · ALOHA · USGS',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const OceanSummaryCard(expanded: true),
          const SizedBox(height: 16),
          _OceanDataCard(
            tier: 'COAST',
            icon: Icons.anchor_rounded,
            source: 'USGS / PacIOOS',
            description:
                'Flash flood warnings from upstream watersheds & harbor inundation levels at key ports.',
            color: cs.primaryContainer,
          ),
          _OceanDataCard(
            tier: 'ABYSS',
            icon: Icons.waves_rounded,
            source: 'ALOHA / PacIOOS',
            description:
                'Deep-sea pressure at 4,800 m for early tsunami detection. '
                'Sub-1-second alert latency target.',
            color: cs.tertiaryContainer,
          ),
          const SizedBox(height: 16),
          // Privacy note
          Card(
            color: cs.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.lock_rounded, color: cs.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Edge Computing Privacy: Your location is never sent to our servers. '
                      'Risk distance calculations happen entirely on your device.',
                      style: tt.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OceanDataCard extends StatelessWidget {
  final String tier;
  final IconData icon;
  final String source;
  final String description;
  final Color color;

  const _OceanDataCard({
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
