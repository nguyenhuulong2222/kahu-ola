import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'debug_panel.dart';
import 'diagnostics_store.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    super.key,
    required this.summary,
    required this.onRetry,
  });

  final String summary;
  final VoidCallback onRetry;

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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const DebugTapTarget(
                  child: Text(
                    'Kahu Ola',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'We could not finish startup.',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  summary,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: onRetry,
                      child: const Text('Retry'),
                    ),
                    OutlinedButton(
                      onPressed: () => _copyDiagnostics(context),
                      child: const Text('Copy diagnostics'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InlineMessageCard extends StatelessWidget {
  const InlineMessageCard({
    super.key,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.icon = Icons.info_outline,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onAction,
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
