import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:souq/models/user.dart';
import 'package:souq/services/auth_service.dart';

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;
  bool _mounted = true;

  AuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    _initialize();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  void _setState(AsyncValue<User?> newState) {
    if (_mounted) {
      state = newState;
    }
  }

  Future<void> _initialize() async {
    if (!_mounted) return;
    
    try {
      final user = await _authService.getUserData();
      _setState(AsyncValue.data(user));
    } catch (e, stack) {
      _setState(AsyncValue.error(e, stack));
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    if (!_mounted) return;
    
    _setState(const AsyncValue.loading());
    try {
      final result = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print(result.user);
      
      if (result.isSuccess) {
        final user = await _authService.getUserData();
        _setState(AsyncValue.data(user));
      } else {
        _setState(const AsyncValue.data(null));
        throw Exception('Sign in failed');
      }
    } catch (e, stack) {
      _setState(AsyncValue.error(e, stack));
      rethrow;
    }
  }

  Future<void> signUpWithEmailAndPassword(
    String email, 
    String password, 
    String firstName, 
    String lastName
  ) async {
    if (!_mounted) return;
    
    _setState(const AsyncValue.loading());
    try {
      final result = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      
      if (result.isSuccess) {
        final user = await _authService.getUserData();
        _setState(AsyncValue.data(user));
      } else {
        _setState(const AsyncValue.data(null));
        throw Exception('Sign up failed');
      }
    } catch (e, stack) {
      _setState(AsyncValue.error(e, stack));
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    if (!_mounted) return;
    
    _setState(const AsyncValue.loading());
    try {
      final result = await _authService.signInWithGoogle();
      if (result.isSuccess) {
        final user = await _authService.getUserData();
        _setState(AsyncValue.data(user));
      } else {
        _setState(const AsyncValue.data(null));
        throw Exception('Google sign in failed');
      }
    } catch (e, stack) {
      _setState(AsyncValue.error(e, stack));
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (!_mounted) return;
    
    try {
      await _authService.signOut();
      _setState(const AsyncValue.data(null));
    } catch (e, stack) {
      _setState(AsyncValue.error(e, stack));
      rethrow;
    }
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    if (!_mounted || state.value == null) return;
    
    try {
      final result = await _authService.updateUserProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        profileImageUrl: profileImageUrl,
      );
      
      if (result.isSuccess) {
        final user = await _authService.getUserData();
        _setState(AsyncValue.data(user));
      } else {
        throw Exception('Profile update failed');
      }
    } catch (e, stack) {
      _setState(AsyncValue.error(e, stack));
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    if (!_mounted) return;
    
    if (email.trim().isEmpty) {
      throw ArgumentError('Email cannot be empty');
    }
    
    try {
      final result = await _authService.sendPasswordResetEmail(email);
      if (!result.isSuccess) {
        throw Exception('Failed to send password reset email');
      }
    } catch (e) {
      rethrow;
    }
  }

  bool get isAuthenticated => state.value != null;
  User? get currentUser => state.value;
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
