class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(super.message, {this.statusCode});

  final int? statusCode;
}

class ParseException extends AppException {
  const ParseException(super.message);
}

class StaleDataException extends AppException {
  const StaleDataException(super.message);
}

class RateLimitException extends AppException {
  const RateLimitException(super.message, {this.cooldownSeconds = 60});

  final int cooldownSeconds;
}
