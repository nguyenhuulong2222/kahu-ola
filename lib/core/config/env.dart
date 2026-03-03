import '../diagnostics/diagnostics_store.dart';
import '../utils/logger.dart';

class Env {
  Env._();

  static const String _compiledUrl = String.fromEnvironment(
    'AGGREGATOR_BASE_URL',
    defaultValue: '',
  );

  static String _remoteConfigUrl = '';

  static String get aggregatorBaseUrl {
    if (_remoteConfigUrl.isNotEmpty) {
      return _remoteConfigUrl;
    }
    return _compiledUrl;
  }

  static void initialize() {
    final diagnostics = DiagnosticsStore.instance;
    diagnostics.activeBaseUrl = aggregatorBaseUrl;
    diagnostics.remoteConfigStatus = aggregatorBaseUrl.isEmpty
        ? RemoteConfigStatus.unavailable
        : RemoteConfigStatus.fallback;
  }

  static void applyRemoteConfig(String url) {
    if (url.isEmpty || !url.startsWith('https://')) {
      DiagnosticsStore.instance.remoteConfigStatus =
          RemoteConfigStatus.unavailable;
      return;
    }

    _remoteConfigUrl = url;
    final diagnostics = DiagnosticsStore.instance;
    diagnostics.activeBaseUrl = url;
    diagnostics.remoteConfigStatus = RemoteConfigStatus.loaded;
    AppLogger.warn(
      'Aggregator base URL updated',
      meta: const {'domain': 'config'},
    );
  }
}
