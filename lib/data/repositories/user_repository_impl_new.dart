import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../core/result.dart';
import '../../core/failure.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/entities/user.dart';
import '../../constants/app_constants.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;
  final auth.FirebaseAuth _auth;

  UserRepositoryImpl({
    FirebaseFirestore? firestore,
    auth.FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = firebaseAuth ?? auth.FirebaseAuth.instance;

  @override
  Future<Result<User?, Failure>> getCurrentUser() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return Result.success(null);
      }

      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final user = _mapDocumentToUser(userData, userDoc.id);
        return Result.success(user);
      } else {
        return Result.failure(const NotFoundFailure('User profile not found'));
      }
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to get current user: ${e.toString()}'));
    }
  }

  @override
  Future<Result<User, Failure>> getUserById(String userId) async {
    try {
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final user = _mapDocumentToUser(userData, userDoc.id);
        return Result.success(user);
      } else {
        return Result.failure(const NotFoundFailure('User not found'));
      }
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to get user: ${e.toString()}'));
    }
  }

  @override
  Future<Result<User, Failure>> updateUser(User user) async {
    try {
      final userRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id);

      final updatedUser = user.copyWith(updatedAt: DateTime.now());
      
      await userRef.set(_mapUserToDocument(updatedUser), SetOptions(merge: true));

      return Result.success(updatedUser);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to update user: ${e.toString()}'));
    }
  }

  @override
  Future<Result<User, Failure>> createUser(User user) async {
    try {
      final userRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id);

      final newUser = user.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await userRef.set(_mapUserToDocument(newUser));

      return Result.success(newUser);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to create user: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void, Failure>> deleteUser(String userId) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .delete();

      return Result.success(null);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to delete user: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<User>, Failure>> getUsers({
    int? page,
    int? limit,
    String? search,
  }) async {
    try {
      Query query = _firestore.collection(AppConstants.usersCollection);

      // Apply search filter if provided
      if (search != null && search.isNotEmpty) {
        query = query
            .where('firstName', isGreaterThanOrEqualTo: search)
            .where('firstName', isLessThanOrEqualTo: search + '\uf8ff');
      }

      // Apply pagination
      if (limit != null) {
        query = query.limit(limit);
      }

      if (page != null && page > 1 && limit != null) {
        final offset = (page - 1) * limit;
        query = query.offset(offset);
      }

      final querySnapshot = await query.get();

      final users = querySnapshot.docs
          .map((doc) => _mapDocumentToUser(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      return Result.success(users);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to get users: ${e.toString()}'));
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((authUser) async {
      if (authUser == null) return null;

      try {
        final userDoc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(authUser.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          return _mapDocumentToUser(userData, userDoc.id);
        }
        return null;
      } catch (e) {
        return null;
      }
    });
  }

  // Helper methods
  User _mapDocumentToUser(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      email: data['email'] as String,
      firstName: data['firstName'] as String,
      lastName: data['lastName'] as String,
      phone: data['phone'] as String?,
      profileImageUrl: data['profileImageUrl'] as String?,
      dateOfBirth: data['dateOfBirth'] != null 
          ? (data['dateOfBirth'] as Timestamp).toDate() 
          : null,
      isEmailVerified: data['isEmailVerified'] as bool? ?? false,
      role: UserRole.values.firstWhere(
        (role) => role.toString() == data['role'],
        orElse: () => UserRole.customer,
      ),
      preferences: data['preferences'] != null 
          ? UserPreferences.fromMap(Map<String, dynamic>.from(data['preferences']))
          : UserPreferences.defaultPreferences(),
      addresses: (data['addresses'] as List<dynamic>?)
          ?.map((addr) => Address.fromMap(Map<String, dynamic>.from(addr)))
          .toList() ?? [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> _mapUserToDocument(User user) {
    return {
      'email': user.email,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'phone': user.phone,
      'profileImageUrl': user.profileImageUrl,
      'dateOfBirth': user.dateOfBirth != null 
          ? Timestamp.fromDate(user.dateOfBirth!) 
          : null,
      'isEmailVerified': user.isEmailVerified,
      'role': user.role.toString(),
      'preferences': user.preferences.toMap(),
      'addresses': user.addresses.map((addr) => addr.toMap()).toList(),
      'createdAt': Timestamp.fromDate(user.createdAt),
      'updatedAt': Timestamp.fromDate(user.updatedAt),
    };
  }
}
