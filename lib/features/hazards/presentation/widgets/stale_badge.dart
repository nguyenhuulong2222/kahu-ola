import 'package:flutter/material.dart';

import '../../domain/enums/freshness.dart';

class StaleBadge extends StatelessWidget {
  const StaleBadge({required this.freshness, super.key});

  final Freshness freshness;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (freshness) {
      Freshness.fresh => (const Color(0xFFD9F3E3), const Color(0xFF15563A)),
      Freshness.staleOk => (const Color(0xFFF9E7BF), const Color(0xFF7A5300)),
      Freshness.staleDrop => (const Color(0xFFF7D8D8), const Color(0xFF7D1E1E)),
      Freshness.unknown => (const Color(0xFFE1E5EA), const Color(0xFF38424D)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        freshness.label,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
