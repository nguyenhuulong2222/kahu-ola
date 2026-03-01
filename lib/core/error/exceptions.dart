/// Thrown by remote data sources when server returns error
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// Thrown when local cache is unavailable or corrupted
class CacheException implements Exception {
  final String message;
  const CacheException({this.message = 'Cache unavailable'});

  @override
  String toString() => 'CacheException: $message';
}

/// Thrown when JSON parsing fails
class ParseException implements Exception {
  final String message;
  const ParseException({required this.message});

  @override
  String toString() => 'ParseException: $message';
}
