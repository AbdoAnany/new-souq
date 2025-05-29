import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/result.dart';
import '../../core/error/app_error.dart';
import '../../domain/repositories/repositories.dart';
import '../../models/wishlist.dart';
import '../../constants/app_constants.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final FirebaseFirestore _firestore;

  WishlistRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Result<List<String>>> getWishlist(String userId) async {
    try {
      final wishlistDoc = await _firestore
          .collection(AppConstants.wishlistsCollection)
          .doc(userId)
          .get();

      if (!wishlistDoc.exists) {
        // Create empty wishlist if it doesn't exist
        final newWishlist = Wishlist(userId: userId, items: []);
        await _firestore
            .collection(AppConstants.wishlistsCollection)
            .doc(userId)
            .set(newWishlist.toJson());
        return Result.success([]);
      }

      final wishlist = Wishlist.fromJson({
        ...wishlistDoc.data()!,
        'userId': userId,
      });

      final productIds = wishlist.items.map((item) => item.productId).toList();
      return Result.success(productIds);
    } catch (e) {
      return Result.failure(
        NetworkError('Failed to fetch wishlist: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void>> addToWishlist(String userId, String productId) async {
    try {
      final wishlistRef = _firestore
          .collection(AppConstants.wishlistsCollection)
          .doc(userId);

      return await _firestore.runTransaction((transaction) async {
        final wishlistDoc = await transaction.get(wishlistRef);
        Wishlist wishlist;

        if (wishlistDoc.exists) {
          wishlist = Wishlist.fromJson({
            ...wishlistDoc.data()!,
            'userId': userId,
          });
        } else {
          wishlist = Wishlist(userId: userId, items: []);
        }

        // Check if product already exists in wishlist
        final existsInWishlist = wishlist.items.any(
          (item) => item.productId == productId,
        );

        if (!existsInWishlist) {
          final wishlistItem = WishlistItem(
            productId: productId,
            addedAt: DateTime.now(),
          );
          wishlist.items.add(wishlistItem);

          transaction.set(wishlistRef, wishlist.toJson());
        }

        return Result.success(null);
      });
    } catch (e) {
      return Result.failure(
        NetworkError('Failed to add to wishlist: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void>> removeFromWishlist(String userId, String productId) async {
    try {
      final wishlistRef = _firestore
          .collection(AppConstants.wishlistsCollection)
          .doc(userId);

      return await _firestore.runTransaction((transaction) async {
        final wishlistDoc = await transaction.get(wishlistRef);

        if (!wishlistDoc.exists) {
          return Result.failure(
            ValidationError('Wishlist not found'),
          );
        }

        final wishlist = Wishlist.fromJson({
          ...wishlistDoc.data()!,
          'userId': userId,
        });

        // Remove the item from wishlist
        wishlist.items.removeWhere((item) => item.productId == productId);

        transaction.set(wishlistRef, wishlist.toJson());
        return Result.success(null);
      });
    } catch (e) {
      return Result.failure(
        NetworkError('Failed to remove from wishlist: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void>> clearWishlist(String userId) async {
    try {
      await _firestore
          .collection(AppConstants.wishlistsCollection)
          .doc(userId)
          .update({
        'items': [],
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return Result.success(null);
    } catch (e) {
      return Result.failure(
        NetworkError('Failed to clear wishlist: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<bool>> isInWishlist(String userId, String productId) async {
    try {
      final wishlistDoc = await _firestore
          .collection(AppConstants.wishlistsCollection)
          .doc(userId)
          .get();

      if (!wishlistDoc.exists) {
        return Result.success(false);
      }

      final wishlist = Wishlist.fromJson({
        ...wishlistDoc.data()!,
        'userId': userId,
      });

      final isInWishlist = wishlist.items.any(
        (item) => item.productId == productId,
      );

      return Result.success(isInWishlist);
    } catch (e) {
      return Result.failure(
        NetworkError('Failed to check wishlist: ${e.toString()}'),
      );
    }
  }
}
