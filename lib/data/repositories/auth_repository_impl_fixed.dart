import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/result.dart';
import '../../core/failure.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/entities/user.dart';
import '../../constants/app_constants.dart';

class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({
    firebase_auth.FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Result<User, Failure>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return Result.failure(
          const AuthFailure('Sign in failed'),
        );
      }

      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(credential.user!.uid)
          .get();

      if (userDoc.exists) {
        final userData = _mapDocumentToUser(userDoc.data()!, credential.user!.uid);
        return Result.success(userData);
      } else {
        // Create user document if it doesn't exist
        final newUser = User(
          id: credential.user!.uid,
          email: credential.user!.email!,
          name: credential.user!.displayName ?? '',
          isEmailVerified: credential.user!.emailVerified,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(credential.user!.uid)
            .set(_mapUserToDocument(newUser));

        return Result.success(newUser);
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Result.failure(_mapFirebaseAuthError(e));
    } catch (e) {
      return Result.failure(
        NetworkFailure('Sign in failed: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<User, Failure>> signUpWithEmailAndPassword(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return Result.failure(
          const AuthFailure('Sign up failed'),
        );
      }

      // Update display name
      await credential.user!.updateDisplayName('$firstName $lastName');

      // Create user document in Firestore
      final newUser = User(
        id: credential.user!.uid,
        email: email,
        name: '$firstName $lastName',
        firstName: firstName,
        lastName: lastName,
        isEmailVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(credential.user!.uid)
          .set(_mapUserToDocument(newUser));

      // Send email verification
      await credential.user!.sendEmailVerification();

      return Result.success(newUser);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Result.failure(_mapFirebaseAuthError(e));
    } catch (e) {
      return Result.failure(
        NetworkFailure('Registration failed: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<User, Failure>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return Result.failure(
          const AuthFailure('Google sign in was cancelled'),
        );
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user == null) {
        return Result.failure(
          const AuthFailure('Google sign in failed'),
        );
      }

      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        final userData = _mapDocumentToUser(userDoc.data()!, userCredential.user!.uid);
        // Update last login
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(userCredential.user!.uid)
            .update({
          'lastLoginAt': Timestamp.fromDate(DateTime.now()),
        });
        return Result.success(userData);
      } else {
        // Create new user document
        final newUser = User(
          id: userCredential.user!.uid,
          email: userCredential.user!.email!,
          name: userCredential.user!.displayName ?? '',
          firstName: userCredential.user!.displayName?.split(' ').first ?? '',
          lastName: userCredential.user!.displayName?.split(' ').skip(1).join(' ') ?? '',
          profileImageUrl: userCredential.user!.photoURL,
          isEmailVerified: userCredential.user!.emailVerified,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(userCredential.user!.uid)
            .set(_mapUserToDocument(newUser));

        return Result.success(newUser);
      }
    } catch (e) {
      return Result.failure(
        NetworkFailure('Google sign in failed: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void, Failure>> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        NetworkFailure('Sign out failed: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void, Failure>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return Result.success(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Result.failure(_mapFirebaseAuthError(e));
    } catch (e) {
      return Result.failure(
        NetworkFailure('Password reset failed: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<User?, Failure>> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      
      if (firebaseUser == null) {
        return Result.success(null);
      }

      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .get();

      if (userDoc.exists) {
        final userData = _mapDocumentToUser(userDoc.data()!, firebaseUser.uid);
        return Result.success(userData);
      }

      return Result.success(null);
    } catch (e) {
      return Result.failure(
        NetworkFailure('Failed to get current user: ${e.toString()}'),
      );
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        final userDoc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(firebaseUser.uid)
            .get();

        if (userDoc.exists) {
          return _mapDocumentToUser(userDoc.data()!, firebaseUser.uid);
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }

      return null;
    });
  }

  // Helper methods
  User _mapDocumentToUser(Map<String, dynamic> doc, String id) {
    return User(
      id: id,
      email: doc['email'] ?? '',
      name: doc['name'] ?? '',
      firstName: doc['firstName'],
      lastName: doc['lastName'],
      phoneNumber: doc['phoneNumber'],
      profileImageUrl: doc['profileImageUrl'],
      address: doc['address'],
      isEmailVerified: doc['isEmailVerified'] ?? false,
      createdAt: (doc['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (doc['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (doc['lastLoginAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> _mapUserToDocument(User user) {
    return {
      'email': user.email,
      'name': user.name,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'phoneNumber': user.phoneNumber,
      'profileImageUrl': user.profileImageUrl,
      'address': user.address,
      'isEmailVerified': user.isEmailVerified,
      'createdAt': Timestamp.fromDate(user.createdAt),
      'updatedAt': Timestamp.fromDate(user.updatedAt),
      'lastLoginAt': user.lastLoginAt != null ? Timestamp.fromDate(user.lastLoginAt!) : null,
    };
  }

  AuthFailure _mapFirebaseAuthError(firebase_auth.FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'No user found for that email address.';
        break;
      case 'wrong-password':
        message = 'Wrong password provided for that user.';
        break;
      case 'invalid-email':
        message = 'The email address is not valid.';
        break;
      case 'user-disabled':
        message = 'This user account has been disabled.';
        break;
      case 'too-many-requests':
        message = 'Too many unsuccessful login attempts. Please try again later.';
        break;
      case 'weak-password':
        message = 'The password provided is too weak.';
        break;
      case 'email-already-in-use':
        message = 'The account already exists for that email.';
        break;
      case 'operation-not-allowed':
        message = 'Email/password accounts are not enabled.';
        break;
      default:
        message = 'Authentication failed: ${e.message}';
    }
    return AuthFailure(message);
  }
}
