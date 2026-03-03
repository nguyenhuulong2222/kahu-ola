import '../../../../core/diagnostics/diagnostics_store.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/fire_signal.dart';
import '../../domain/entities/perimeter.dart';
import '../../domain/entities/smoke_signal.dart';
import '../../domain/repositories/hazards_repository.dart';
import '../aggregator_client.dart';

class HazardsRepositoryImpl implements HazardsRepository {
  HazardsRepositoryImpl(this._client);

  final AggregatorClient _client;

  @override
  Future<List<FireSignal>> getFireSignals() async {
    return _guardFetch(
      endpoint: HazardEndpoint.fire,
      fetcher: () async => (await _client.fetchFireSignals()).signals,
    );
  }

  @override
  Future<List<SmokeSignal>> getSmokeSignals() async {
    return _guardFetch(
      endpoint: HazardEndpoint.smoke,
      fetcher: () async => (await _client.fetchSmokeSignals()).signals,
    );
  }

  @override
  Future<List<Perimeter>> getPerimeters() async {
    return _guardFetch(
      endpoint: HazardEndpoint.perimeter,
      fetcher: () async => (await _client.fetchPerimeters()).signals,
    );
  }

  Future<List<T>> _guardFetch<T>({
    required HazardEndpoint endpoint,
    required Future<List<T>> Function() fetcher,
  }) async {
    final diagnostics = DiagnosticsStore.instance;

    try {
      final items = await fetcher();
      diagnostics.markOffline(false);
      diagnostics.recordFetchSuccess(endpoint);
      AppLogger.info(
        'Hazard signals fetched',
        meta: <String, dynamic>{
          'endpoint': endpoint.name,
          'count': items.length,
          'region': 'maui',
        },
      );
      return items;
    } on RateLimitException catch (error, stack) {
      diagnostics.enterRateLimitCooldown(seconds: error.cooldownSeconds);
      diagnostics.recordEndpointError(
        endpoint,
        error,
        domain: FailureDomain.network,
        stack: stack,
      );
      AppLogger.warn(
        'Aggregator rate limited',
        meta: <String, dynamic>{
          'endpoint': endpoint.name,
          'cooldown_seconds': error.cooldownSeconds,
        },
      );
      return <T>[];
    } on ParseException catch (error, stack) {
      diagnostics.recordEndpointError(
        endpoint,
        error,
        domain: FailureDomain.parse,
        stack: stack,
      );
      AppLogger.error(
        'Schema mismatch',
        meta: <String, dynamic>{'endpoint': endpoint.name},
      );
      return <T>[];
    } on NetworkException catch (error, stack) {
      diagnostics.markOffline(true);
      diagnostics.recordEndpointError(
        endpoint,
        error,
        domain: FailureDomain.network,
        stack: stack,
      );
      if (_allEndpointsStaleBeyondTenMinutes(diagnostics)) {
        diagnostics.markAggregatorUnavailable();
      }
      AppLogger.warn(
        'Network failure while fetching hazard data',
        meta: <String, dynamic>{'endpoint': endpoint.name},
      );
      return <T>[];
    } catch (error, stack) {
      diagnostics.markOffline(true);
      diagnostics.recordEndpointError(
        endpoint,
        error,
        domain: FailureDomain.network,
        stack: stack,
      );
      AppLogger.warn(
        'Unexpected repository failure',
        meta: <String, dynamic>{'endpoint': endpoint.name},
      );
      return <T>[];
    }
  }

  bool _allEndpointsStaleBeyondTenMinutes(DiagnosticsStore diagnostics) {
    final deadline = DateTime.now().toUtc().subtract(
      const Duration(minutes: 10),
    );
    final fetches = <DateTime?>[
      diagnostics.lastFireFetchAt,
      diagnostics.lastSmokeFetchAt,
      diagnostics.lastPerimeterFetchAt,
    ];

    return fetches.every(
      (DateTime? value) => value != null && value.isBefore(deadline),
    );
  }
}
