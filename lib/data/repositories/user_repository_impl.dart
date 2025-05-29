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
    int? limit,
    String? startAfter,
    String? searchQuery,
  }) async {
    try {
      Query query = _firestore.collection(AppConstants.usersCollection);

      if (searchQuery != null && searchQuery.isNotEmpty) {
        // Simple search implementation - you might want to improve this
        query = query.where('name', isGreaterThanOrEqualTo: searchQuery)
                     .where('name', isLessThan: searchQuery + '\uf8ff');
      }

      if (startAfter != null) {
        final startDoc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(startAfter)
            .get();
        if (startDoc.exists) {
          query = query.startAfterDocument(startDoc);
        }
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final usersSnapshot = await query.get();
      final users = usersSnapshot.docs
          .map((doc) => _mapDocumentToUser(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      return Result.success(users);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to get users: ${e.toString()}'));
    }
  }

  @override
  Future<Result<User, Failure>> updateUserProfile({
    required String userId,
    String? name,
    String? email,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
  }) async {
    try {
      final userRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId);

      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (address != null) updateData['address'] = address;
      if (profileImageUrl != null) updateData['profileImageUrl'] = profileImageUrl;

      await userRef.update(updateData);

      // Get the updated user
      final userDoc = await userRef.get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final user = _mapDocumentToUser(userData, userDoc.id);
        return Result.success(user);
      } else {
        return Result.failure(const NotFoundFailure('User not found'));
      }
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to update user profile: ${e.toString()}'));
    }
  }

  // Helper methods
  User _mapDocumentToUser(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      email: data['email'] as String,
      name: data['name'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String?,
      profileImageUrl: data['profileImageUrl'] as String?,
      address: data['address'] as String?,
      isEmailVerified: data['isEmailVerified'] as bool? ?? false,
      isPhoneVerified: data['isPhoneVerified'] as bool? ?? false,
      fcmToken: data['fcmToken'] as String?,
      role: data['role'] as String? ?? 'user',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> _mapUserToDocument(User user) {
    return {
      'email': user.email,
      'name': user.name,
      'phoneNumber': user.phoneNumber,
      'profileImageUrl': user.profileImageUrl,
      'address': user.address,
      'isEmailVerified': user.isEmailVerified,
      'isPhoneVerified': user.isPhoneVerified,
      'fcmToken': user.fcmToken,
      'role': user.role,
      'createdAt': Timestamp.fromDate(user.createdAt),
      'updatedAt': Timestamp.fromDate(user.updatedAt),
    };
  }
}
