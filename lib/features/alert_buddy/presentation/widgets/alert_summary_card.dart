import 'package:flutter/material.dart';

/// Compact or expanded summary card for NWS alerts
class AlertSummaryCard extends StatelessWidget {
  final bool expanded;
  const AlertSummaryCard({super.key, this.expanded = false});

  @override
  Widget build(BuildContext context) {
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
                Icon(Icons.notifications_active_rounded,
                    color: cs.onErrorContainer),
                const SizedBox(width: 8),
                Text(
                  'Alert Buddy',
                  style: tt.titleLarge?.copyWith(color: cs.onErrorContainer),
                ),
                const Spacer(),
                // Live badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'LIVE',
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
              '3 active alerts for Hawaii',
              style: tt.bodyLarge?.copyWith(
                  color: cs.onErrorContainer,
                  fontWeight: FontWeight.w600),
            ),
            if (expanded) ...[
              const SizedBox(height: 4),
              Text(
                'Source: NWS api.weather.gov · Updated <1 min ago',
                style: tt.bodySmall?.copyWith(
                    color: cs.onErrorContainer.withValues(alpha: 0.7)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
