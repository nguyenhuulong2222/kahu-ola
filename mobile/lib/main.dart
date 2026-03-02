import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_shell.dart';
import 'debug_panel.dart';
import 'diagnostics_store.dart';
import 'error_screen.dart';
import 'loading_screen.dart';
import 'state/alert_buddy_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final diagnostics = DiagnosticsStore.instance;
  FlutterError.onError = diagnostics.recordFlutterError;
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    diagnostics.recordError(
      error,
      stackTrace,
      source: 'platform_dispatcher',
    );
    return true;
  };

  runZonedGuarded(
    () {
      runApp(const ProviderScope(child: MauiApp()));
    },
    (error, stackTrace) {
      diagnostics.recordError(
        error,
        stackTrace,
        source: 'run_zoned_guarded',
      );
    },
  );
}

class MauiApp extends StatelessWidget {
  const MauiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maui Alert Buddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      builder: (context, child) {
        return child ??
            const LoadingScreen(
              message: 'Rendering the app shell...',
            );
      },
      home: AppShell(
        builder: (context, _) => const AlertBuddyPage(),
      ),
    );
  }
}

/// UI language code for labels.
/// - If user selects "auto", use device locale.
/// - Otherwise use selected lang.
String _uiLang(BuildContext context, String selected) {
  if (selected == 'auto') {
    return Localizations.localeOf(context).languageCode.toLowerCase();
  }
  return selected.toLowerCase();
}

String _t(BuildContext context, String selectedLang, String key) {
  final lang = _uiLang(context, selectedLang);

  // English
  const en = <String, String>{
    'place': 'Place',
    'language': 'Language',
    'max_actions': 'Max actions',
    'actions': 'actions',
    'use_ai': 'Use AI',
    'auto_refresh_on': 'Auto-refresh: ON',
    'auto_refresh_off': 'Auto-refresh: OFF',
    'severity': 'Severity',
    'cache': 'cache',
    'live': 'live',
    'updated': 'Updated',
    'no_alerts_for': 'No active weather alerts for',
    'loading': 'Loading…',
    'error': 'Error',
    'refresh': 'Refresh',
  };

  // Vietnamese
  const vi = <String, String>{
    'place': 'Khu vực',
    'language': 'Ngôn ngữ',
    'max_actions': 'Tối đa hành động',
    'actions': 'hành động',
    'use_ai': 'Dùng AI',
    'auto_refresh_on': 'Tự làm mới: BẬT',
    'auto_refresh_off': 'Tự làm mới: TẮT',
    'severity': 'Mức độ',
    'cache': 'cache',
    'live': 'live',
    'updated': 'Cập nhật',
    'no_alerts_for': 'Không có cảnh báo thời tiết cho',
    'loading': 'Đang tải…',
    'error': 'Lỗi',
    'refresh': 'Làm mới',
  };

  // Tagalog / Filipino (tl)
  const tl = <String, String>{
    'place': 'Lugar',
    'language': 'Wika',
    'max_actions': 'Max na aksyon',
    'actions': 'mga aksyon',
    'use_ai': 'Gumamit ng AI',
    'auto_refresh_on': 'Auto-refresh: ON',
    'auto_refresh_off': 'Auto-refresh: OFF',
    'severity': 'Antas',
    'cache': 'cache',
    'live': 'live',
    'updated': 'Na-update',
    'no_alerts_for': 'Walang aktibong babala sa panahon para sa',
    'loading': 'Naglo-load…',
    'error': 'Error',
    'refresh': 'Refresh',
  };

  // Korean (ko)
  const ko = <String, String>{
    'place': '지역',
    'language': '언어',
    'max_actions': '최대 행동',
    'actions': '개의 행동',
    'use_ai': 'AI 사용',
    'auto_refresh_on': '자동 새로고침: ON',
    'auto_refresh_off': '자동 새로고침: OFF',
    'severity': '심각도',
    'cache': 'cache',
    'live': 'live',
    'updated': '업데이트',
    'no_alerts_for': '현재 기상 경보가 없습니다:',
    'loading': '로딩 중…',
    'error': '오류',
    'refresh': '새로고침',
  };

  // Japanese (ja)
  const ja = <String, String>{
    'place': '場所',
    'language': '言語',
    'max_actions': '最大アクション数',
    'actions': '件',
    'use_ai': 'AI を使用',
    'auto_refresh_on': '自動更新: ON',
    'auto_refresh_off': '自動更新: OFF',
    'severity': '重要度',
    'cache': 'cache',
    'live': 'live',
    'updated': '更新',
    'no_alerts_for': '現在、天気警報はありません:',
    'loading': '読み込み中…',
    'error': 'エラー',
    'refresh': '更新',
  };

  // Hawaiian (haw)
  const haw = <String, String>{
    'place': 'Wahi',
    'language': 'ʻŌlelo',
    'max_actions': 'Nā hana kiʻekiʻe',
    'actions': 'nā hana',
    'use_ai': 'E hoʻohana i AI',
    'auto_refresh_on': 'Hoʻouka hou aunoa: ON',
    'auto_refresh_off': 'Hoʻouka hou aunoa: OFF',
    'severity': 'Kūlana',
    'cache': 'cache',
    'live': 'live',
    'updated': 'Hoʻohou',
    'no_alerts_for': 'ʻAʻohe leka hoʻāla no ke aniau no',
    'loading': 'Ke hoʻouka nei…',
    'error': 'Hewa',
    'refresh': 'Hoʻouka hou',
  };

  Map<String, String> dict;
  switch (lang) {
    case 'vi':
      dict = vi;
      break;
    case 'tl':
      dict = tl;
      break;
    case 'ko':
      dict = ko;
      break;
    case 'ja':
      dict = ja;
      break;
    case 'haw':
      dict = haw;
      break;
    default:
      dict = en;
  }

  return dict[key] ?? en[key] ?? key;
}

String _formatUpdated(DateTime dt) {
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  final ss = dt.second.toString().padLeft(2, '0');
  return '$y-$m-$d $hh:$mm:$ss';
}

class AlertBuddyPage extends ConsumerStatefulWidget {
  const AlertBuddyPage({super.key});

  @override
  ConsumerState<AlertBuddyPage> createState() => _AlertBuddyPageState();
}

class _AlertBuddyPageState extends ConsumerState<AlertBuddyPage> {
  final List<_PlacePreset> presets = const [
    _PlacePreset(name: 'Maui (default)', lat: 20.7984, lon: -156.3319, label: 'Maui'),
    _PlacePreset(name: 'Lahaina', lat: 20.8783, lon: -156.6825, label: 'Lahaina'),
    _PlacePreset(name: 'Kahului', lat: 20.8890, lon: -156.4729, label: 'Kahului'),
    _PlacePreset(name: 'Kihei', lat: 20.7644, lon: -156.4450, label: 'Kihei'),
    _PlacePreset(name: 'Hana', lat: 20.7580, lon: -155.9890, label: 'Hana'),
  ];

  int presetIndex = 0;

  /// Backend languages
  String lang = 'auto'; // auto/en/vi/tl/ko/ja/haw

  int maxActions = 4;
  bool useAi = false;
  bool autoRefresh = true;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
    _applyAutoRefresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _applyAutoRefresh() {
    _timer?.cancel();
    if (!autoRefresh) return;

    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _load(silent: true);
    });
  }

  Future<void> _load({bool silent = false}) async {
    final p = presets[presetIndex];
    await ref.read(alertBuddyControllerProvider.notifier).loadOnce(
          lat: p.lat,
          lon: p.lon,
          placeLabel: p.label,
          lang: lang,
          maxActions: maxActions,
          useAi: useAi,
          silent: silent,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(alertBuddyControllerProvider);
    final autoRefreshLabel = autoRefresh
        ? _t(context, lang, 'auto_refresh_on')
        : _t(context, lang, 'auto_refresh_off');

    return Scaffold(
      appBar: AppBar(
        title: const DebugTapTarget(
          child: Text('Maui Alert Buddy'),
        ),
        actions: [
          IconButton(
            tooltip: _t(context, lang, 'refresh'),
            onPressed: () => _load(silent: false),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _ControlsCard(
              presets: presets,
              presetIndex: presetIndex,
              onPresetChanged: (idx) {
                setState(() => presetIndex = idx);
                _load();
              },
              placeLabel: _t(context, lang, 'place'),
              languageLabel: _t(context, lang, 'language'),
              maxActionsLabel: _t(context, lang, 'max_actions'),
              actionsSuffix: _t(context, lang, 'actions'),
              useAiLabel: _t(context, lang, 'use_ai'),
              autoRefreshLabel: autoRefreshLabel,
              lang: lang,
              onLangChanged: (v) {
                setState(() => lang = v);
                _load();
                _applyAutoRefresh();
              },
              maxActions: maxActions,
              onMaxActionsChanged: (v) {
                setState(() => maxActions = v);
                _load();
              },
              useAi: useAi,
              onUseAiChanged: (v) {
                setState(() => useAi = v);
                _load();
              },
              autoRefresh: autoRefresh,
              onAutoRefreshChanged: (v) {
                setState(() => autoRefresh = v);
                _applyAutoRefresh();
              },
            ),
            const SizedBox(height: 14),
            Expanded(
              child: _ResultCard(
                state: state,
                placeName: presets[presetIndex].label,
                lang: lang,
                onRetry: () => _load(silent: false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.state,
    required this.placeName,
    required this.lang,
    required this.onRetry,
  });

  final AlertBuddyUiState state;
  final String placeName;
  final String lang;
  final VoidCallback onRetry;

  bool _startsWithEnglishNoAlert(String s) {
    return s.toLowerCase().startsWith('no active weather alerts');
  }

  String _compactError(String value) {
    final normalized = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= 180) {
      return normalized;
    }
    return '${normalized.substring(0, 180)}...';
  }

  @override
  Widget build(BuildContext context) {
    if (state.loading && state.data == null) {
      return const Center(
        child: InlineLoadingState(),
      );
    }
    if (state.error != null && state.data == null) {
      return Center(
        child: InlineMessageCard(
          title: 'Unable to load current safety data',
          message:
              'Check your connection and try again. ${_compactError(state.error!)}',
          actionLabel: _t(context, lang, 'refresh'),
          onAction: onRetry,
          icon: Icons.error_outline,
        ),
      );
    }

    final data = state.data;
    if (data == null) {
      return Center(
        child: InlineMessageCard(
          title: 'No data yet',
          message:
              'We have not received a response yet. Please retry in a moment.',
          actionLabel: _t(context, lang, 'refresh'),
          onAction: onRetry,
          icon: Icons.cloud_off,
        ),
      );
    }

    // ✅ NEW SCHEMA: severity/headline are inside alert
    final severity = (data.alert?.severity ?? 'None').trim().isEmpty
        ? 'None'
        : (data.alert?.severity ?? 'None');

    final headline = (data.alert?.headline ?? '').trim();

    // Backend may return english for no-alert; localize that line in UI for ALL langs.
    String oneLiner = data.oneLiner.trim();
    if (severity.toLowerCase() == 'none' &&
        (oneLiner.isEmpty || _startsWithEnglishNoAlert(oneLiner))) {
      oneLiner = '${_t(context, lang, 'no_alerts_for')} $placeName.';
    }

    final updated = DateTime.now();

    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _Pill(
                  label: '${_t(context, lang, 'severity')}: $severity',
                ),
              ),
              const SizedBox(width: 10),
              _Pill(
                label: state.cacheHit ? _t(context, lang, 'cache') : _t(context, lang, 'live'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_t(context, lang, 'updated')}: ${_formatUpdated(updated)}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    oneLiner,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (headline.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      headline,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                  if (data.actions.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    ...data.actions.map(
                      (a) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('•  '),
                            Expanded(child: Text(a)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (state.error != null) ...[
            const SizedBox(height: 10),
            InlineMessageCard(
              title: 'Showing last known data',
              message:
                  'Latest refresh failed. ${_compactError(state.error!)}',
              actionLabel: _t(context, lang, 'refresh'),
              onAction: onRetry,
              icon: Icons.warning_amber_rounded,
            ),
          ],
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Text(label),
    );
  }
}

class _ControlsCard extends StatelessWidget {
  const _ControlsCard({
    required this.presets,
    required this.presetIndex,
    required this.onPresetChanged,
    required this.placeLabel,
    required this.languageLabel,
    required this.maxActionsLabel,
    required this.actionsSuffix,
    required this.useAiLabel,
    required this.autoRefreshLabel,
    required this.lang,
    required this.onLangChanged,
    required this.maxActions,
    required this.onMaxActionsChanged,
    required this.useAi,
    required this.onUseAiChanged,
    required this.autoRefresh,
    required this.onAutoRefreshChanged,
  });

  final List<_PlacePreset> presets;
  final int presetIndex;
  final ValueChanged<int> onPresetChanged;

  final String placeLabel;
  final String languageLabel;
  final String maxActionsLabel;
  final String actionsSuffix;
  final String useAiLabel;
  final String autoRefreshLabel;

  final String lang;
  final ValueChanged<String> onLangChanged;

  final int maxActions;
  final ValueChanged<int> onMaxActionsChanged;

  final bool useAi;
  final ValueChanged<bool> onUseAiChanged;

  final bool autoRefresh;
  final ValueChanged<bool> onAutoRefreshChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(placeLabel, style: Theme.of(context).textTheme.labelLarge),
            DropdownButton<int>(
              value: presetIndex,
              isExpanded: true,
              items: [
                for (int i = 0; i < presets.length; i++)
                  DropdownMenuItem(
                    value: i,
                    child: Text(presets[i].name),
                  ),
              ],
              onChanged: (v) => onPresetChanged(v ?? 0),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(languageLabel, style: Theme.of(context).textTheme.labelLarge),
                      DropdownButton<String>(
                        value: lang,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'auto', child: Text('Auto (device)')),
                          DropdownMenuItem(value: 'en', child: Text('English (en)')),
                          DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt (vi)')),
                          DropdownMenuItem(value: 'tl', child: Text('Filipino/Tagalog (tl)')),
                          DropdownMenuItem(value: 'ko', child: Text('한국어 (ko)')),
                          DropdownMenuItem(value: 'ja', child: Text('日本語 (ja)')),
                          DropdownMenuItem(value: 'haw', child: Text('ʻŌlelo Hawaiʻi (haw)')),
                        ],
                        onChanged: (v) => onLangChanged(v ?? 'auto'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(maxActionsLabel, style: Theme.of(context).textTheme.labelLarge),
                      DropdownButton<int>(
                        value: maxActions,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 2, child: Text('2')),
                          DropdownMenuItem(value: 3, child: Text('3')),
                          DropdownMenuItem(value: 4, child: Text('4')),
                          DropdownMenuItem(value: 5, child: Text('5')),
                        ],
                        onChanged: (v) => onMaxActionsChanged(v ?? 4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Switch(value: useAi, onChanged: onUseAiChanged),
                const SizedBox(width: 8),
                Text(useAiLabel),
                const Spacer(),
                FilledButton.tonal(
                  onPressed: () => onAutoRefreshChanged(!autoRefresh),
                  child: Text(autoRefreshLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlacePreset {
  final String name;
  final double lat;
  final double lon;
  final String label;

  const _PlacePreset({
    required this.name,
    required this.lat,
    required this.lon,
    required this.label,
  });
}
