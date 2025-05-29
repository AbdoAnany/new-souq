import '../../core/usecase/usecase.dart';
import '../../core/result.dart';
import '../../core/failure.dart';
import '../repositories/repositories.dart';
import '../entities/user.dart';

class SignInWithEmailAndPassword implements UseCase<User, SignInParams> {
  final AuthRepository repository;
  
  SignInWithEmailAndPassword(this.repository);
  
  @override
  Future<Result<User, Failure>> call(SignInParams params) async {
    return await repository.signInWithEmailAndPassword(
      params.email,
      params.password,
    );
  }
}

class SignUpWithEmailAndPassword implements UseCase<User, SignUpParams> {
  final AuthRepository repository;
  
  SignUpWithEmailAndPassword(this.repository);
  
  @override
  Future<Result<User>> call(SignUpParams params) async {
    return await repository.signUpWithEmailAndPassword(
      params.email,
      params.password,
      params.firstName,
      params.lastName,
    );
  }
}

class SignInWithGoogle implements NoParamsUseCase<Result<User>> {
  final AuthRepository repository;
  
  SignInWithGoogle(this.repository);
  
  @override
  Future<Result<User>> call() async {
    return await repository.signInWithGoogle();
  }
}

class SignOut implements NoParamsUseCase<Result<void>> {
  final AuthRepository repository;
  
  SignOut(this.repository);
  
  @override
  Future<Result<void>> call() async {
    return await repository.signOut();
  }
}

class ResetPassword implements UseCase<Result<void>, String> {
  final AuthRepository repository;
  
  ResetPassword(this.repository);
  
  @override
  Future<Result<void>> call(String email) async {
    return await repository.resetPassword(email);
  }
}

class GetCurrentUser implements NoParamsUseCase<Result<User?>> {
  final AuthRepository repository;
  
  GetCurrentUser(this.repository);
  
  @override
  Future<Result<User?>> call() async {
    return await repository.getCurrentUser();
  }
}

// Parameter classes
class SignInParams {
  final String email;
  final String password;
  
  const SignInParams({
    required this.email,
    required this.password,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SignInParams &&
      runtimeType == other.runtimeType &&
      email == other.email &&
      password == other.password;
  
  @override
  int get hashCode => email.hashCode ^ password.hashCode;
}

class SignUpParams {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  
  const SignUpParams({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SignUpParams &&
      runtimeType == other.runtimeType &&
      email == other.email &&
      password == other.password &&
      firstName == other.firstName &&
      lastName == other.lastName;
  
  @override
  int get hashCode =>
      email.hashCode ^
      password.hashCode ^
      firstName.hashCode ^
      lastName.hashCode;
}
