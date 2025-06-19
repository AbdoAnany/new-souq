import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.login(email, password);
        await localDataSource.cacheUser(userModel);
        return Right(userModel);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on CacheException catch (e) {
        // Login succeeded but caching failed - still return success
        final userModel = await remoteDataSource.getCurrentUser();
        if (userModel != null) {
          return Right(userModel);
        }
        return Left(CacheFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final fullName = '$firstName $lastName';
        final userModel = await remoteDataSource.register(email, password, fullName);
        await localDataSource.cacheUser(userModel);
        return Right(userModel);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on CacheException catch (e) {
        // Registration succeeded but caching failed - still return success
        final userModel = await remoteDataSource.getCurrentUser();
        if (userModel != null) {
          return Right(userModel);
        }
        return Left(CacheFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearCache();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      // First try to get from cache
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        // If network is available, also check remote for updates
        if (await networkInfo.isConnected) {
          try {
            final remoteUser = await remoteDataSource.getCurrentUser();
            if (remoteUser != null) {
              await localDataSource.cacheUser(remoteUser);
              return Right(remoteUser);
            }
          } catch (e) {
            // If remote fails, return cached version
            return Right(cachedUser);
          }
        }
        return Right(cachedUser);
      }

      // If no cached user and network is available, check remote
      if (await networkInfo.isConnected) {
        final remoteUser = await remoteDataSource.getCurrentUser();
        if (remoteUser != null) {
          await localDataSource.cacheUser(remoteUser);
        }
        return Right(remoteUser);
      }

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.resetPassword(email);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    // TODO: Implement proper password reset with token
    return const Left(ServerFailure(message: 'Not implemented'));
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // TODO: Implement password change
    return const Left(ServerFailure(message: 'Not implemented'));
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // Get current user to update specific fields
        final currentUser = await localDataSource.getCachedUser();
        if (currentUser == null) {
          return const Left(CacheFailure(message: 'User not found'));
        }

        final updatedUser = UserModel(
          id: userId,
          email: currentUser.email,
          firstName: firstName ?? currentUser.firstName,
          lastName: lastName ?? currentUser.lastName,
          phoneNumber: phoneNumber ?? currentUser.phoneNumber,
          profileImageUrl: profileImageUrl ?? currentUser.profileImageUrl,
          role: currentUser.role,
          createdAt: currentUser.createdAt,
          updatedAt: DateTime.now(),
          isActive: currentUser.isActive,
          isEmailVerified: currentUser.isEmailVerified,
        );

        final result = await remoteDataSource.updateProfile(updatedUser);
        await localDataSource.cacheUser(result);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount({required String userId}) async {
    // TODO: Implement account deletion
    return const Left(ServerFailure(message: 'Not implemented'));
  }

  @override
  Future<Either<Failure, void>> verifyEmail({required String token}) async {
    // TODO: Implement email verification
    return const Left(ServerFailure(message: 'Not implemented'));
  }

  @override
  Future<Either<Failure, void>> resendEmailVerification() async {
    // TODO: Implement resend email verification
    return const Left(ServerFailure(message: 'Not implemented'));
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithGoogle() async {
    // TODO: Implement Google login
    return const Left(ServerFailure(message: 'Not implemented'));
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithFacebook() async {
    // TODO: Implement Facebook login
    return const Left(ServerFailure(message: 'Not implemented'));
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final isLoggedIn = await localDataSource.isUserLoggedIn();
      return Right(isLoggedIn);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Stream<UserEntity?> get authStateStream {
    // TODO: Implement auth state stream
    throw UnimplementedError('Auth state stream not implemented');
  }
}
