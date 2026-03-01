import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/error/exceptions.dart';
import '../models/alert_model.dart';

/// Remote data source for NWS (api.weather.gov)
/// Implements <200ms response via Redis caching on the backend aggregator.
class NwsRemoteDataSource {
  final Dio _dio;

  NwsRemoteDataSource({required Dio dio}) : _dio = dio;

  /// GET /v1/alerts/nws — Returns active NWS alerts for Hawaii zone HIZ001+
  Future<List<AlertModel>> fetchActiveAlerts() async {
    try {
      final response = await _dio.get(ApiEndpoints.nwsAlerts);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final features = data['features'] as List<dynamic>? ?? [];

        return features
            .map((f) => AlertModel.fromJson(
                  (f as Map<String, dynamic>)['properties']
                      as Map<String, dynamic>,
                ))
            .toList();
      }

      throw ServerException(
        message: 'NWS returned ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'NWS request failed',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
