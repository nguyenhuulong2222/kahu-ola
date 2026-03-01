import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PushNotificationService {
  PushNotificationService._();

  static const String _mauiKey = 'alert_pref_maui';
  static const String _lanaiKey = 'alert_pref_lanai';
  static const String _molokaiKey = 'alert_pref_molokai';

  static const Map<String, String> _preferenceKeys = {
    'Maui': _mauiKey,
    'Lanai': _lanaiKey,
    'Molokai': _molokaiKey,
  };

  static const Map<String, String> _topicNames = {
    'Maui': 'alerts_maui',
    'Lanai': 'alerts_lanai',
    'Molokai': 'alerts_molokai',
  };

  static Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.setAutoInitEnabled(true);
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await syncSavedTopicSubscriptions();

    FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        debugPrint(
          'Foreground FCM message: ${message.messageId} '
          '${message.notification?.title ?? ''}',
        );
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (kDebugMode) {
        debugPrint('Notification opened app: ${message.messageId}');
      }
    });

    final token = await messaging.getToken();
    if (kDebugMode) {
      debugPrint('FCM device token: $token');
    }
  }

  static Future<Map<String, bool>> loadIslandPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      for (final entry in _preferenceKeys.entries)
        entry.key: prefs.getBool(entry.value) ?? true,
    };
  }

  static Future<void> setIslandPreference(
    String island,
    bool enabled,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _preferenceKeys[island];
    final topic = _topicNames[island];
    if (key == null || topic == null) return;

    await prefs.setBool(key, enabled);
    await _setTopicSubscription(topic: topic, enabled: enabled);
  }

  static Future<void> syncSavedTopicSubscriptions() async {
    final preferences = await loadIslandPreferences();

    for (final entry in preferences.entries) {
      final topic = _topicNames[entry.key];
      if (topic == null) continue;

      await _setTopicSubscription(topic: topic, enabled: entry.value);
    }
  }

  static Future<void> _setTopicSubscription({
    required String topic,
    required bool enabled,
  }) async {
    final messaging = FirebaseMessaging.instance;
    if (enabled) {
      await messaging.subscribeToTopic(topic);
    } else {
      await messaging.unsubscribeFromTopic(topic);
    }
  }
}
