import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/diagnostics/diagnostics_store.dart';
import '../domain/entities/fire_signal.dart';
import '../domain/entities/perimeter.dart';
import '../domain/entities/smoke_signal.dart';
import '../domain/enums/aggregator_health.dart';
import 'hazards_providers.dart';
import 'widgets/fire_card.dart';
import 'widgets/perimeter_card.dart';
import 'widgets/smoke_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diagnostics = ref.watch(diagnosticsStoreProvider);
    final fireSignals = ref.watch(fireSignalsProvider);
    final smokeSignals = ref.watch(smokeSignalsProvider);
    final perimeters = ref.watch(perimetersProvider);

    final allEmpty =
        (fireSignals.valueOrNull?.isEmpty ?? true) &&
        (smokeSignals.valueOrNull?.isEmpty ?? true) &&
        (perimeters.valueOrNull?.isEmpty ?? true);

    final anyLoading =
        fireSignals.isLoading || smokeSignals.isLoading || perimeters.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kahu Ola'),
        actions: <Widget>[
          IconButton(
            onPressed: () => context.push('/data-integrity'),
            tooltip: 'Data Integrity',
            icon: const Icon(Icons.monitor_heart_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: <Widget>[
            const _HeroPanel(),
            const SizedBox(height: 16),
            ..._buildBanners(context, diagnostics),
            _HazardSection(
              title: 'FireSignal',
              subtitle: 'Wildfire-first hotspot intelligence',
              child: _buildFireContent(fireSignals),
            ),
            const SizedBox(height: 16),
            _HazardSection(
              title: 'SmokeSignal',
              subtitle: 'Air quality and exposure guidance',
              child: _buildSmokeContent(smokeSignals),
            ),
            const SizedBox(height: 16),
            _HazardSection(
              title: 'Perimeter',
              subtitle: 'Official and estimated boundary updates',
              child: _buildPerimeterContent(perimeters),
            ),
            if (allEmpty && !anyLoading) ...<Widget>[
              const SizedBox(height: 16),
              const _EmptyStateCard(),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBanners(
    BuildContext context,
    DiagnosticsStore diagnostics,
  ) {
    final banners = <Widget>[];

    if (!diagnostics.firebaseReady) {
      banners.add(
        _BannerCard(
          color: const Color(0xFFF8E6B9),
          title: 'Notifications unavailable',
          message:
              'Firebase is unavailable right now. The dashboard remains usable.',
          icon: Icons.notifications_off_outlined,
        ),
      );
    }

    if (diagnostics.isOffline) {
      banners.add(
        _BannerCard(
          color: const Color(0xFFDDE9F8),
          title: 'Offline mode',
          message: 'Cached UI remains available while connectivity recovers.',
          icon: Icons.wifi_off_outlined,
        ),
      );
    }

    if (diagnostics.isCooldownActive) {
      banners.add(
        _BannerCard(
          color: const Color(0xFFF6E1D1),
          title: 'Cooldown active',
          message:
              'Data temporarily unavailable. The client will retry shortly.',
          icon: Icons.timer_outlined,
        ),
      );
    }

    if (diagnostics.aggregatorHealth == AggregatorHealth.degraded) {
      banners.add(
        _BannerCard(
          color: const Color(0xFFF8E6B9),
          title: 'Data source degraded',
          message:
              'Recent fetches are failing, but the dashboard stays online.',
          icon: Icons.warning_amber_outlined,
        ),
      );
    }

    if (diagnostics.aggregatorHealth == AggregatorHealth.unavailable) {
      banners.add(
        _BannerCard(
          color: const Color(0xFFF6D7D7),
          title: 'Data source unavailable',
          message:
              'Use official county, state, and federal guidance until service recovers.',
          icon: Icons.report_problem_outlined,
        ),
      );
    }

    return banners
        .expand((Widget banner) => <Widget>[banner, const SizedBox(height: 12)])
        .toList();
  }

  Widget _buildFireContent(AsyncValue<List<FireSignal>> asyncValue) {
    return asyncValue.when(
      data: (List<FireSignal> items) {
        if (items.isEmpty) {
          return const _EmptyCollectionMessage(
            message:
                'No active wildfire hotspots in the current signal window.',
          );
        }
        return Column(
          children: items
              .take(3)
              .map(
                (FireSignal item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FireCard(signal: item),
                ),
              )
              .toList(),
        );
      },
      loading: () => const _LoadingState(),
      error: (_, __) => const _EmptyCollectionMessage(
        message: 'FireSignal data is temporarily unavailable.',
      ),
    );
  }

  Widget _buildSmokeContent(AsyncValue<List<SmokeSignal>> asyncValue) {
    return asyncValue.when(
      data: (List<SmokeSignal> items) {
        if (items.isEmpty) {
          return const _EmptyCollectionMessage(
            message: 'No smoke advisories in the current signal window.',
          );
        }
        return Column(
          children: items
              .take(3)
              .map(
                (SmokeSignal item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SmokeCard(signal: item),
                ),
              )
              .toList(),
        );
      },
      loading: () => const _LoadingState(),
      error: (_, __) => const _EmptyCollectionMessage(
        message: 'SmokeSignal data is temporarily unavailable.',
      ),
    );
  }

  Widget _buildPerimeterContent(AsyncValue<List<Perimeter>> asyncValue) {
    return asyncValue.when(
      data: (List<Perimeter> items) {
        if (items.isEmpty) {
          return const _EmptyCollectionMessage(
            message: 'No perimeter updates are available right now.',
          );
        }
        return Column(
          children: items
              .take(3)
              .map(
                (Perimeter item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PerimeterCard(perimeter: item),
                ),
              )
              .toList(),
        );
      },
      loading: () => const _LoadingState(),
      error: (_, __) => const _EmptyCollectionMessage(
        message: 'Perimeter data is temporarily unavailable.',
      ),
    );
  }

  Future<void> _refresh(WidgetRef ref) async {
    ref.read(refreshNonceProvider.notifier).state++;
    await Future.wait(<Future<void>>[
      ref.read(fireSignalsProvider.future).then((_) {}),
      ref.read(smokeSignalsProvider.future).then((_) {}),
      ref.read(perimetersProvider.future).then((_) {}),
    ]);
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFF4A1E13),
            Color(0xFFB6461A),
            Color(0xFFE3A153),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Civic Hazard Intelligence',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Wildfire-first. Cache-first. Privacy-first.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'The dashboard renders even when data fails. Pull to refresh when conditions change.',
            style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({
    required this.color,
    required this.title,
    required this.message,
    required this.icon,
  });

  final Color color;
  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(message),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HazardSection extends StatelessWidget {
  const _HazardSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: <Widget>[
        SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(strokeWidth: 2.2),
        ),
        SizedBox(width: 12),
        Expanded(child: Text('Loading signal data...')),
      ],
    );
  }
}

class _EmptyCollectionMessage extends StatelessWidget {
  const _EmptyCollectionMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EEE7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(message),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const <Widget>[
            Text(
              'No active hazard signals',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'The client is healthy and the current response window is empty. Pull to refresh or open Data Integrity for diagnostics.',
            ),
          ],
        ),
      ),
    );
  }
}
