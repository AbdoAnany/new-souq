import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/result.dart';
import '../../core/failure.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/entities/wishlist.dart';
import '../../domain/entities/product.dart';
import '../../constants/app_constants.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final FirebaseFirestore _firestore;
  final ProductRepository _productRepository;

  WishlistRepositoryImpl({
    FirebaseFirestore? firestore,
    required ProductRepository productRepository,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
        _productRepository = productRepository;

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
      } else {        // Create empty wishlist
        final emptyWishlist = Wishlist(
          id: userId,
          userId: userId,
          items: [],
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
  Future<Result<Wishlist, Failure>> addToWishlist(String userId, String productId) async {
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
            items: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }

        // Check if product is already in wishlist
        if (wishlist.containsProduct(productId)) {
          return Result.success(wishlist);
        }

        // Get product details
        final productResult = await _productRepository.getProductById(productId);
        if (productResult.isFailure) {
          return Result.failure((productResult as ResultFailure).failure);
        }
        
        final product = (productResult as Success).value;

        // Add product to wishlist
        final newItem = WishlistItem(
          id: _generateWishlistItemId(),
          productId: productId,
          product: product,
          addedAt: DateTime.now(),
        );

        final updatedItems = List<WishlistItem>.from(wishlist.items)..add(newItem);

        final updatedWishlist = wishlist.copyWith(
          items: updatedItems,
          updatedAt: DateTime.now(),
        );

        transaction.set(wishlistRef, _mapWishlistToDocument(updatedWishlist));

        return Result.success(updatedWishlist);
      });
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to add to wishlist: ${e.toString()}'));
    }
  }  @override
  Future<Result<Wishlist, Failure>> removeFromWishlist(String userId, String productId) async {
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
        final updatedItems = wishlist.items
            .where((item) => item.productId != productId)
            .toList();

        final updatedWishlist = wishlist.copyWith(
          items: updatedItems,
          updatedAt: DateTime.now(),
        );

        transaction.set(wishlistRef, _mapWishlistToDocument(updatedWishlist));

        return Result.success(updatedWishlist);
      });
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to remove from wishlist: ${e.toString()}'));
    }
  }
  @override
  Future<Result<Wishlist, Failure>> clearWishlist(String userId) async {
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

        final clearedWishlist = wishlist.copyWith(
          items: [],
          updatedAt: DateTime.now(),
        );

        transaction.set(wishlistRef, _mapWishlistToDocument(clearedWishlist));

        return Result.success(clearedWishlist);
      });
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
            items: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }

        List<WishlistItem> updatedItems = List.from(wishlist.items);

        if (wishlist.containsProduct(productId)) {
          // Remove item
          updatedItems.removeWhere((item) => item.productId == productId);
        } else {
          // Add item - get product details first
          final productResult = await _productRepository.getProductById(productId);
          if (productResult.isFailure) {
            return Result.failure((productResult as ResultFailure).failure);
          }
          
          final product = (productResult as Success).value;
          
          final newItem = WishlistItem(
            id: _generateWishlistItemId(),
            productId: productId,
            product: product,
            addedAt: DateTime.now(),
          );
          updatedItems.add(newItem);
        }

        final updatedWishlist = wishlist.copyWith(
          items: updatedItems,
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

      return Result.success(wishlist.containsProduct(productId));
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
            items: [],
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
    final itemsData = List<Map<String, dynamic>>.from(data['items'] ?? []);
    final items = itemsData.map((itemData) => _mapDocumentToWishlistItem(itemData)).toList();

    return Wishlist(
      id: id,
      userId: data['userId'] as String,
      items: items,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
  WishlistItem _mapDocumentToWishlistItem(Map<String, dynamic> data) {
    final productData = data['product'] as Map<String, dynamic>;
    
    return WishlistItem(
      id: data['id'] as String,
      productId: data['productId'] as String,
      product: Product(
        id: productData['id'] as String,
        name: productData['name'] as String,
        description: productData['description'] as String? ?? '',
        price: (productData['price'] as num).toDouble(),
        originalPrice: (productData['originalPrice'] as num?)?.toDouble(),
        categoryId: productData['categoryId'] as String? ?? '',
        category: productData['category'] as String? ?? '',
        images: List<String>.from(productData['images'] ?? []),
        inStock: productData['inStock'] as bool? ?? true,
        quantity: productData['quantity'] as int? ?? 0,
        rating: (productData['rating'] as num?)?.toDouble() ?? 0.0,
        reviewCount: productData['reviewCount'] as int? ?? 0,
        specifications: Map<String, dynamic>.from(productData['specifications'] ?? {}),
        tags: List<String>.from(productData['tags'] ?? []),
        createdAt: (productData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (productData['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        isFeatured: productData['isFeatured'] as bool? ?? false,
        discountPercentage: (productData['discountPercentage'] as num?)?.toDouble(),
        brand: productData['brand'] as String?,
        sku: productData['sku'] as String?,
        weight: (productData['weight'] as num?)?.toDouble(),
        dimensions: productData['dimensions'] as String?,
      ),
      addedAt: (data['addedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> _mapWishlistToDocument(Wishlist wishlist) {
    return {
      'userId': wishlist.userId,
      'items': wishlist.items.map((item) => _mapWishlistItemToDocument(item)).toList(),
      'createdAt': Timestamp.fromDate(wishlist.createdAt),
      'updatedAt': Timestamp.fromDate(wishlist.updatedAt),
    };
  }
  Map<String, dynamic> _mapWishlistItemToDocument(WishlistItem item) {
    return {
      'id': item.id,
      'productId': item.productId,
      'product': {
        'id': item.product.id,
        'name': item.product.name,
        'description': item.product.description,
        'price': item.product.price,
        'originalPrice': item.product.originalPrice,
        'categoryId': item.product.categoryId,
        'category': item.product.category,
        'images': item.product.images,
        'inStock': item.product.inStock,
        'quantity': item.product.quantity,
        'rating': item.product.rating,
        'reviewCount': item.product.reviewCount,
        'specifications': item.product.specifications,
        'tags': item.product.tags,
        'createdAt': Timestamp.fromDate(item.product.createdAt),
        'updatedAt': Timestamp.fromDate(item.product.updatedAt),
        'isFeatured': item.product.isFeatured,
        'discountPercentage': item.product.discountPercentage,
        'brand': item.product.brand,
        'sku': item.product.sku,
        'weight': item.product.weight,
        'dimensions': item.product.dimensions,
      },
      'addedAt': Timestamp.fromDate(item.addedAt),
    };
  }

  String _generateWishlistItemId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${(1000 + (999 * (DateTime.now().microsecond / 1000000))).round()}';
  }
}
