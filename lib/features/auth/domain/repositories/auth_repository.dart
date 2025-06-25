import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

// Auth repository interface - defines contracts for auth operations
abstract class AuthRepository {
  // Authentication methods
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, UserEntity?>> getCurrentUser();

  Future<Either<Failure, void>> forgotPassword({required String email});

  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<Either<Failure, UserEntity>> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
  });

  Future<Either<Failure, void>> deleteAccount({required String userId});

  Future<Either<Failure, void>> verifyEmail({required String token});

  Future<Either<Failure, void>> resendEmailVerification();

  // Social authentication
  Future<Either<Failure, UserEntity>> loginWithGoogle();

  Future<Either<Failure, UserEntity>> loginWithFacebook();

  // Check authentication status
  Future<Either<Failure, bool>> isLoggedIn();

  // Auth state stream
  Stream<UserEntity?> get authStateStream;
}
