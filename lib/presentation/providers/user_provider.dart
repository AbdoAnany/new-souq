import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/user_usecases.dart';
import '../../data/providers/repository_providers.dart';
import '../../core/result.dart';

// User state
class UserState {
  final User? currentUser;
  final List<User> users;
  final bool isLoading;
  final String? error;

  const UserState({
    this.currentUser,
    this.users = const [],
    this.isLoading = false,
    this.error,
  });

  UserState copyWith({
    User? currentUser,
    List<User>? users,
    bool? isLoading,
    String? error,
  }) {
    return UserState(
      currentUser: currentUser ?? this.currentUser,
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// User provider
class UserNotifier extends StateNotifier<UserState> {
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final UpdateUserUseCase _updateUserUseCase;
  final GetUsersUseCase _getUsersUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;

  UserNotifier({
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required UpdateUserUseCase updateUserUseCase,
    required GetUsersUseCase getUsersUseCase,
    required UpdateUserProfileUseCase updateUserProfileUseCase,
  })  : _getCurrentUserUseCase = getCurrentUserUseCase,
        _updateUserUseCase = updateUserUseCase,
        _getUsersUseCase = getUsersUseCase,
        _updateUserProfileUseCase = updateUserProfileUseCase,
        super(const UserState());

  // Get current user
  Future<void> getCurrentUser() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getCurrentUserUseCase(NoParams());
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (user) => state = state.copyWith(
        isLoading: false,
        currentUser: user,
        error: null,
      ),
    );
  }

  // Update user
  Future<Result<User, Failure>> updateUser(User user) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _updateUserUseCase(UpdateUserParams(user: user));

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (updatedUser) => state = state.copyWith(
        isLoading: false,
        currentUser: updatedUser,
        error: null,
      ),
    );

    return result;
  }

  // Get users (for admin)
  Future<void> getUsers({
    int? limit,
    String? startAfter,
    String? searchQuery,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getUsersUseCase(GetUsersParams(
      limit: limit,
      startAfter: startAfter,
      searchQuery: searchQuery,
    ));

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (users) => state = state.copyWith(
        isLoading: false,
        users: users,
        error: null,
      ),
    );
  }

  // Update user profile
  Future<Result<User, Failure>> updateUserProfile({
    String? name,
    String? email,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
  }) async {
    if (state.currentUser == null) {
      state = state.copyWith(error: 'No current user');
      return Result.failure(const Failure('No current user'));
    }

    state = state.copyWith(isLoading: true, error: null);

    final result = await _updateUserProfileUseCase(UpdateUserProfileParams(
      userId: state.currentUser!.id,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      address: address,
      profileImageUrl: profileImageUrl,
    ));

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (updatedUser) => state = state.copyWith(
        isLoading: false,
        currentUser: updatedUser,
        error: null,
      ),
    );

    return result;
  }

  // Set current user (for auth provider integration)
  void setCurrentUser(User? user) {
    state = state.copyWith(currentUser: user);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Clear users
  void clearUsers() {
    state = state.copyWith(users: []);
  }

  // Logout
  void logout() {
    state = const UserState();
  }
}

// Provider definitions
final userNotifierProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  
  return UserNotifier(
    getCurrentUserUseCase: GetCurrentUserUseCase(userRepository),
    updateUserUseCase: UpdateUserUseCase(userRepository),
    getUsersUseCase: GetUsersUseCase(userRepository),
    updateUserProfileUseCase: UpdateUserProfileUseCase(userRepository),
  );
});

// Convenience providers
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(userNotifierProvider).currentUser;
});

final usersProvider = Provider<List<User>>((ref) {
  return ref.watch(userNotifierProvider).users;
});

final isUserLoadingProvider = Provider<bool>((ref) {
  return ref.watch(userNotifierProvider).isLoading;
});

final userErrorProvider = Provider<String?>((ref) {
  return ref.watch(userNotifierProvider).error;
});

// User profile provider for easy access to profile data
final userProfileProvider = Provider<Map<String, String?>>((ref) {
  final user = ref.watch(currentUserProvider);
  return {
    'name': user?.name,
    'email': user?.email,
    'phoneNumber': user?.phoneNumber,
    'address': user?.address,
    'profileImageUrl': user?.profileImageUrl,
  };
});
