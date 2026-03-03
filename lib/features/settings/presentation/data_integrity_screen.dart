import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/config/build_info.dart';
import '../../hazards/presentation/hazards_providers.dart';

class DataIntegrityScreen extends ConsumerWidget {
  const DataIntegrityScreen({super.key});

  static const String _legalDisclaimer =
      'Kahu Ola is an independent civic technology platform that aggregates '
      'publicly available government data sources. It does not represent or '
      'replace official emergency services, evacuation orders, or governmental '
      'directives. Always follow official county, state, and federal guidance.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diagnostics = ref.watch(diagnosticsStoreProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Data Integrity')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Runtime Diagnostics',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FieldRow(
                    label: 'App version',
                    value: '${BuildInfo.buildName} (${BuildInfo.buildNumber})',
                  ),
                  _FieldRow(
                    label: 'Active base URL',
                    value: diagnostics.activeBaseUrl.isEmpty
                        ? 'Not configured'
                        : diagnostics.activeBaseUrl,
                  ),
                  _FieldRow(
                    label: 'Firebase status',
                    value: diagnostics.firebaseReady
                        ? 'Ready'
                        : 'Unavailable'
                              '${diagnostics.firebaseError == null ? '' : ' (${diagnostics.firebaseError})'}',
                  ),
                  _FieldRow(
                    label: 'Remote Config',
                    value: diagnostics.remoteConfigStatus.name,
                  ),
                  _FieldRow(
                    label: 'Fire last success',
                    value: _formatDate(diagnostics.lastFireFetchAt),
                  ),
                  _FieldRow(
                    label: 'Smoke last success',
                    value: _formatDate(diagnostics.lastSmokeFetchAt),
                  ),
                  _FieldRow(
                    label: 'Perimeter last success',
                    value: _formatDate(diagnostics.lastPerimeterFetchAt),
                  ),
                  _FieldRow(
                    label: 'Fire last error',
                    value: diagnostics.lastFireError ?? 'None',
                  ),
                  _FieldRow(
                    label: 'Smoke last error',
                    value: diagnostics.lastSmokeError ?? 'None',
                  ),
                  _FieldRow(
                    label: 'Perimeter last error',
                    value: diagnostics.lastPerimeterError ?? 'None',
                  ),
                  _FieldRow(
                    label: 'networkFailures',
                    value: diagnostics.networkFailures.toString(),
                  ),
                  _FieldRow(
                    label: 'parseFailures',
                    value: diagnostics.parseFailures.toString(),
                  ),
                  _FieldRow(
                    label: 'crashCount',
                    value: diagnostics.crashCount.toString(),
                  ),
                  _FieldRow(
                    label: 'Aggregator health',
                    value: diagnostics.aggregatorHealth.name,
                  ),
                  _FieldRow(
                    label: 'Cooldown active',
                    value: diagnostics.isCooldownActive ? 'Yes' : 'No',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: diagnostics.reset,
                      icon: const Icon(Icons.cleaning_services_outlined),
                      label: const Text('Clear Diagnostics'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Legal Disclaimer',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(_legalDisclaimer),
                ],
              ),
            ),
          ),
          if (kDebugMode) ...<Widget>[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  'Debug mode is active. This screen exposes session diagnostics only.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return 'Never';
    }
    return DateFormat('MMM d, yyyy HH:mm').format(value.toLocal());
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          SelectableText(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
