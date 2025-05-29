import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/result.dart';
import '../../core/error/app_error.dart';
import '../../domain/repositories/repositories.dart';
import '../../models/user.dart';
import '../../constants/app_constants.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;

  UserRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Result<User>> getCurrentUser() async {
    try {
      // This would typically get the current user ID from FirebaseAuth
      // For now, we'll implement a basic version
      return Result.failure(
        AuthError('User not authenticated'),
      );
    } catch (e) {
      return Result.failure(
        NetworkError('Failed to get current user: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<User>> getUserById(String userId) async {
    try {
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        return Result.failure(
          ValidationError('User not found'),
        );
      }

      final user = User.fromJson({
        ...userDoc.data()!,
        'id': userDoc.id,
      });

      return Result.success(user);
    } catch (e) {
      return Result.failure(
        NetworkError('Failed to fetch user: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<User>> updateUser(User user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .update({
        ...user.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return Result.success(user);
    } catch (e) {
      return Result.failure(
        NetworkError('Failed to update user: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void>> deleteUser(String userId) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .delete();

      return Result.success(null);
    } catch (e) {
      return Result.failure(
        NetworkError('Failed to delete user: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<User>>> getUsers({
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
            .where('firstName', isLessThan: search + 'z');
      }

      // Apply pagination
      if (limit != null) {
        query = query.limit(limit);
      }

      if (page != null && limit != null && page > 1) {
        final offset = (page - 1) * limit;
        // Note: Firestore doesn't support offset directly, 
        // this is a simplified implementation
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      
      final users = querySnapshot.docs
          .map((doc) => User.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();

      return Result.success(users);
    } catch (e) {
      return Result.failure(
        NetworkError('Failed to fetch users: ${e.toString()}'),
      );
    }
  }
}
