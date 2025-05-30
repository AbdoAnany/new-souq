import 'failure.dart';

/// A Result type that represents either a successful value or a failure
abstract class Result<T, F> {
  const Result();
  /// Returns true if this is a Success
  bool get isSuccess => this is Success<T, F>;
  /// Returns true if this is a Failure
  bool get isFailure => this is ResultFailure<T, F>;

  /// Fold the result into a single value
  R fold<R>(R Function(F failure) onFailure, R Function(T success) onSuccess) {
    if (this is Success<T, F>) {
      return onSuccess((this as Success<T, F>).value);
    } else {
      return onFailure((this as ResultFailure<T, F>).failure);
    }
  }

  /// Map the success value
  Result<R, F> map<R>(R Function(T) mapper) {
    if (this is Success<T, F>) {
      try {
        return Result.success(mapper((this as Success<T, F>).value));
      } catch (e) {
        return Result.failure(e as F);
      }
    } else {
      return Result.failure((this as ResultFailure<T, F>).failure);
    }
  }

  /// FlatMap operation
  Result<R, F> flatMap<R>(Result<R, F> Function(T) mapper) {
    if (this is Success<T, F>) {
      return mapper((this as Success<T, F>).value);
    } else {
      return Result.failure((this as ResultFailure<T, F>).failure);
    }
  }

  /// Create a successful result
  static Result<T, F> success<T, F>(T value) => Success(value);

  /// Create a failed result
  static Result<T, F> failure<T, F>(F failure) => ResultFailure(failure);
}

/// Success case of Result
class Success<T, F> extends Result<T, F> {
  final T value;

  const Success(this.value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Success<T, F> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// Failure case of Result
class ResultFailure<T, F> extends Result<T, F> {
  final F failure;

  const ResultFailure(this.failure);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ResultFailure<T, F> && other.failure == failure;
  }

  @override
  int get hashCode => failure.hashCode;
  @override
  String toString() => 'Failure($failure)';
}

/// Type aliases for common Result types
typedef ResultVoid = Result<void, Failure>;
typedef ResultString = Result<String, Failure>;
typedef ResultInt = Result<int, Failure>;
typedef ResultBool = Result<bool, Failure>;
