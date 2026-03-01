import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:kahu_ola/core/constants/app_constants.dart';
import 'package:latlong2/latlong.dart';

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  static const LatLng _mauiCountyCenter = LatLng(20.8400, -156.6600);
  static const double _fireAlertRadiusKm = 120;
  static const int _maxResolvedLocations = 3;
  static const Map<String, LatLng> _islandCenters = {
    'Maui': LatLng(20.7984, -156.3319),
    'Lanai': LatLng(20.8268, -156.9210),
    'Molokai': LatLng(21.1440, -157.0240),
  };

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      responseType: ResponseType.plain,
    ),
  );
  final Distance _distance = const Distance();
  final MapController _mapController = MapController();

  List<LatLng> _firePoints = const [];
  List<String> _fireLocations = const [];
  String? _lastSlackAlertSignature;
  bool _didAttemptSlackGreeting = false;
  bool _isLoading = true;
  String? _errorMessage;
  DateTime? _lastUpdatedAt;

  @override
  void initState() {
    super.initState();
    _sendSlackStartupGreeting();
    _fetchFireData();
  }

  @override
  void dispose() {
    _dio.close(force: true);
    super.dispose();
  }

  String get _nasaFirmsUrl {
    final now = DateTime.now().toUtc();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    return 'https://firms.modaps.eosdis.nasa.gov/api/area/csv/'
        'a5b75d643ba4525130d33fea0ae1487c/MODIS_NRT/world/1/$year-$month-$day';
  }

  Future<void> _fetchFireData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _dio.get<String>(_nasaFirmsUrl);
      final csvText = response.data ?? '';
      final points = _parseFirePointsFromCsv(csvText)
          .where(
            (point) =>
                _distance.as(LengthUnit.Kilometer, _mauiCountyCenter, point) <=
                _fireAlertRadiusKm,
          )
          .toList();
      final fireLocations = await _resolveFireLocations(points);

      if (!mounted) return;
      setState(() {
        _firePoints = points;
        _fireLocations = fireLocations;
        _isLoading = false;
        _lastUpdatedAt = DateTime.now();
      });
      _maybeSendSlackHotspotAlert(points, fireLocations);
    } on DioException {
      if (!mounted) return;
      setState(() {
        _firePoints = const [];
        _fireLocations = const [];
        _isLoading = false;
        _errorMessage =
            'Unable to load the latest NASA FIRMS fire data. Please try again.';
        _lastUpdatedAt = DateTime.now();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _firePoints = const [];
        _fireLocations = const [];
        _isLoading = false;
        _errorMessage = 'An unexpected error occurred while loading fire data.';
        _lastUpdatedAt = DateTime.now();
      });
    }
  }

  Future<void> _sendSlackStartupGreeting() async {
    if (_didAttemptSlackGreeting || AppConstants.slackWebhookUrl.isEmpty) {
      return;
    }

    _didAttemptSlackGreeting = true;
    await _postSlackMessage(
      '🚀 Kahu Ola Fire Surveillance is LIVE for Maui, Lanai, and Molokai. Monitoring 120km radius.',
      channel: AppConstants.slackAlertsChannel,
    );
  }

  Future<void> _maybeSendSlackHotspotAlert(
    List<LatLng> points,
    List<String> fireLocations,
  ) async {
    if (AppConstants.slackWebhookUrl.isEmpty || points.isEmpty) return;

    final alertLocations = fireLocations.isEmpty
        ? points.take(_maxResolvedLocations).map(_fallbackLocationLabel).toList()
        : fireLocations;
    final alertSignature = '${points.length}|${alertLocations.join('|')}';
    if (alertSignature == _lastSlackAlertSignature) return;

    final message = StringBuffer()
      ..writeln('ACTIVE FIRE ALERT - MAUI COUNTY')
      ..writeln('Detected hotspots: ${points.length}.')
      ..write('Impacted islands and areas: ${alertLocations.join(', ')}');

    final didSend = await _postSlackMessage(
      message.toString(),
      channel: AppConstants.slackAlertsChannel,
    );
    if (didSend) {
      _lastSlackAlertSignature = alertSignature;
    }
  }

  Future<bool> _postSlackMessage(
    String text, {
    String? channel,
  }) async {
    if (AppConstants.slackWebhookUrl.isEmpty) return false;

    try {
      final payload = <String, dynamic>{'text': text};
      if (channel != null && channel.isNotEmpty) {
        payload['channel'] = channel;
      }

      final response = await _dio.post<String>(
        AppConstants.slackWebhookUrl,
        data: payload,
        options: Options(
          contentType: Headers.jsonContentType,
          responseType: ResponseType.plain,
        ),
      );
      return response.statusCode != null && response.statusCode! >= 200 &&
          response.statusCode! < 300;
    } on DioException {
      return false;
    }
  }

  Future<List<String>> _resolveFireLocations(List<LatLng> points) async {
    if (points.isEmpty) return const [];

    final samplePoints = points.take(_maxResolvedLocations).toList();
    final labels = await Future.wait(samplePoints.map(_reverseGeocodePoint));
    final uniqueLabels = <String>{};

    for (final label in labels) {
      if (label != null && label.isNotEmpty) {
        uniqueLabels.add(label);
      }
    }

    if (uniqueLabels.isNotEmpty) {
      return uniqueLabels.toList();
    }

    return samplePoints.map(_fallbackLocationLabel).toList();
  }

  Future<String?> _reverseGeocodePoint(LatLng point) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );
      if (placemarks.isEmpty) return null;

      final placemark = placemarks.first;
      final islandName = _identifyIsland(point, placemark);
      final area = placemark.locality ??
          placemark.subLocality ??
          placemark.subAdministrativeArea ??
          placemark.administrativeArea;
      if (area == null || area.isEmpty) return islandName;

      if (area.toLowerCase().contains(islandName.toLowerCase())) {
        return area;
      }

      return '$area, $islandName';
    } catch (_) {
      return null;
    }
  }

  String _identifyIsland(LatLng point, Placemark placemark) {
    final placemarkValues = <String?>[
      placemark.name,
      placemark.locality,
      placemark.subLocality,
      placemark.subAdministrativeArea,
      placemark.administrativeArea,
      placemark.thoroughfare,
    ];

    for (final value in placemarkValues) {
      final normalized = value?.toLowerCase() ?? '';
      if (normalized.contains('lanai')) {
        return 'Lanai';
      }
      if (normalized.contains('molokai')) {
        return 'Molokai';
      }
      if (normalized.contains('maui') && !normalized.contains('county')) {
        return 'Maui';
      }
    }

    return _nearestIsland(point);
  }

  String _nearestIsland(LatLng point) {
    var nearestIsland = 'Maui';
    var nearestDistance = double.infinity;

    for (final entry in _islandCenters.entries) {
      final islandDistance = _distance.as(
        LengthUnit.Kilometer,
        point,
        entry.value,
      );
      if (islandDistance < nearestDistance) {
        nearestDistance = islandDistance;
        nearestIsland = entry.key;
      }
    }

    return nearestIsland;
  }

  String _fallbackLocationLabel(LatLng point) {
    return '${_nearestIsland(point)} near '
        '${point.latitude.toStringAsFixed(3)}, '
        '${point.longitude.toStringAsFixed(3)}';
  }

  List<LatLng> _parseFirePointsFromCsv(String csvText) {
    final lines = const LineSplitter()
        .convert(csvText)
        .where((line) => line.trim().isNotEmpty)
        .toList();

    if (lines.length < 2) return const [];

    final headers = _splitCsvLine(lines.first);
    final latIndex = headers.indexOf('latitude');
    final lonIndex = headers.indexOf('longitude');
    if (latIndex < 0 || lonIndex < 0) return const [];

    final points = <LatLng>[];
    for (final line in lines.skip(1)) {
      final columns = _splitCsvLine(line);
      if (columns.length <= latIndex || columns.length <= lonIndex) {
        continue;
      }

      final lat = double.tryParse(columns[latIndex]);
      final lon = double.tryParse(columns[lonIndex]);
      if (lat != null && lon != null) {
        points.add(LatLng(lat, lon));
      }
    }
    return points;
  }

  List<String> _splitCsvLine(String line) {
    final result = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }

    result.add(buffer.toString().trim());
    return result;
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '--:--:--';

    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }

  Widget _buildStatusCard() {
    final theme = Theme.of(context);
    final hasActiveFires = _firePoints.isNotEmpty;

    late final Color backgroundColor;
    late final IconData icon;
    late final String title;
    late final String message;

    if (_errorMessage != null) {
      backgroundColor = Colors.orange.shade900;
      icon = Icons.warning_amber_rounded;
      title = 'Fire Data Unavailable';
      message = _errorMessage!;
    } else if (_isLoading) {
      backgroundColor = Colors.blueGrey.shade900;
      icon = Icons.sync;
      title = 'Checking Maui County Fire Activity';
      message = 'Loading the latest NASA FIRMS hotspot scan for Maui County.';
    } else if (hasActiveFires) {
      backgroundColor = Colors.red.shade900;
      icon = Icons.local_fire_department;
      title = 'ACTIVE FIRE ALERT - MAUI COUNTY';

      final areaSummary = _fireLocations.isEmpty
          ? 'Hotspots detected within ${_fireAlertRadiusKm.toInt()} km of Maui County.'
          : 'Impacted islands and areas: ${_fireLocations.join(', ')}';
      message = '$areaSummary\nDetected hotspots: ${_firePoints.length}.';
    } else {
      backgroundColor = Colors.green.shade800;
      icon = Icons.verified_outlined;
      title = 'No Nearby Fire Hotspots Detected';
      message =
          'The latest NASA FIRMS scan shows no hotspots within ${_fireAlertRadiusKm.toInt()} km of Maui County.';
    }

    return Card(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'KAHU OLA - The Guardian of Life',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
            initialCenter: _mauiCountyCenter,
            initialZoom: 9,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://api.mapbox.com/styles/v1/${AppConstants.mapboxStyle}'
                  '/tiles/{z}/{x}/{y}?access_token=${AppConstants.mapboxToken}',
            ),
            MarkerLayer(
              markers: _firePoints
                  .map(
                    (point) => Marker(
                      point: point,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.local_fire_department,
                        color: Colors.red,
                        size: 30,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 8, 15, 0),
            child: Align(
              alignment: Alignment.topCenter,
              child: _buildBrandBanner(),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 68, 15, 0),
            child: _buildStatusCard(),
          ),
        ),
        if (_isLoading)
          const Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: EdgeInsets.all(14),
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ),
        Positioned(
          bottom: 15,
          left: 15,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              'NASA Satellite Data updated at: ${_formatTime(_lastUpdatedAt)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
              ),
            ),
          ),
        ),
        Positioned(
          right: 15,
          bottom: 15,
          child: FloatingActionButton.small(
            heroTag: 'refreshFireData',
            onPressed: _isLoading ? null : () => _fetchFireData(),
            backgroundColor: Colors.black87,
            foregroundColor: Colors.white,
            child: const Icon(Icons.refresh),
          ),
        ),
      ],
    );
  }
}
