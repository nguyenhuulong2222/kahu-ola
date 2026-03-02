import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/alert_buddy_api.dart';
import '../diagnostics_store.dart';

class AlertBuddyUiState {
  final bool loading;
  final String? error;
  final AlertBuddyResult? data;
  final bool cacheHit;

  const AlertBuddyUiState({
    this.loading = false,
    this.error,
    this.data,
    this.cacheHit = false,
  });

  AlertBuddyUiState copyWith({
    bool? loading,
    String? error,
    AlertBuddyResult? data,
    bool? cacheHit,
  }) {
    return AlertBuddyUiState(
      loading: loading ?? this.loading,
      error: error,
      data: data ?? this.data,
      cacheHit: cacheHit ?? this.cacheHit,
    );
  }
}

final alertBuddyApiProvider = Provider<AlertBuddyApi>((ref) {
  return AlertBuddyApi();
});

final alertBuddyControllerProvider =
    StateNotifierProvider<AlertBuddyController, AlertBuddyUiState>((ref) {
  return AlertBuddyController(ref.read(alertBuddyApiProvider));
});

class AlertBuddyController extends StateNotifier<AlertBuddyUiState> {
  AlertBuddyController(this._api) : super(const AlertBuddyUiState());

  final AlertBuddyApi _api;

  Future<void> loadOnce({
    required double lat,
    required double lon,
    required String placeLabel,
    required String lang,
    required int maxActions,
    required bool useAi,
    bool silent = false,
  }) async {
    final diagnostics = DiagnosticsStore.instance;

    if (!silent) {
      state = state.copyWith(loading: true, error: null);
    } else {
      state = state.copyWith(error: null);
    }

    diagnostics.log(
      'DATA: loadOnce(place=$placeLabel, lang=$lang, useAi=$useAi, '
      'maxActions=$maxActions, silent=$silent)',
    );

    try {
      final res = await _api.getAlertBuddy(
        lat: lat,
        lon: lon,
        placeLabel: placeLabel, // ✅ fix: place -> placeLabel
        lang: lang,
        maxActions: maxActions,
        useAi: useAi,
      );

      state = AlertBuddyUiState(
        loading: false,
        error: null,
        data: res,
        cacheHit: res.cacheHit,
      );
      diagnostics.log('DATA: UI state updated successfully');
    } catch (e) {
      state = AlertBuddyUiState(
        loading: false,
        error: e.toString(),
        data: state.data,
        cacheHit: state.cacheHit,
      );
      diagnostics.recordError(
        e,
        StackTrace.current,
        source: 'alert_buddy_provider.loadOnce',
      );
    }
  }
}
