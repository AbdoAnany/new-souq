// Custom exceptions for different error scenarios
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
}

class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
}

class PermissionException implements Exception {
  final String message;
  const PermissionException(this.message);
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException(this.message);
}

class UnexpectedException implements Exception {
  final String message;
  const UnexpectedException(this.message);
}
