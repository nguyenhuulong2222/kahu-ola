import 'package:flutter/material.dart';
import '../widgets/alert_summary_card.dart';

/// Alert Buddy — Module A1
/// Source: NWS api.weather.gov
/// Aggregates and summarises National Weather Service alerts for Hawaii.
class AlertBuddyPage extends StatelessWidget {
  const AlertBuddyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Alert Buddy'),
            Text(
              'NWS · api.weather.gov',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const AlertSummaryCard(expanded: true),
          const SizedBox(height: 16),
          const _MockAlertList(),
        ],
      ),
    );
  }
}

class _MockAlertList extends StatelessWidget {
  const _MockAlertList();

  @override
  Widget build(BuildContext context) {
    const alerts = [
      _AlertItem(
        title: 'Gale Warning',
        area: 'Maui County Waters',
        severity: 'Severe',
        expires: 'Feb 28, 6:00 AM HST',
        color: Color(0xFFE64A19),
      ),
      _AlertItem(
        title: 'Flash Flood Watch',
        area: 'Hana District',
        severity: 'Moderate',
        expires: 'Feb 28, 12:00 PM HST',
        color: Color(0xFFF9A825),
      ),
      _AlertItem(
        title: 'Vog Advisory',
        area: 'Statewide',
        severity: 'Minor',
        expires: 'Ongoing',
        color: Color(0xFF2E7D32),
      ),
    ];

    return Column(children: alerts.toList());
  }
}

class _AlertItem extends StatelessWidget {
  final String title;
  final String area;
  final String severity;
  final String expires;
  final Color color;

  const _AlertItem({
    required this.title,
    required this.area,
    required this.severity,
    required this.expires,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(Icons.warning_amber_rounded, color: color),
        ),
        title: Text(title,
            style: TextStyle(fontWeight: FontWeight.w700, color: color)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(area),
            Text('Expires: $expires',
                style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Chip(
          label: Text(severity,
              style: const TextStyle(fontSize: 12, color: Colors.white)),
          backgroundColor: color,
          padding: EdgeInsets.zero,
        ),
        isThreeLine: true,
      ),
    );
  }
}
