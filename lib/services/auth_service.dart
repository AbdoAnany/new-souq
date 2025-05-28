import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:souq/models/user.dart' as app_user;
import 'package:souq/constants/app_constants.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  firebase_auth.User? get currentUser => _auth.currentUser;
  
  // Auth state stream
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        final userDoc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(credential.user!.uid)
            .get();
            
        if (userDoc.exists) {
          final userData = app_user.User.fromJson({
            ...userDoc.data()!,
            'id': credential.user!.uid,
          });
          return AuthResult.success(userData);
        } else {
          // Create user document if it doesn't exist
          final newUser = app_user.User(
            id: credential.user!.uid,
            email: credential.user!.email!,
            firstName: credential.user!.displayName?.split(' ').first ?? '',
            lastName: credential.user!.displayName?.split(' ').skip(1).join(' ') ?? '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isEmailVerified: credential.user!.emailVerified,
          );
          
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(credential.user!.uid)
              .set(newUser.toJson());
              
          return AuthResult.success(newUser);
        }
      }
      
      return AuthResult.failure('Authentication failed');
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred');
    }
  }

  // Sign up with email and password
  Future<AuthResult> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName('$firstName $lastName');
        
        // Create user document
        final newUser = app_user.User(
          id: credential.user!.uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isEmailVerified: credential.user!.emailVerified,
        );
        
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(credential.user!.uid)
            .set(newUser.toJson());
            
        // Send email verification
        await credential.user!.sendEmailVerification();
        
        return AuthResult.success(newUser);
      }
      
      return AuthResult.failure('Registration failed');
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred');
    }
  }

  // Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult.failure('Google sign in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        final userDoc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(userCredential.user!.uid)
            .get();
            
        if (userDoc.exists) {
          final userData = app_user.User.fromJson({
            ...userDoc.data()!,
            'id': userCredential.user!.uid,
          });
          return AuthResult.success(userData);
        } else {
          // Create user document for new Google user
          final names = userCredential.user!.displayName?.split(' ') ?? ['', ''];
          final newUser = app_user.User(
            id: userCredential.user!.uid,
            email: userCredential.user!.email!,
            firstName: names.first,
            lastName: names.skip(1).join(' '),
            profileImageUrl: userCredential.user!.photoURL,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isEmailVerified: userCredential.user!.emailVerified,
          );
          
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(userCredential.user!.uid)
              .set(newUser.toJson());
              
          return AuthResult.success(newUser);
        }
      }
      
      return AuthResult.failure('Google authentication failed');
    } catch (e) {
      return AuthResult.failure('Google sign in failed: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  // Send password reset email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult.success(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Failed to send password reset email');
    }
  }

  // Send email verification
  Future<AuthResult> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return AuthResult.success(null);
      }
      return AuthResult.failure('User not found or email already verified');
    } catch (e) {
      return AuthResult.failure('Failed to send verification email');
    }
  }

  // Update user profile
  Future<AuthResult> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('User not authenticated');
      }

      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();
          
      if (!userDoc.exists) {
        return AuthResult.failure('User document not found');
      }

      final currentUserData = app_user.User.fromJson({
        ...userDoc.data()!,
        'id': user.uid,
      });

      final updatedUser = currentUserData.copyWith(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        profileImageUrl: profileImageUrl,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update(updatedUser.toJson());
          
      // Update Firebase Auth display name if names changed
      if (firstName != null || lastName != null) {
        await user.updateDisplayName('${updatedUser.firstName} ${updatedUser.lastName}');
      }

      return AuthResult.success(updatedUser);
    } catch (e) {
      return AuthResult.failure('Failed to update profile: ${e.toString()}');
    }
  }

  // Get user data
  Future<app_user.User?> getUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();
          
      if (userDoc.exists) {
        return app_user.User.fromJson({
          ...userDoc.data()!,
          'id': user.uid,
        });
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update FCM token
  Future<void> updateFCMToken(String token) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .update({
          'fcmToken': token,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  // Change password
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('User not authenticated');
      }

      // Re-authenticate user
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Update password
      await user.updatePassword(newPassword);
      
      return AuthResult.success(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Failed to change password');
    }
  }

  // Delete account
  Future<AuthResult> deleteAccount(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('User not authenticated');
      }

      // Re-authenticate user
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Delete user document
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .delete();
      
      // Delete user account
      await user.delete();
      
      return AuthResult.success(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Failed to delete account');
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'requires-recent-login':
        return 'Please log in again to complete this action.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}

class AuthResult {
  final bool isSuccess;
  final app_user.User? user;
  final String? errorMessage;

  AuthResult._({
    required this.isSuccess,
    this.user,
    this.errorMessage,
  });

  factory AuthResult.success(app_user.User? user) {
    return AuthResult._(
      isSuccess: true,
      user: user,
    );
  }

  factory AuthResult.failure(String errorMessage) {
    return AuthResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}
