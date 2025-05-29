import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/result.dart';
import '../../data/providers/repository_providers.dart';
import '../../domain/repositories/repositories.dart';
import '../../models/user.dart';

/// Authentication state for managing user authentication
class AuthState {
  final User? user;
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
    );
  }

  bool get hasError => error != null;
  bool get hasUser => user != null;
}

/// Authentication provider for managing auth state and operations
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState()) {
    _initAuth();
  }

  /// Initialize authentication state
  void _initAuth() {
    // Listen to auth state changes
    _authRepository.authStateChanges.listen(
      (user) {
        if (!mounted) return;
        state = state.copyWith(
          user: user,
          isAuthenticated: user != null,
          isLoading: false,
        );
      },
      onError: (error) {
        if (!mounted) return;
        state = state.copyWith(
          error: error.toString(),
          isLoading: false,
        );
        if (kDebugMode) {
          print('Auth state change error: $error');
        }
      },
    );

    // Get current user
    _getCurrentUser();
  }

  /// Get current user
  Future<void> _getCurrentUser() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.getCurrentUser();

    result.fold(
      onSuccess: (user) {
        state = state.copyWith(
          user: user,
          isAuthenticated: user != null,
          isLoading: false,
        );
      },
      onFailure: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.toString(),
        );
        if (kDebugMode) {
          print('Error getting current user: $error');
        }
      },
    );
  }

  /// Sign in with email and password
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (state.isLoading) return false;

    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.signInWithEmailAndPassword(email, password);

    return result.fold(
      onSuccess: (user) {
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
        return true;
      },
      onFailure: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.toString(),
        );
        if (kDebugMode) {
          print('Sign in error: $error');
        }
        return false;
      },
    );
  }

  /// Sign up with email and password
  Future<bool> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    if (state.isLoading) return false;

    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.signUpWithEmailAndPassword(
      email,
      password,
      firstName,
      lastName,
    );

    return result.fold(
      onSuccess: (user) {
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
        return true;
      },
      onFailure: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.toString(),
        );
        if (kDebugMode) {
          print('Sign up error: $error');
        }
        return false;
      },
    );
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    if (state.isLoading) return false;

    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.signInWithGoogle();

    return result.fold(
      onSuccess: (user) {
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
        return true;
      },
      onFailure: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.toString(),
        );
        if (kDebugMode) {
          print('Google sign in error: $error');
        }
        return false;
      },
    );
  }

  /// Sign out
  Future<bool> signOut() async {
    if (state.isLoading) return false;

    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.signOut();

    return result.fold(
      onSuccess: (_) {
        state = state.copyWith(
          user: null,
          isAuthenticated: false,
          isLoading: false,
        );
        return true;
      },
      onFailure: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.toString(),
        );
        if (kDebugMode) {
          print('Sign out error: $error');
        }
        return false;
      },
    );
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    if (state.isLoading) return false;

    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.resetPassword(email);

    return result.fold(
      onSuccess: (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
      onFailure: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.toString(),
        );
        if (kDebugMode) {
          print('Reset password error: $error');
        }
        return false;
      },
    );
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refresh user data
  Future<void> refreshUser() async {
    await _getCurrentUser();
  }
}

/// Main auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    authRepository: ref.read(authRepositoryProvider),
  );
});

/// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

/// Authentication status provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Authentication loading provider
final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

/// Authentication error provider
final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});

/// User ID provider for convenience
final userIdProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).user?.id;
});
