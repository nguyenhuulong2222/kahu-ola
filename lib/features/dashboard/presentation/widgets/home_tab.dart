import 'package:flutter/material.dart';
import '../../../alert_buddy/presentation/widgets/alert_summary_card.dart';
import '../../../wildfire_air/presentation/widgets/wildfire_summary_card.dart';
import '../../../ocean_safety/presentation/widgets/ocean_summary_card.dart';

/// Home tab — situational-awareness overview
/// Shows live alert cards from all 3 primary modules
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: () async {
        // TODO: trigger Riverpod providers refresh
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Space-to-Abyss status bar ──────────────────────────────────
          _SpaceToAbyssStatusBar(),
          const SizedBox(height: 16),

          // ── Section: Active Alerts ─────────────────────────────────────
          Text('Active Alerts', style: tt.headlineMedium),
          const SizedBox(height: 12),
          const AlertSummaryCard(),
          const SizedBox(height: 12),

          // ── Section: Wildfire & Air ───────────────────────────────────
          Text('Wildfire & Air Quality', style: tt.headlineMedium),
          const SizedBox(height: 12),
          const WildfireSummaryCard(),
          const SizedBox(height: 12),

          // ── Section: Ocean Safety ─────────────────────────────────────
          Text('Ocean Safety', style: tt.headlineMedium),
          const SizedBox(height: 12),
          const OceanSummaryCard(),
          const SizedBox(height: 24),

          // ── Legal disclaimer ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Kahu Ola is a civic-tech tool. It does not replace 911 or '
              'official emergency services. Always follow official guidance.',
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Top status bar showing which data layers are live
class _SpaceToAbyssStatusBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final layers = [
      ('Space', Icons.satellite_alt_rounded, true),
      ('Summit', Icons.terrain_rounded, true),
      ('Land', Icons.local_fire_department_rounded, true),
      ('Coast', Icons.anchor_rounded, false), // false = stale demo
      ('Abyss', Icons.waves_rounded, true),
    ];

    return Card(
      color: cs.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live Data Streams',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: layers
                  .map((l) => _LayerChip(
                        label: l.$1,
                        icon: l.$2,
                        isLive: l.$3,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _LayerChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLive;

  const _LayerChip({
    required this.label,
    required this.icon,
    required this.isLive,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = isLive ? cs.tertiary : cs.error;

    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
