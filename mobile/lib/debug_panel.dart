import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'diagnostics_store.dart';

class DebugPanelControllerScope extends InheritedWidget {
  const DebugPanelControllerScope({
    super.key,
    required this.openPanel,
    required this.retryBootstrap,
    required super.child,
  });

  final VoidCallback openPanel;
  final VoidCallback retryBootstrap;

  static DebugPanelControllerScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DebugPanelControllerScope>();
  }

  @override
  bool updateShouldNotify(DebugPanelControllerScope oldWidget) {
    return openPanel != oldWidget.openPanel ||
        retryBootstrap != oldWidget.retryBootstrap;
  }
}

class DebugTapTarget extends StatefulWidget {
  const DebugTapTarget({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<DebugTapTarget> createState() => _DebugTapTargetState();
}

class _DebugTapTargetState extends State<DebugTapTarget> {
  static const int _requiredTaps = 7;
  static const Duration _requiredLongPress = Duration(seconds: 2);

  int _tapCount = 0;
  Timer? _tapResetTimer;
  Timer? _longPressTimer;

  @override
  void dispose() {
    _tapResetTimer?.cancel();
    _longPressTimer?.cancel();
    super.dispose();
  }

  void _activate() {
    _tapResetTimer?.cancel();
    _longPressTimer?.cancel();
    _tapCount = 0;
    DebugPanelControllerScope.maybeOf(context)?.openPanel();
  }

  void _onTap() {
    _tapCount += 1;
    _tapResetTimer?.cancel();
    _tapResetTimer = Timer(const Duration(seconds: 3), () {
      _tapCount = 0;
    });

    if (_tapCount >= _requiredTaps) {
      _activate();
    }
  }

  void _onLongPressDown(_) {
    _longPressTimer?.cancel();
    _longPressTimer = Timer(_requiredLongPress, _activate);
  }

  void _onLongPressEnd(_) {
    _longPressTimer?.cancel();
  }

  void _onLongPressCancel() {
    _longPressTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      onLongPressDown: _onLongPressDown,
      onLongPressEnd: _onLongPressEnd,
      onLongPressCancel: _onLongPressCancel,
      child: widget.child,
    );
  }
}

class DebugPanel extends StatelessWidget {
  const DebugPanel({
    super.key,
    required this.onRetryBootstrap,
  });

  final VoidCallback onRetryBootstrap;

  Future<void> _copyDiagnostics(BuildContext context) async {
    final report = DiagnosticsStore.instance.buildDiagnosticsReport();
    await Clipboard.setData(ClipboardData(text: report));

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Diagnostics copied to clipboard.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = DiagnosticsStore.instance;

    return SafeArea(
      child: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final config = store.config;

          return Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Runtime Diagnostics',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(label: 'Version', value: config?.appVersion ?? 'Unknown'),
                    _InfoRow(label: 'Build', value: config?.buildNumber ?? 'Unknown'),
                    _InfoRow(
                      label: 'Environment',
                      value: config?.environmentName ?? 'Unknown',
                    ),
                    _InfoRow(
                      label: 'API Base URL',
                      value: config?.maskedApiBaseUrl ?? 'Unknown',
                    ),
                    _InfoRow(
                      label: 'Network',
                      value: store.networkReachabilityLabel,
                    ),
                    _InfoRow(
                      label: 'Bootstrap',
                      value: store.lastBootstrapStep,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Last Error',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      store.lastError ?? 'None',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    ExpansionTile(
                      title: const Text('Stack trace'),
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: EdgeInsets.zero,
                      children: [
                        SelectableText(
                          store.lastStackTrace ?? 'No stack trace captured.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ExpansionTile(
                      title: const Text('Recent logs'),
                      initiallyExpanded: false,
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: EdgeInsets.zero,
                      children: [
                        SelectableText(
                          store.logLines.isEmpty
                              ? 'No logs captured yet.'
                              : store.logLines.join('\n'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton(
                          onPressed: onRetryBootstrap,
                          child: const Text('Retry bootstrap'),
                        ),
                        OutlinedButton(
                          onPressed: () => _copyDiagnostics(context),
                          child: const Text('Copy diagnostics'),
                        ),
                        TextButton(
                          onPressed: () {
                            DiagnosticsStore.instance.clearEphemeralState();
                          },
                          child: const Text('Reset local cache'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
