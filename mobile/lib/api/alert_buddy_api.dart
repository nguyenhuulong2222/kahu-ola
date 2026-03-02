import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../diagnostics_store.dart';

/// Alert object inside the /api/v1/alert-buddy response.
///
/// Backend shape:
/// "alert": {
///   "severity": "...",
///   "headline": "...",
///   ...
/// }
class AlertBuddyAlert {
  final String? severity;
  final String? headline;

  const AlertBuddyAlert({
    this.severity,
    this.headline,
  });

  factory AlertBuddyAlert.fromJson(Map<String, dynamic> j) {
    return AlertBuddyAlert(
      severity: j['severity']?.toString(),
      headline: j['headline']?.toString(),
    );
  }
}

/// Result model returned by /api/v1/alert-buddy
class AlertBuddyResult {
  final bool ok;
  final String placeLabel;
  final String lang;
  final String tz;
  final AlertBuddyAlert? alert;
  final String oneLiner;
  final List<String> actions;
  final Map<String, dynamic> meta;

  const AlertBuddyResult({
    required this.ok,
    required this.placeLabel,
    required this.lang,
    required this.tz,
    required this.alert,
    required this.oneLiner,
    required this.actions,
    required this.meta,
  });

  /// meta.cache_hit (bool) if present
  bool get cacheHit {
    final v = meta['cache_hit'];
    return v == true;
  }

  factory AlertBuddyResult.fromJson(Map<String, dynamic> j) {
    return AlertBuddyResult(
      ok: j['ok'] == true,
      placeLabel: (j['place_label'] ?? 'Maui').toString(),
      lang: (j['lang'] ?? 'auto').toString(),
      tz: (j['tz'] ?? 'Pacific/Honolulu').toString(),
      alert: j['alert'] is Map<String, dynamic>
          ? AlertBuddyAlert.fromJson(j['alert'] as Map<String, dynamic>)
          : null,
      oneLiner: (j['one_liner'] ?? '').toString(),
      actions: (j['actions'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      meta: (j['meta'] as Map<String, dynamic>? ?? <String, dynamic>{}),
    );
  }
}

class AlertBuddyApi {
  static const Duration _requestTimeout = Duration(seconds: 10);

  /// Normalized base URL (no trailing slash)
  final String baseUrl;

  /// If you pass [baseUrl], it overrides env var.
  /// Otherwise it uses --dart-define=API_BASE_URL (fallback to Cloud Run).
  AlertBuddyApi([String? baseUrl])
      : baseUrl = _normalizeBaseUrl(baseUrl ?? AppConfig.current.apiBaseUrl);

  static String _normalizeBaseUrl(String raw) {
    var s = raw.trim();
    while (s.endsWith('/')) {
      s = s.substring(0, s.length - 1);
    }
    return s;
  }

  /// Calls:
  /// GET {baseUrl}/api/v1/alert-buddy?lat=...&lon=...&...
  Future<AlertBuddyResult> getAlertBuddy({
    required double lat,
    required double lon,
    String lang = 'auto',
    String tz = 'Pacific/Honolulu',
    String placeLabel = 'Maui',
    bool useAi = true,
    int maxActions = 4,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/alert-buddy').replace(
      queryParameters: <String, String>{
        'lat': lat.toString(),
        'lon': lon.toString(),
        'lang': lang,
        'tz': tz,
        'place_label': placeLabel,
        'use_ai': useAi.toString(),
        'max_actions': maxActions.toString(),
      },
    );

    final diagnostics = DiagnosticsStore.instance;
    diagnostics.log('DATA: requesting alert snapshot from $uri');

    try {
      final resp = await http.get(
        uri,
        headers: const {'accept': 'application/json'},
      ).timeout(_requestTimeout);

      if (resp.statusCode != 200) {
        final body =
            resp.body.length > 800 ? resp.body.substring(0, 800) : resp.body;
        diagnostics.setNetworkReachability(
          NetworkReachability.reachable,
          reason: 'HTTP ${resp.statusCode}',
        );
        throw Exception('HTTP ${resp.statusCode} from $uri: $body');
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      diagnostics.setNetworkReachability(
        NetworkReachability.reachable,
        reason: 'HTTP ${resp.statusCode}',
      );
      diagnostics.log('DATA: alert snapshot loaded successfully');
      return AlertBuddyResult.fromJson(data);
    } on TimeoutException {
      diagnostics.setNetworkReachability(
        NetworkReachability.unreachable,
        reason: 'request timeout',
      );
      throw Exception('Request timed out after 10 seconds.');
    } on http.ClientException catch (e) {
      diagnostics.setNetworkReachability(
        NetworkReachability.unreachable,
        reason: 'client exception',
      );
      throw Exception('ClientException: ${e.message}, uri=$uri');
    } on FormatException catch (e) {
      diagnostics.recordError(
        e,
        StackTrace.current,
        source: 'alert_buddy_api.parse',
      );
      throw Exception('Invalid response payload from $uri');
    }
  }
}
