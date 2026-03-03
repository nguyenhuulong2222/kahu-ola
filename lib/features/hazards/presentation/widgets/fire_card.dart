import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/fire_signal.dart';
import '../../domain/enums/severity_level.dart';
import 'stale_badge.dart';

class FireCard extends StatelessWidget {
  const FireCard({required this.signal, super.key});

  final FireSignal signal;

  @override
  Widget build(BuildContext context) {
    final severityColor = switch (signal.severity) {
      SeverityLevel.info => const Color(0xFF2F6DB5),
      SeverityLevel.watch => const Color(0xFF947300),
      SeverityLevel.warning => const Color(0xFFB35A00),
      SeverityLevel.critical => const Color(0xFFAA1E12),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F2),
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
                  color: severityColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  signal.severity.label.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              StaleBadge(freshness: signal.freshness),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            signal.headline,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Provider: ${signal.provider} | Updated ${DateFormat('MMM d, HH:mm').format(signal.eventTime.toLocal())}',
          ),
          if (signal.reasonCodes.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: signal.reasonCodes
                  .take(3)
                  .map(
                    (String code) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        code,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
