import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/perimeter.dart';
import 'stale_badge.dart';

class PerimeterCard extends StatelessWidget {
  const PerimeterCard({required this.perimeter, super.key});

  final Perimeter perimeter;

  @override
  Widget build(BuildContext context) {
    final isOfficial = perimeter.official;
    final badgeColor = isOfficial
        ? const Color(0xFFD9F3E3)
        : const Color(0xFFF9E7BF);
    final badgeTextColor = isOfficial
        ? const Color(0xFF15563A)
        : const Color(0xFF7A5300);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4EF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isOfficial ? 'OFFICIAL' : 'ESTIMATED',
                  style: TextStyle(
                    color: badgeTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              StaleBadge(freshness: perimeter.freshness),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            perimeter.headline,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Provider: ${perimeter.provider} | Updated ${DateFormat('MMM d, HH:mm').format(perimeter.eventTime.toLocal())}',
          ),
          if (perimeter.acres > 0) ...<Widget>[
            const SizedBox(height: 4),
            Text('Area: ${perimeter.acres.toStringAsFixed(0)} acres'),
          ],
          if (!isOfficial) ...<Widget>[
            const SizedBox(height: 10),
            const Text(
              'Estimated perimeter only. Always verify with official county, state, and federal guidance.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}
