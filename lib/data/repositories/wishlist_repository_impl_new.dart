import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/result.dart';
import '../../core/failure.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/entities/wishlist.dart';
import '../../constants/app_constants.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final FirebaseFirestore _firestore;

  WishlistRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Result<Wishlist, Failure>> getWishlist(String userId) async {
    try {
      final wishlistDoc = await _firestore
          .collection(AppConstants.wishlistsCollection)
          .doc(userId)
          .get();

      if (wishlistDoc.exists) {
        final wishlistData = wishlistDoc.data()!;
        final wishlist = _mapDocumentToWishlist(wishlistData, wishlistDoc.id);
        return Result.success(wishlist);
      } else {
        // Create empty wishlist
        final emptyWishlist = Wishlist(
          id: userId,
          userId: userId,
          productIds: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        // Save empty wishlist to Firestore
        await _firestore
            .collection(AppConstants.wishlistsCollection)
            .doc(userId)
            .set(_mapWishlistToDocument(emptyWishlist));
            
        return Result.success(emptyWishlist);
      }
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to get wishlist: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void, Failure>> addToWishlist(String userId, String productId) async {
    try {
      final wishlistRef = _firestore
          .collection(AppConstants.wishlistsCollection)
          .doc(userId);

      return await _firestore.runTransaction((transaction) async {
        final wishlistDoc = await transaction.get(wishlistRef);
        Wishlist wishlist;

        if (wishlistDoc.exists) {
          final wishlistData = wishlistDoc.data()!;
          wishlist = _mapDocumentToWishlist(wishlistData, wishlistDoc.id);
        } else {
          wishlist = Wishlist(
            id: userId,
            userId: userId,
            productIds: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }

        // Check if product is already in wishlist
        if (wishlist.productIds.contains(productId)) {
          return Result.success(null);
        }

        // Add product to wishlist
        final updatedProductIds = List<String>.from(wishlist.productIds)
          ..add(productId);

        final updatedWishlist = wishlist.copyWith(
          productIds: updatedProductIds,
          updatedAt: DateTime.now(),
        );

        transaction.set(wishlistRef, _mapWishlistToDocument(updatedWishlist));

        return Result.success(null);
      });
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to add to wishlist: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void, Failure>> removeFromWishlist(String userId, String productId) async {
    try {
      final wishlistRef = _firestore
          .collection(AppConstants.wishlistsCollection)
          .doc(userId);

      return await _firestore.runTransaction((transaction) async {
        final wishlistDoc = await transaction.get(wishlistRef);
        
        if (!wishlistDoc.exists) {
          return Result.failure(const NotFoundFailure('Wishlist not found'));
        }

        final wishlistData = wishlistDoc.data()!;
        final wishlist = _mapDocumentToWishlist(wishlistData, wishlistDoc.id);

        // Remove product from wishlist
        final updatedProductIds = List<String>.from(wishlist.productIds)
          ..remove(productId);

        final updatedWishlist = wishlist.copyWith(
          productIds: updatedProductIds,
          updatedAt: DateTime.now(),
        );

        transaction.set(wishlistRef, _mapWishlistToDocument(updatedWishlist));

        return Result.success(null);
      });
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to remove from wishlist: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void, Failure>> clearWishlist(String userId) async {
    try {
      final wishlistRef = _firestore
          .collection(AppConstants.wishlistsCollection)
          .doc(userId);

      await wishlistRef.update({
        'productIds': [],
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return Result.success(null);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to clear wishlist: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Wishlist, Failure>> toggleWishlist(String userId, String productId) async {
    try {
      final wishlistRef = _firestore
          .collection(AppConstants.wishlistsCollection)
          .doc(userId);

      return await _firestore.runTransaction((transaction) async {
        final wishlistDoc = await transaction.get(wishlistRef);
        Wishlist wishlist;

        if (wishlistDoc.exists) {
          final wishlistData = wishlistDoc.data()!;
          wishlist = _mapDocumentToWishlist(wishlistData, wishlistDoc.id);
        } else {
          wishlist = Wishlist(
            id: userId,
            userId: userId,
            productIds: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }

        List<String> updatedProductIds = List.from(wishlist.productIds);

        if (updatedProductIds.contains(productId)) {
          updatedProductIds.remove(productId);
        } else {
          updatedProductIds.add(productId);
        }

        final updatedWishlist = wishlist.copyWith(
          productIds: updatedProductIds,
          updatedAt: DateTime.now(),
        );

        transaction.set(wishlistRef, _mapWishlistToDocument(updatedWishlist));

        return Result.success(updatedWishlist);
      });
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to toggle wishlist: ${e.toString()}'));
    }
  }

  @override
  Future<Result<bool, Failure>> isInWishlist(String userId, String productId) async {
    try {
      final wishlistDoc = await _firestore
          .collection(AppConstants.wishlistsCollection)
          .doc(userId)
          .get();

      if (!wishlistDoc.exists) {
        return Result.success(false);
      }

      final wishlistData = wishlistDoc.data()!;
      final wishlist = _mapDocumentToWishlist(wishlistData, wishlistDoc.id);

      return Result.success(wishlist.productIds.contains(productId));
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to check wishlist: ${e.toString()}'));
    }
  }

  @override
  Stream<Result<Wishlist, Failure>> watchWishlist(String userId) {
    return _firestore
        .collection(AppConstants.wishlistsCollection)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      try {
        if (snapshot.exists) {
          final wishlistData = snapshot.data()!;
          final wishlist = _mapDocumentToWishlist(wishlistData, snapshot.id);
          return Result.success(wishlist);
        } else {
          final emptyWishlist = Wishlist(
            id: userId,
            userId: userId,
            productIds: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          return Result.success(emptyWishlist);
        }
      } catch (e) {
        return Result.failure(NetworkFailure('Failed to watch wishlist: ${e.toString()}'));
      }
    });
  }

  // Helper methods
  Wishlist _mapDocumentToWishlist(Map<String, dynamic> data, String id) {
    final productIds = List<String>.from(data['productIds'] ?? []);

    return Wishlist(
      id: id,
      userId: data['userId'] as String,
      productIds: productIds,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> _mapWishlistToDocument(Wishlist wishlist) {
    return {
      'userId': wishlist.userId,
      'productIds': wishlist.productIds,
      'createdAt': Timestamp.fromDate(wishlist.createdAt),
      'updatedAt': Timestamp.fromDate(wishlist.updatedAt),
    };
  }
}
