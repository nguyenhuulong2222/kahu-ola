import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'config.dart';
import 'debug_panel.dart';
import 'diagnostics_store.dart';
import 'error_screen.dart';
import 'loading_screen.dart';

typedef AppShellContentBuilder = Widget Function(
  BuildContext context,
  AppConfig config,
);

typedef AppBootstrapper = Future<AppConfig> Function(DiagnosticsStore diagnostics);

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.builder,
    this.bootstrapper,
  });

  final AppShellContentBuilder builder;
  final AppBootstrapper? bootstrapper;

  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  static const Duration _bootstrapTimeout = Duration(seconds: 15);
  static const Duration _networkTimeout = Duration(seconds: 10);

  _AppShellPhase _phase = _AppShellPhase.loading;
  AppConfig? _config;
  String _errorSummary = 'Startup diagnostics are still loading.';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_runBootstrap());
    });
  }

  Future<void> _runBootstrap() async {
    final diagnostics = DiagnosticsStore.instance;
    diagnostics.beginBootstrapCycle();

    setState(() {
      _phase = _AppShellPhase.loading;
    });

    diagnostics.setBootstrapStep('BOOT 1/6: prepare shell');

    try {
      final bootstrap = widget.bootstrapper ?? _defaultBootstrap;
      final config = await bootstrap(diagnostics).timeout(_bootstrapTimeout);

      if (!mounted) {
        return;
      }

      diagnostics.setBootstrapStep('BOOT 6/6: shell ready');

      setState(() {
        _phase = _AppShellPhase.ready;
        _config = config;
      });
    } catch (error, stackTrace) {
      diagnostics.recordError(error, stackTrace, source: 'bootstrap');

      if (!mounted) {
        return;
      }

      setState(() {
        _phase = _AppShellPhase.error;
        _errorSummary = _friendlyErrorMessage(error);
      });
    }
  }

  Future<AppConfig> _defaultBootstrap(DiagnosticsStore diagnostics) async {
    diagnostics.setBootstrapStep('BOOT 2/6: load config');
    final config = await AppConfig.load();
    diagnostics.attachConfig(config);

    diagnostics.setBootstrapStep('BOOT 3/6: validate config');
    config.validate();

    diagnostics.setBootstrapStep('BOOT 4/6: verify optional services');
    if (config.useFirebase) {
      diagnostics.log(
        'Firebase is enabled by configuration. Native initialization must '
        'succeed before release builds ship.',
      );
    } else {
      diagnostics.log('Firebase is disabled for this build.');
    }

    diagnostics.setBootstrapStep('BOOT 5/6: check network reachability');
    await _warmReachability(config.apiBaseUrl, diagnostics);

    return config;
  }

  Future<void> _warmReachability(
    String baseUrl,
    DiagnosticsStore diagnostics,
  ) async {
    final uri = Uri.tryParse(baseUrl);
    if (uri == null || uri.host.isEmpty) {
      diagnostics.setNetworkReachability(
        NetworkReachability.unreachable,
        reason: 'invalid base URL',
      );
      return;
    }

    final client = HttpClient()..connectionTimeout = _networkTimeout;

    try {
      final request = await client.getUrl(uri).timeout(_networkTimeout);
      final response = await request.close().timeout(_networkTimeout);
      await response.drain<void>();
      diagnostics.setNetworkReachability(
        NetworkReachability.reachable,
        reason: 'HTTP ${response.statusCode}',
      );
    } catch (error) {
      diagnostics.log('BOOT: reachability probe failed: $error');
      diagnostics.setNetworkReachability(
        NetworkReachability.unreachable,
        reason: 'probe failed',
      );
    } finally {
      client.close(force: true);
    }
  }

  String _friendlyErrorMessage(Object error) {
    if (error is TimeoutException) {
      return 'Startup timed out after 15 seconds. Check connectivity and '
          'configuration, then retry.';
    }

    final text = error.toString().trim();
    if (text.isEmpty) {
      return 'Startup failed before the app became ready.';
    }
    return text.length > 240 ? '${text.substring(0, 240)}...' : text;
  }

  void _openDebugPanel() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DebugPanel(
          onRetryBootstrap: () {
            Navigator.of(context).pop();
            unawaited(_runBootstrap());
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    switch (_phase) {
      case _AppShellPhase.loading:
        child = const LoadingScreen(
          message: 'Preparing configuration and diagnostics...',
        );
        break;
      case _AppShellPhase.ready:
        try {
          child = widget.builder(context, _config ?? AppConfig.current);
        } catch (error, stackTrace) {
          DiagnosticsStore.instance.recordError(
            error,
            stackTrace,
            source: 'app_shell.main_builder',
          );
          child = ErrorScreen(
            summary: _friendlyErrorMessage(error),
            onRetry: () {
              unawaited(_runBootstrap());
            },
          );
        }
        break;
      case _AppShellPhase.error:
        child = ErrorScreen(
          summary: _errorSummary,
          onRetry: () {
            unawaited(_runBootstrap());
          },
        );
        break;
    }

    return DebugPanelControllerScope(
      openPanel: _openDebugPanel,
      retryBootstrap: () {
        unawaited(_runBootstrap());
      },
      child: Stack(
        children: [
          child,
          Positioned(
            top: 0,
            left: 0,
            width: 72,
            height: 72,
            child: const DebugTapTarget(
              child: SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

enum _AppShellPhase {
  loading,
  ready,
  error,
}
