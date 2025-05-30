import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/result.dart';
import '../../core/failure.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/product.dart';
import '../../constants/app_constants.dart';

class CartRepositoryImpl implements CartRepository {
  final FirebaseFirestore _firestore;
  final ProductRepository _productRepository;

  CartRepositoryImpl({
    FirebaseFirestore? firestore,
    required ProductRepository productRepository,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
        _productRepository = productRepository;

  @override
  Future<Result<Cart, Failure>> getCart(String userId) async {
    try {
      final cartDoc = await _firestore
          .collection(AppConstants.cartsCollection)
          .doc(userId)
          .get();

      if (cartDoc.exists) {
        final cartData = cartDoc.data()!;
        final cart = _mapDocumentToCart(cartData, cartDoc.id);
        return Result.success(cart);
      } else {
        // Create empty cart
        final emptyCart = Cart(
          id: userId,
          userId: userId,
          items: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        return Result.success(emptyCart);
      }
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to get cart: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Cart, Failure>> addToCart({
    required String userId,
    required String productId,
    required int quantity,
    Map<String, dynamic>? selectedVariants,
  }) async {
    try {
      if (quantity <= 0) {
        return Result.failure(const ValidationFailure('Quantity must be greater than 0'));
      }

      final cartRef = _firestore
          .collection(AppConstants.cartsCollection)
          .doc(userId);

      return await _firestore.runTransaction((transaction) async {
        final cartDoc = await transaction.get(cartRef);
        Cart cart;

        if (cartDoc.exists) {
          final cartData = cartDoc.data()!;
          cart = _mapDocumentToCart(cartData, cartDoc.id);
        } else {
          cart = Cart(
            id: userId,
            userId: userId,
            items: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }

        // Check if item already exists in cart
        final existingItemIndex = cart.items.indexWhere(
          (item) => item.productId == productId && 
                   _variantsMatch(item.selectedVariants, selectedVariants),
        );

        List<CartItem> updatedItems = List.from(cart.items);

        if (existingItemIndex != -1) {
          // Update existing item quantity
          final existingItem = updatedItems[existingItemIndex];
          updatedItems[existingItemIndex] = existingItem.copyWith(
            quantity: existingItem.quantity + quantity,
          );        } else {
          // Get product details first
          final productResult = await _productRepository.getProductById(productId);
          if (productResult.isFailure) {
            return Result.failure((productResult as ResultFailure).failure);
          }
          
          final product = (productResult as Success).value;
          
          // Add new item
          final newItem = CartItem(
            id: _generateCartItemId(),
            productId: productId,
            product: product,
            quantity: quantity,
            price: product.price,
            selectedVariants: selectedVariants ?? {},
            addedAt: DateTime.now(),
          );
          updatedItems.add(newItem);
        }

        final updatedCart = cart.copyWith(
          items: updatedItems,
          updatedAt: DateTime.now(),
        );

        // Save to Firestore
        transaction.set(cartRef, _mapCartToDocument(updatedCart));

        return Result.success(updatedCart);
      });
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to add to cart: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Cart, Failure>> updateCartItem({
    required String userId,
    required String productId,
    required int quantity,
  }) async {
    try {
      if (quantity < 0) {
        return Result.failure(const ValidationFailure('Quantity cannot be negative'));
      }

      final cartRef = _firestore
          .collection(AppConstants.cartsCollection)
          .doc(userId);

      return await _firestore.runTransaction((transaction) async {
        final cartDoc = await transaction.get(cartRef);
        
        if (!cartDoc.exists) {
          return Result.failure(const NotFoundFailure('Cart not found'));
        }

        final cartData = cartDoc.data()!;
        final cart = _mapDocumentToCart(cartData, cartDoc.id);

        final itemIndex = cart.items.indexWhere(
          (item) => item.productId == productId,
        );

        if (itemIndex == -1) {
          return Result.failure(const NotFoundFailure('Item not found in cart'));
        }

        List<CartItem> updatedItems = List.from(cart.items);

        if (quantity == 0) {
          // Remove item
          updatedItems.removeAt(itemIndex);
        } else {
          // Update quantity
          updatedItems[itemIndex] = updatedItems[itemIndex].copyWith(
            quantity: quantity,
          );
        }

        final updatedCart = cart.copyWith(
          items: updatedItems,
          updatedAt: DateTime.now(),
        );

        transaction.set(cartRef, _mapCartToDocument(updatedCart));

        return Result.success(updatedCart);
      });
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to update cart item: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Cart, Failure>> removeFromCart({
    required String userId,
    required String productId,
  }) async {
    try {
      final cartRef = _firestore
          .collection(AppConstants.cartsCollection)
          .doc(userId);

      return await _firestore.runTransaction((transaction) async {
        final cartDoc = await transaction.get(cartRef);
        
        if (!cartDoc.exists) {
          return Result.failure(const NotFoundFailure('Cart not found'));
        }

        final cartData = cartDoc.data()!;
        final cart = _mapDocumentToCart(cartData, cartDoc.id);

        final updatedItems = cart.items
            .where((item) => item.productId != productId)
            .toList();

        final updatedCart = cart.copyWith(
          items: updatedItems,
          updatedAt: DateTime.now(),
        );

        transaction.set(cartRef, _mapCartToDocument(updatedCart));

        return Result.success(updatedCart);
      });
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to remove from cart: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void, Failure>> clearCart(String userId) async {
    try {
      final cartRef = _firestore
          .collection(AppConstants.cartsCollection)
          .doc(userId);

      await cartRef.update({
        'items': [],
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return Result.success(null);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to clear cart: ${e.toString()}'));
    }
  }

  @override
  Stream<Result<Cart, Failure>> watchCart(String userId) {
    return _firestore
        .collection(AppConstants.cartsCollection)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      try {
        if (snapshot.exists) {
          final cartData = snapshot.data()!;
          final cart = _mapDocumentToCart(cartData, snapshot.id);
          return Result.success(cart);
        } else {
          final emptyCart = Cart(
            id: userId,
            userId: userId,
            items: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          return Result.success(emptyCart);
        }
      } catch (e) {
        return Result.failure(NetworkFailure('Failed to watch cart: ${e.toString()}'));
      }
    });
  }
  // Helper methods
  Cart _mapDocumentToCart(Map<String, dynamic> data, String id) {
    final itemsData = data['items'] as List<dynamic>? ?? [];
    final items = itemsData.map((itemData) => _mapDocumentToCartItem(itemData)).toList();

    return Cart(
      id: id,
      userId: data['userId'] as String,
      items: items,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  CartItem _mapDocumentToCartItem(Map<String, dynamic> data) {
    // Create a minimal product object from stored data
    final product = Product(
      id: data['productId'] as String,
      name: data['productName'] as String? ?? 'Unknown Product',
      description: data['productDescription'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      categoryId: data['categoryId'] as String? ?? '',
      category: data['category'] as String? ?? '',
      images: (data['productImages'] as List<dynamic>?)?.cast<String>() ?? [],
      inStock: true,
      quantity: 1,
      rating: 0.0,
      reviewCount: 0,
      specifications: {},
      tags: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isFeatured: false,
    );

    return CartItem(
      id: data['id'] as String,
      productId: data['productId'] as String,
      product: product,
      quantity: data['quantity'] as int,
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      selectedVariants: Map<String, dynamic>.from(data['selectedVariants'] ?? {}),
      addedAt: (data['addedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> _mapCartToDocument(Cart cart) {
    return {
      'userId': cart.userId,
      'items': cart.items.map(_mapCartItemToDocument).toList(),
      'createdAt': Timestamp.fromDate(cart.createdAt),
      'updatedAt': Timestamp.fromDate(cart.updatedAt),
    };
  }
  Map<String, dynamic> _mapCartItemToDocument(CartItem item) {
    return {
      'id': item.id,
      'productId': item.productId,
      'productName': item.product.name,      'productDescription': item.product.description,
      'productImages': item.product.images,
      'categoryId': item.product.categoryId,
      'category': item.product.category,
      'quantity': item.quantity,
      'price': item.price,
      'selectedVariants': item.selectedVariants,
      'addedAt': Timestamp.fromDate(item.addedAt),
    };
  }

  bool _variantsMatch(Map<String, dynamic>? variants1, Map<String, dynamic>? variants2) {
    if (variants1 == null && variants2 == null) return true;
    if (variants1 == null || variants2 == null) return false;
    
    if (variants1.length != variants2.length) return false;
    
    for (final key in variants1.keys) {
      if (variants1[key] != variants2[key]) return false;
    }
    
    return true;
  }

  String _generateCartItemId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
