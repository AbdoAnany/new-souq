import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

// Base use case for all business logic
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// For use cases that don't require parameters
class NoParams {
  const NoParams();
}
