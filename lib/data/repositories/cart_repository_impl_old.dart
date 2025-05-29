import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/result.dart';
import '../../core/failure.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/product.dart';
import '../../constants/app_constants.dart';
import '../../services/product_service.dart';

class CartRepositoryImpl implements CartRepository {
  final FirebaseFirestore _firestore;
  final ProductService _productService;

  CartRepositoryImpl({
    FirebaseFirestore? firestore,
    ProductService? productService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _productService = productService ?? ProductService();
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
        // Create new cart if it doesn't exist
        final newCart = Cart(
          id: userId,
          userId: userId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await _firestore
            .collection(AppConstants.cartsCollection)
            .doc(userId)
            .set(newCart.toJson());
            
        return Result.success(newCart);
      }
    } catch (e) {
      return Result.failure(
        NetworkError('Failed to fetch cart: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Cart>> addToCart(String userId, String productId, int quantity) async {
    try {
      final productResult = await _productService.getProductById(productId);
      final product = productResult.data;
      
      if (product == null) {
        return Result.failure(
          ValidationError('Product not found'),
        );
      }

      final cartRef = _firestore
          .collection(AppConstants.cartsCollection)
          .doc(userId);

      return await _firestore.runTransaction((transaction) async {
        final cartDoc = await transaction.get(cartRef);
        Cart cart;

        if (cartDoc.exists) {
          cart = Cart.fromJson({...cartDoc.data()!, 'id': cartDoc.id});
        } else {
          cart = Cart(
            id: userId,
            userId: userId,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }

        // Check if item already exists in cart
        final existingItemIndex = cart.items.indexWhere(
          (item) => item.productId == productId,
        );

        if (existingItemIndex != -1) {
          // Update quantity of existing item
          final existingItem = cart.items[existingItemIndex];
          final newQuantity = existingItem.quantity + quantity;
          
          cart.items[existingItemIndex] = CartItem(
            id: existingItem.id,
            productId: productId,
            product: product,
            quantity: newQuantity,
            price: product.price,
            addedAt: existingItem.addedAt,
          );
        } else {
          // Add new item to cart
          final cartItem = CartItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            productId: productId,
            product: product,
            quantity: quantity,
            price: product.price,
            addedAt: DateTime.now(),
          );
          
          cart.items.add(cartItem);
        }

        cart = cart.copyWith(updatedAt: DateTime.now());
        
        transaction.set(cartRef, cart.toJson());
        return Result.success(cart);
      });
    } catch (e) {
      return Result.failure(
        NetworkError('Failed to add item to cart: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Cart>> updateCartItem(String userId, String productId, int quantity) async {
    try {
      if (quantity <= 0) {
        return removeFromCart(userId, productId);
      }

      final cartRef = _firestore
          .collection(AppConstants.cartsCollection)
          .doc(userId);

      return await _firestore.runTransaction((transaction) async {
        final cartDoc = await transaction.get(cartRef);
        
        if (!cartDoc.exists) {
          return Result.failure(
            ValidationError('Cart not found'),
          );
        }

        final cart = Cart.fromJson({...cartDoc.data()!, 'id': cartDoc.id});
        
        final itemIndex = cart.items.indexWhere(
          (item) => item.productId == productId,
        );

        if (itemIndex == -1) {
          return Result.failure(
            ValidationError('Item not found in cart'),
          );
        }

        // Update the item quantity
        final existingItem = cart.items[itemIndex];
        cart.items[itemIndex] = CartItem(
          id: existingItem.id,
          productId: productId,
          product: existingItem.product,
          quantity: quantity,
          price: existingItem.price,
          addedAt: existingItem.addedAt,
        );

        final updatedCart = cart.copyWith(updatedAt: DateTime.now());
        transaction.set(cartRef, updatedCart.toJson());
        
        return Result.success(updatedCart);
      });
    } catch (e) {
      return Result.failure(
        NetworkError('Failed to update cart item: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Cart>> removeFromCart(String userId, String productId) async {
    try {
      final cartRef = _firestore
          .collection(AppConstants.cartsCollection)
          .doc(userId);

      return await _firestore.runTransaction((transaction) async {
        final cartDoc = await transaction.get(cartRef);
        
        if (!cartDoc.exists) {
          return Result.failure(
            ValidationError('Cart not found'),
          );
        }

        final cart = Cart.fromJson({...cartDoc.data()!, 'id': cartDoc.id});
        
        // Remove the item
        cart.items.removeWhere((item) => item.productId == productId);
        
        final updatedCart = cart.copyWith(updatedAt: DateTime.now());
        transaction.set(cartRef, updatedCart.toJson());
        
        return Result.success(updatedCart);
      });
    } catch (e) {
      return Result.failure(
        NetworkError('Failed to remove item from cart: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void>> clearCart(String userId) async {
    try {
      final cartRef = _firestore
          .collection(AppConstants.cartsCollection)
          .doc(userId);

      await cartRef.update({
        'items': [],
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return Result.success(null);
    } catch (e) {
      return Result.failure(
        NetworkError('Failed to clear cart: ${e.toString()}'),
      );
    }
  }

  @override
  Stream<Cart> watchCart(String userId) {
    return _firestore
        .collection(AppConstants.cartsCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return Cart.fromJson({...doc.data()!, 'id': doc.id});
          } else {
            return Cart(
              id: userId,
              userId: userId,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
          }
        });
  }
}
