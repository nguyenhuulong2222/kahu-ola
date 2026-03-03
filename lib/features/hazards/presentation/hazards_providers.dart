import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/build_info.dart';
import '../../../core/diagnostics/diagnostics_store.dart';
import '../../../core/network/http_client.dart';
import '../data/aggregator_client.dart';
import '../data/repositories/hazards_repository_impl.dart';
import '../domain/entities/fire_signal.dart';
import '../domain/entities/perimeter.dart';
import '../domain/entities/smoke_signal.dart';
import '../domain/repositories/hazards_repository.dart';
import '../domain/usecases/get_fire_signals.dart';
import '../domain/usecases/get_perimeters.dart';
import '../domain/usecases/get_smoke_signals.dart';

final diagnosticsStoreProvider = ChangeNotifierProvider<DiagnosticsStore>((
  Ref ref,
) {
  return DiagnosticsStore.instance;
});

final httpClientProvider = Provider<Dio>((Ref ref) {
  return buildHttpClient(appVersion: BuildInfo.appVersion);
});

final aggregatorClientProvider = Provider<AggregatorClient>((Ref ref) {
  return AggregatorClient(dio: ref.watch(httpClientProvider));
});

final hazardsRepositoryProvider = Provider<HazardsRepository>((Ref ref) {
  return HazardsRepositoryImpl(ref.watch(aggregatorClientProvider));
});

final getFireSignalsProvider = Provider<GetFireSignals>((Ref ref) {
  return GetFireSignals(ref.watch(hazardsRepositoryProvider));
});

final getSmokeSignalsProvider = Provider<GetSmokeSignals>((Ref ref) {
  return GetSmokeSignals(ref.watch(hazardsRepositoryProvider));
});

final getPerimetersProvider = Provider<GetPerimeters>((Ref ref) {
  return GetPerimeters(ref.watch(hazardsRepositoryProvider));
});

final refreshNonceProvider = StateProvider<int>((Ref ref) => 0);

final fireSignalsProvider = FutureProvider<List<FireSignal>>((Ref ref) async {
  ref.watch(refreshNonceProvider);
  return ref.watch(getFireSignalsProvider).call();
});

final smokeSignalsProvider = FutureProvider<List<SmokeSignal>>((Ref ref) async {
  ref.watch(refreshNonceProvider);
  return ref.watch(getSmokeSignalsProvider).call();
});

final perimetersProvider = FutureProvider<List<Perimeter>>((Ref ref) async {
  ref.watch(refreshNonceProvider);
  return ref.watch(getPerimetersProvider).call();
});
