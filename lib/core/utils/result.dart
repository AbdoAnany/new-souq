/// Represents the result of an operation that can either succeed or fail
abstract class Result<T> {
  const Result();
  
  /// Returns true if the result is a success
  bool get isSuccess => this is Success<T>;
  
  /// Returns true if the result is a failure
  bool get isFailure => this is Failure<T>;
  
  /// Returns the data if success, null otherwise
  T? get data => isSuccess ? (this as Success<T>).data : null;
  
  /// Returns the error if failure, null otherwise
  Exception? get error => isFailure ? (this as Failure<T>).error : null;
  
  /// Transform the result with a mapper function
  Result<R> map<R>(R Function(T) mapper) {
    if (isSuccess) {
      try {
        return Success(mapper((this as Success<T>).data));
      } catch (e) {
        return Failure(e is Exception ? e : Exception(e.toString()));
      }
    }
    return Failure((this as Failure<T>).error);
  }
  
  /// Handle both success and failure cases
  R when<R>({
    required R Function(T data) success,
    required R Function(Exception error) failure,
  }) {
    if (isSuccess) {
      return success((this as Success<T>).data);
    }
    return failure((this as Failure<T>).error);
  }
  
  /// Execute a function only if the result is successful
  Result<T> onSuccess(void Function(T data) action) {
    if (isSuccess) {
      action((this as Success<T>).data);
    }
    return this;
  }
  
  /// Execute a function only if the result is a failure
  Result<T> onFailure(void Function(Exception error) action) {
    if (isFailure) {
      action((this as Failure<T>).error);
    }
    return this;
  }
}

/// Represents a successful result
class Success<T> extends Result<T> {
  final T data;
  
  const Success(this.data);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success &&
      runtimeType == other.runtimeType &&
      data == other.data;
  
  @override
  int get hashCode => data.hashCode;
  
  @override
  String toString() => 'Success(data: $data)';
}

/// Represents a failed result
class Failure<T> extends Result<T> {
  final Exception error;
  
  const Failure(this.error);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
      runtimeType == other.runtimeType &&
      error == other.error;
  
  @override
  int get hashCode => error.hashCode;
  
  @override
  String toString() => 'Failure(error: $error)';
}

/// Extension methods for easier Result creation
extension ResultExtensions<T> on T {
  /// Wrap a value in a Success result
  Result<T> get success => Success(this);
}

extension ExceptionExtensions on Exception {
  /// Wrap an exception in a Failure result
  Result<T> failure<T>() => Failure<T>(this);
}

/// Utility functions for Result
class ResultUtils {
  /// Execute an async operation and return a Result
  static Future<Result<T>> tryAsync<T>(Future<T> Function() operation) async {
    try {
      final result = await operation();
      return Success(result);
    } catch (e) {
      return Failure(e is Exception ? e : Exception(e.toString()));
    }
  }
  
  /// Execute a synchronous operation and return a Result
  static Result<T> trySync<T>(T Function() operation) {
    try {
      final result = operation();
      return Success(result);
    } catch (e) {
      return Failure(e is Exception ? e : Exception(e.toString()));
    }
  }
  
  /// Combine multiple results into one
  static Result<List<T>> combine<T>(List<Result<T>> results) {
    final List<T> data = [];
    
    for (final result in results) {
      if (result.isFailure) {
        return Failure(result.error!);
      }
      data.add(result.data!);
    }
    
    return Success(data);
  }
}
