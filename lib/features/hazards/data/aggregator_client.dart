import 'package:dio/dio.dart';

import '../../../core/config/env.dart';
import '../../../core/diagnostics/diagnostics_store.dart';
import '../../../core/network/api_exceptions.dart';
import 'models/fire_signal_dto.dart';
import 'models/perimeter_dto.dart';
import 'models/smoke_signal_dto.dart';

class AggregatorClient {
  AggregatorClient({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<FireSignalDto> fetchFireSignals() async {
    final envelope = await _requestEnvelope(
      endpoint: HazardEndpoint.fire,
      path: '/hazards/fire',
    );
    return FireSignalDto.fromJson(envelope);
  }

  Future<SmokeSignalDto> fetchSmokeSignals() async {
    final envelope = await _requestEnvelope(
      endpoint: HazardEndpoint.smoke,
      path: '/hazards/smoke',
    );
    return SmokeSignalDto.fromJson(envelope);
  }

  Future<PerimeterDto> fetchPerimeters() async {
    final envelope = await _requestEnvelope(
      endpoint: HazardEndpoint.perimeter,
      path: '/hazards/perimeters',
    );
    return PerimeterDto.fromJson(envelope);
  }

  Future<Map<String, dynamic>> _requestEnvelope({
    required HazardEndpoint endpoint,
    required String path,
  }) async {
    _dio.options.baseUrl = Env.aggregatorBaseUrl;

    const maxAttempts = 3;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await _dio.get<Object>(
          path,
          queryParameters: const <String, String>{'region': 'maui'},
        );
        return _castEnvelope(response.data, endpoint);
      } on DioException catch (error) {
        final statusCode = error.response?.statusCode;
        if (statusCode == 429) {
          throw const RateLimitException(
            'Aggregator rate limit active',
            cooldownSeconds: 60,
          );
        }

        if (_isRetryable(error) && attempt < maxAttempts) {
          await Future<void>.delayed(Duration(seconds: attempt));
          continue;
        }

        throw NetworkException(
          'Aggregator request failed for $path',
          statusCode: statusCode,
        );
      }
    }

    throw NetworkException(
      'Aggregator request failed after retries for ${endpoint.name}',
    );
  }

  Map<String, dynamic> _castEnvelope(Object? data, HazardEndpoint endpoint) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return data.cast<String, dynamic>();
    }
    throw ParseException('Invalid response payload for ${endpoint.name}');
  }

  bool _isRetryable(DioException error) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout;
  }
}
