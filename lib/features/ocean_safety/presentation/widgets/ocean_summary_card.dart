import 'package:flutter/material.dart';

/// Summary card for Ocean Safety (Module A5)
class OceanSummaryCard extends StatelessWidget {
  final bool expanded;
  const OceanSummaryCard({super.key, this.expanded = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      color: cs.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.waves_rounded, color: cs.onPrimaryContainer),
                const SizedBox(width: 8),
                Text(
                  'Ocean Safety',
                  style: tt.titleLarge
                      ?.copyWith(color: cs.onPrimaryContainer),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'NORMAL',
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
              'No tsunami signals · Rip current risk: Low',
              style: tt.bodyLarge?.copyWith(
                  color: cs.onPrimaryContainer,
                  fontWeight: FontWeight.w600),
            ),
            if (expanded) ...[
              const SizedBox(height: 4),
              Text(
                'ALOHA depth pressure: 14.7 psi (nominal)',
                style: tt.bodySmall?.copyWith(
                    color: cs.onPrimaryContainer.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 4),
              Text(
                'Sources: PacIOOS · ALOHA · USGS',
                style: tt.bodySmall?.copyWith(
                    color: cs.onPrimaryContainer.withValues(alpha: 0.6)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
