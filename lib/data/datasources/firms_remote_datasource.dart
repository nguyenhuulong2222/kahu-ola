import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/error/exceptions.dart';
import '../models/wildfire_model.dart';

/// Remote data source for NASA FIRMS + AirNow + MesoWest
/// Space & Land layers of the "Space to Abyss" matrix.
class FiresRemoteDataSource {
  final Dio _dio;

  FiresRemoteDataSource({required Dio dio}) : _dio = dio;

  // ── NASA FIRMS (LAND layer) ──────────────────────────────────────────────
  /// Fetch active fire hotspots detected by VIIRS/MODIS over Hawaii
  Future<List<WildfireModel>> fetchFireHotspots() async {
    try {
      final response = await _dio.get(ApiEndpoints.nasaFirms);

      if (response.statusCode == 200) {
        final List<dynamic> raw = response.data as List<dynamic>;
        return raw
            .map((item) =>
                WildfireModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw ServerException(
        message: 'NASA FIRMS returned ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'FIRMS request failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ── AirNow (LAND layer) ──────────────────────────────────────────────────
  /// Fetch current AQI data including Vog levels
  Future<List<AirQualityModel>> fetchAirQuality() async {
    try {
      final response = await _dio.get(ApiEndpoints.airNow);

      if (response.statusCode == 200) {
        final List<dynamic> raw = response.data as List<dynamic>;
        return raw
            .map((item) =>
                AirQualityModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw ServerException(
        message: 'AirNow returned ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'AirNow request failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ── MesoWest / RAWS (SUMMIT layer) ───────────────────────────────────────
  /// Fetch Haleakalā wind gusts and fuel moisture (SUMMIT layer)
  Future<Map<String, dynamic>> fetchSummitWindData() async {
    try {
      final response = await _dio.get(ApiEndpoints.mesoWest);

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }

      throw ServerException(
        message: 'MesoWest returned ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'MesoWest request failed',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
