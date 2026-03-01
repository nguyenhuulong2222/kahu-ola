import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/error/exceptions.dart';
import '../models/ocean_model.dart';

/// Remote data source for PacIOOS, ALOHA, and USGS
/// Coast & Abyss layers of the "Space to Abyss" matrix.
class PacioosRemoteDataSource {
  final Dio _dio;

  PacioosRemoteDataSource({required Dio dio}) : _dio = dio;

  // ── PacIOOS Ocean (COAST layer) ──────────────────────────────────────────
  /// Offshore currents, tidal data, wave conditions
  Future<List<OceanModel>> fetchOceanConditions() async {
    try {
      final response = await _dio.get(ApiEndpoints.pacioosCoast);

      if (response.statusCode == 200) {
        final List<dynamic> raw = response.data as List<dynamic>;
        return raw
            .map((item) => OceanModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw ServerException(
        message: 'PacIOOS coast returned ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'PacIOOS coast request failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ── ALOHA Deep Pressure (ABYSS layer) ────────────────────────────────────
  /// Deep-sea pressure at 4,800 m for tsunami early-warning
  Future<List<DeepSeaPressureModel>> fetchDeepSeaPressure() async {
    try {
      final response = await _dio.get(ApiEndpoints.alohaDeep);

      if (response.statusCode == 200) {
        final List<dynamic> raw = response.data as List<dynamic>;
        return raw
            .map((item) =>
                DeepSeaPressureModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw ServerException(
        message: 'ALOHA returned ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'ALOHA request failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ── USGS Flood (COAST layer) ─────────────────────────────────────────────
  /// Flash flood warnings from USGS stream gauges
  Future<Map<String, dynamic>> fetchFloodWarnings() async {
    try {
      final response = await _dio.get(ApiEndpoints.usgsFlood);

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }

      throw ServerException(
        message: 'USGS returned ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'USGS request failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ── GOES-West (SPACE layer) ───────────────────────────────────────────────
  /// Satellite thermal anomaly data (wildfire detection from orbit)
  Future<Map<String, dynamic>> fetchGoesWest() async {
    try {
      final response = await _dio.get(ApiEndpoints.goesWest);

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }

      throw ServerException(
        message: 'GOES-West returned ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'GOES-West request failed',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
