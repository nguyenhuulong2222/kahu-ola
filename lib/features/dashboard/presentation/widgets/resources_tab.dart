import 'package:flutter/material.dart';

/// Resources tab — Guides, legal info, civic tech mission
class ResourcesTab extends StatelessWidget {
  const ResourcesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final resources = [
      (
        Icons.local_fire_department_rounded,
        'Wildfire Evacuation Guide',
        'HI Emergency Management Agency',
        cs.errorContainer,
      ),
      (
        Icons.water_rounded,
        'Tsunami Readiness',
        'Pacific Tsunami Warning Center',
        cs.primaryContainer,
      ),
      (
        Icons.air_rounded,
        'Vog Health Advisory',
        'Hawaii DOH Air Quality',
        cs.secondaryContainer,
      ),
      (
        Icons.health_and_safety_rounded,
        'Ocean Safety Tips',
        'Ocean Safety Division, HI',
        cs.tertiaryContainer,
      ),
      (
        Icons.gavel_rounded,
        'Legal Notice',
        'Civic Tech · Pro-bono · Not a replacement for 911',
        cs.surfaceContainerHighest,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Resources & Guides', style: tt.headlineMedium),
        const SizedBox(height: 16),
        ...resources.map(
          (r) => Card(
            color: r.$4,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(r.$1, size: 32),
              title: Text(r.$2,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16)),
              subtitle: Text(r.$3),
              trailing: const Icon(Icons.open_in_new_rounded, size: 18),
              onTap: () {},
            ),
          ),
        ),
      ],
    );
  }
}
