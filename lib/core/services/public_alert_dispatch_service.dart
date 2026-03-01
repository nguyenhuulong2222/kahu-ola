import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class PublicAlertDispatchService {
  PublicAlertDispatchService._();

  static const Map<String, String> _topicNames = {
    'Maui': 'alerts_maui',
    'Lanai': 'alerts_lanai',
    'Molokai': 'alerts_molokai',
  };

  static Future<void> publishHotspotAlert({
    required Set<String> islands,
    required List<String> locations,
    required int hotspotCount,
  }) async {
    if (islands.isEmpty || hotspotCount <= 0) return;

    final normalizedIslands = islands.toList()..sort();
    final topics = normalizedIslands
        .map((island) => _topicNames[island])
        .whereType<String>()
        .toList();
    if (topics.isEmpty) return;

    final now = DateTime.now().toUtc();
    final minuteBucket = DateTime.utc(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    ).toIso8601String();
    final signature = [
      minuteBucket,
      ...normalizedIslands,
      hotspotCount.toString(),
      ...locations.take(3),
    ].join('|');
    final alertId = base64Url.encode(utf8.encode(signature)).replaceAll('=', '');
    final islandLabel = normalizedIslands.join(', ');
    final body = locations.isEmpty
        ? 'NASA FIRMS detected $hotspotCount hotspot(s) in $islandLabel.'
        : 'NASA FIRMS detected $hotspotCount hotspot(s): ${locations.join(', ')}';

    await FirebaseFirestore.instance
        .collection('public_alert_dispatch')
        .doc(alertId)
        .set({
          'title': 'KAHU OLA ALERT',
          'body': body,
          'topics': topics,
          'islands': normalizedIslands,
          'locations': locations,
          'hotspotCount': hotspotCount,
          'source': 'nasa_firms',
          'createdAt': FieldValue.serverTimestamp(),
          'status': 'pending',
        }, SetOptions(merge: false));
  }
}
