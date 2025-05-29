/// Base class for all errors in the application
abstract class AppError implements Exception {
  final String message;
  final String? code;
  final dynamic data;

  const AppError(this.message, {this.code, this.data});

  @override
  String toString() => 'AppError: $message';
}

/// Network related errors
class NetworkError extends AppError {
  const NetworkError(super.message, {super.code, super.data});
}

/// Authentication related errors
class AuthError extends AppError {
  const AuthError(super.message, {super.code, super.data});
}

/// Validation related errors
class ValidationError extends AppError {
  const ValidationError(super.message, {super.code, super.data});
}

/// Server related errors
class ServerError extends AppError {
  const ServerError(super.message, {super.code, super.data});
}

/// Cache related errors
class CacheError extends AppError {
  const CacheError(super.message, {super.code, super.data});
}

/// Permission related errors
class PermissionError extends AppError {
  const PermissionError(super.message, {super.code, super.data});
}

/// Timeout related errors
class TimeoutError extends AppError {
  const TimeoutError(super.message, {super.code, super.data});
}

/// Generic application errors
class GenericError extends AppError {
  const GenericError(super.message, {super.code, super.data});
}

/// Error handler utility class
class ErrorHandler {
  static AppError handleError(dynamic error) {
    if (error is AppError) {
      return error;
    }
    
    // Handle different types of errors
    final errorMessage = error.toString();
    
    if (errorMessage.contains('network') || errorMessage.contains('connection')) {
      return NetworkError(errorMessage);
    }
    
    if (errorMessage.contains('auth') || errorMessage.contains('unauthorized')) {
      return AuthError(errorMessage);
    }
    
    if (errorMessage.contains('timeout')) {
      return TimeoutError(errorMessage);
    }
    
    if (errorMessage.contains('server') || errorMessage.contains('500')) {
      return ServerError(errorMessage);
    }
    
    return GenericError(errorMessage);
  }
  
  static String getLocalizedMessage(AppError error) {
    // Return user-friendly error messages
    switch (error.runtimeType) {
      case const (NetworkError):
        return 'Please check your internet connection and try again.';
      case const (AuthError):
        return 'Authentication failed. Please login again.';
      case const (ValidationError):
        return error.message;
      case const (ServerError):
        return 'Server error occurred. Please try again later.';
      case const (TimeoutError):
        return 'Request timed out. Please try again.';
      case const (PermissionError):
        return 'Permission denied. Please check your permissions.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
