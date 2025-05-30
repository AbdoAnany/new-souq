import '../../core/result.dart';
import '../../core/failure.dart';
import '../../core/usecase/usecase.dart';
import '../repositories/repositories.dart';
import '../entities/user.dart';

/// Use case for getting current user
class GetCurrentUserUseCase implements NoParamsUseCase<User?> {
  final UserRepository _repository;

  GetCurrentUserUseCase(this._repository);

  @override
  Future<Result<User?, Failure>> call() async {
    return await _repository.getCurrentUser();
  }
}

/// Use case for getting user by ID
class GetUserByIdUseCase implements UseCase<User, String> {
  final UserRepository _repository;

  GetUserByIdUseCase(this._repository);

  @override
  Future<Result<User, Failure>> call(String userId) async {
    return await _repository.getUserById(userId);
  }
}

/// Use case for updating user
class UpdateUserUseCase implements UseCase<User, User> {
  final UserRepository _repository;

  UpdateUserUseCase(this._repository);

  @override
  Future<Result<User, Failure>> call(User user) async {
    // Validate user data
    if (user.email.isEmpty) {
      return Result.failure(const ValidationFailure('Email is required'));
    }

    if (user.name.isEmpty) {
      return Result.failure(const ValidationFailure('Name is required'));
    }

    if (!_isValidEmail(user.email)) {
      return Result.failure(const ValidationFailure('Please enter a valid email address'));
    }

    return await _repository.updateUser(user);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

/// Use case for deleting user
class DeleteUserUseCase implements UseCase<void, String> {
  final UserRepository _repository;

  DeleteUserUseCase(this._repository);

  @override
  Future<Result<void, Failure>> call(String userId) async {
    return await _repository.deleteUser(userId);
  }
}

/// Parameters for getting users with filters
class GetUsersParams {
  final int? page;
  final int? limit;
  final String? search;

  const GetUsersParams({
    this.page,
    this.limit,
    this.search,
  });
}

/// Use case for getting users (admin)
class GetUsersUseCase implements UseCase<List<User>, GetUsersParams> {
  final UserRepository _repository;

  GetUsersUseCase(this._repository);

  @override
  Future<Result<List<User>, Failure>> call(GetUsersParams params) async {
    return await _repository.getUsers(
      startAfter: params.page.toString(),
      limit: params.limit,
      searchQuery: params.search,
    );
  }
}

/// Parameters for updating user profile
class UpdateUserProfileParams {
  final String userId;
  final String firstName;
  final String lastName;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? profileImageUrl;

  const UpdateUserProfileParams({
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.dateOfBirth,
    this.profileImageUrl,
  });
}

/// Use case for updating user profile
class UpdateUserProfileUseCase implements UseCase<User, UpdateUserProfileParams> {
  final UserRepository _repository;

  UpdateUserProfileUseCase(this._repository);

  @override
  Future<Result<User, Failure>> call(UpdateUserProfileParams params) async {
    if (params.firstName.isEmpty) {
      return Result.failure(const ValidationFailure('First name is required'));
    }

    if (params.lastName.isEmpty) {
      return Result.failure(const ValidationFailure('Last name is required'));
    }

    // Get current user first
    final currentUserResult = await _repository.getUserById(params.userId);
    if (currentUserResult.isFailure) {
      return Result.failure(currentUserResult.failure);
    }

    final currentUser = currentUserResult.value;

    // Update user with new profile data
    final updatedUser = currentUser.copyWith(
      firstName: params.firstName,
      lastName: params.lastName,
      phone: params.phone,
      dateOfBirth: params.dateOfBirth,
      profileImageUrl: params.profileImageUrl,
      updatedAt: DateTime.now(),
    );

    return await _repository.updateUser(updatedUser);
  }
}
