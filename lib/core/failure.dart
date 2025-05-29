/// Base class for all failures in the application
abstract class Failure {
  final String message;
  final int? code;
  final dynamic data;

  const Failure(this.message, {this.code, this.data});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Failure &&
        other.message == message &&
        other.code == code &&
        other.data == data;
  }

  @override
  int get hashCode => Object.hash(message, code, data);

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code, super.data});
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code, super.data});
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code, super.data});
}

/// Authentication-related failures
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code, super.data});
}

/// Validation-related failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code, super.data});
}

/// Permission-related failures
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.code, super.data});
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.code, super.data});
}

/// Unexpected failures
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message, {super.code, super.data});
}

/// Timeout failures
class TimeoutFailure extends Failure {
  const TimeoutFailure(super.message, {super.code, super.data});
}

/// Cancelled operation failures
class CancelledFailure extends Failure {
  const CancelledFailure(super.message, {super.code, super.data});
}
