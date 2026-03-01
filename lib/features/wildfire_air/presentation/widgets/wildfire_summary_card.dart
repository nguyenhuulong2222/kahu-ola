import 'package:flutter/material.dart';

/// Summary card for Wildfire & Air Quality (Module A3)
class WildfireSummaryCard extends StatelessWidget {
  final bool expanded;
  const WildfireSummaryCard({super.key, this.expanded = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      color: cs.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_fire_department_rounded,
                    color: cs.onSecondaryContainer),
                const SizedBox(width: 8),
                Text(
                  'Wildfire & Air',
                  style: tt.titleLarge
                      ?.copyWith(color: cs.onSecondaryContainer),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'WATCH',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'AQI: 85 · Moderate · Vog Advisory Active',
              style: tt.bodyLarge?.copyWith(
                  color: cs.onSecondaryContainer,
                  fontWeight: FontWeight.w600),
            ),
            if (expanded) ...[
              const SizedBox(height: 4),
              Text(
                'Wind: ENE 18 mph (Haleakalā summit) · Fuel Moisture: 12%',
                style: tt.bodySmall?.copyWith(
                    color: cs.onSecondaryContainer.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 4),
              Text(
                'Sources: NASA FIRMS · MesoWest · AirNow',
                style: tt.bodySmall?.copyWith(
                    color: cs.onSecondaryContainer.withValues(alpha: 0.6)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
