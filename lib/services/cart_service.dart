import 'package:cloud_firestore/cloud_firestore.dart';
import '/core/constants/app_constants.dart';
import 'package:souq/models/cart.dart';
import 'package:souq/models/product.dart';
import 'package:uuid/uuid.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Get user's cart
  Future<Cart> getCart(String userId) async {
    try {
      final cartDoc = await _firestore
          .collection(AppConstants.cartsCollection)
          .doc(userId)
          .get();

      if (cartDoc.exists) {
        return Cart.fromJson({...cartDoc.data()!, 'id': cartDoc.id});
      } else {
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
            
        return newCart;
      }
    } catch (e) {
      throw Exception('Failed to fetch cart: ${e.toString()}');
    }
  }

  // Add item to cart
  Future<Cart> addToCart({
    required String userId,
    required Product product,
    required int quantity,
    Map<String, dynamic>? selectedVariants,
  }) async {
    try {
      final cart = await getCart(userId);
      final existingItemIndex = cart.items.indexWhere(
        (item) => item.productId == product.id,
      );

      List<CartItem> updatedItems = List.from(cart.items);

      if (existingItemIndex != -1) {
        // Update existing item quantity
        final existingItem = updatedItems[existingItemIndex];
        final newQuantity = existingItem.quantity + quantity;
        
        if (newQuantity <= AppConstants.maxCartQuantity) {
          updatedItems[existingItemIndex] = existingItem.copyWith(
            quantity: newQuantity,
          );
        } else {
          throw Exception('Maximum quantity limit reached');
        }
      } else {
        // Add new item
        if (quantity <= AppConstants.maxCartQuantity) {
          final newItem = CartItem(
            id: _uuid.v4(),
            productId: product.id,
            product: product,
            quantity: quantity,
            price: product.price,
            addedAt: DateTime.now(),
            selectedVariants: selectedVariants,
          );
          updatedItems.add(newItem);
        } else {
          throw Exception('Maximum quantity limit reached');
        }
      }

      final updatedCart = cart.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.cartsCollection)
          .doc(userId)
          .update(updatedCart.toJson());

      return updatedCart;
    } catch (e) {
      throw Exception('Failed to add item to cart: ${e.toString()}');
    }
  }

  // Update cart item quantity
  Future<Cart> updateCartItemQuantity({
    required String userId,
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      final cart = await getCart(userId);
      final itemIndex = cart.items.indexWhere((item) => item.id == cartItemId);

      if (itemIndex == -1) {
        throw Exception('Cart item not found');
      }

      List<CartItem> updatedItems = List.from(cart.items);

      if (quantity <= 0) {
        // Remove item if quantity is 0 or less
        updatedItems.removeAt(itemIndex);
      } else if (quantity <= AppConstants.maxCartQuantity) {
        // Update quantity
        updatedItems[itemIndex] = updatedItems[itemIndex].copyWith(
          quantity: quantity,
        );
      } else {
        throw Exception('Maximum quantity limit reached');
      }

      final updatedCart = cart.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.cartsCollection)
          .doc(userId)
          .update(updatedCart.toJson());

      return updatedCart;
    } catch (e) {
      throw Exception('Failed to update cart item: ${e.toString()}');
    }
  }

  // Remove item from cart
  Future<Cart> removeFromCart({
    required String userId,
    required String cartItemId,
  }) async {
    try {
      final cart = await getCart(userId);
      final updatedItems = cart.items
          .where((item) => item.id != cartItemId)
          .toList();

      final updatedCart = cart.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.cartsCollection)
          .doc(userId)
          .update(updatedCart.toJson());

      return updatedCart;
    } catch (e) {
      throw Exception('Failed to remove item from cart: ${e.toString()}');
    }
  }

  // Clear cart
  Future<Cart> clearCart(String userId) async {
    try {
      final cart = await getCart(userId);
      final updatedCart = cart.copyWith(
        items: [],
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.cartsCollection)
          .doc(userId)
          .update(updatedCart.toJson());

      return updatedCart;
    } catch (e) {
      throw Exception('Failed to clear cart: ${e.toString()}');
    }
  }

  // Get cart stream for real-time updates
  Stream<Cart> getCartStream(String userId) {
    return _firestore
        .collection(AppConstants.cartsCollection)
        .doc(userId)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.exists) {
        return Cart.fromJson({...snapshot.data()!, 'id': snapshot.id});
      } else {
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
            
        return newCart;
      }
    });
  }

  // Apply coupon/offer to cart
  Future<Cart> applyCoupon({
    required String userId,
    required String couponCode,
  }) async {
    try {
      // This would integrate with the offers system
      // For now, it's a placeholder
      final cart = await getCart(userId);
      
      // Validate coupon and calculate discount
      // Implementation would depend on your coupon system
      
      return cart;
    } catch (e) {
      throw Exception('Failed to apply coupon: ${e.toString()}');
    }
  }

  // Remove coupon from cart
  Future<Cart> removeCoupon(String userId) async {
    try {
      final cart = await getCart(userId);
      
      // Remove coupon discount
      // Implementation would depend on your coupon system
      
      return cart;
    } catch (e) {
      throw Exception('Failed to remove coupon: ${e.toString()}');
    }
  }

  // Validate cart items (check stock, prices, etc.)
  Future<CartValidationResult> validateCart(String userId) async {
    try {
      final cart = await getCart(userId);
      final validationErrors = <String>[];
      final updatedItems = <CartItem>[];

      for (final item in cart.items) {
        // Get latest product data
        final productDoc = await _firestore
            .collection(AppConstants.productsCollection)
            .doc(item.productId)
            .get();

        if (!productDoc.exists) {
          validationErrors.add('Product ${item.product.name} is no longer available');
          continue;
        }

        final latestProduct = Product.fromJson({
          ...productDoc.data()!,
          'id': productDoc.id,
        });

        // Check if product is still in stock
        if (!latestProduct.inStock || latestProduct.quantity < item.quantity) {
          if (!latestProduct.inStock) {
            validationErrors.add('${latestProduct.name} is out of stock');
          } else {
            validationErrors.add(
              '${latestProduct.name} only has ${latestProduct.quantity} items available',
            );
            // Update quantity to available stock
            updatedItems.add(item.copyWith(
              quantity: latestProduct.quantity,
              product: latestProduct,
              price: latestProduct.price,
            ));
          }
          continue;
        }

        // Check if price has changed
        if (item.price != latestProduct.price) {
          validationErrors.add(
            'Price for ${latestProduct.name} has changed from \$${item.price.toStringAsFixed(2)} to \$${latestProduct.price.toStringAsFixed(2)}',
          );
        }

        // Add updated item
        updatedItems.add(item.copyWith(
          product: latestProduct,
          price: latestProduct.price,
        ));
      }

      // Update cart with validated items if there were changes
      if (updatedItems.length != cart.items.length || 
          updatedItems.any((item) => 
            cart.items.firstWhere((original) => original.id == item.id).price != item.price ||
            cart.items.firstWhere((original) => original.id == item.id).quantity != item.quantity
          )) {
        final updatedCart = cart.copyWith(
          items: updatedItems,
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection(AppConstants.cartsCollection)
            .doc(userId)
            .update(updatedCart.toJson());

        return CartValidationResult(
          isValid: validationErrors.isEmpty,
          errors: validationErrors,
          updatedCart: updatedCart,
        );
      }

      return CartValidationResult(
        isValid: validationErrors.isEmpty,
        errors: validationErrors,
        updatedCart: cart,
      );
    } catch (e) {
      throw Exception('Failed to validate cart: ${e.toString()}');
    }
  }

  // Calculate shipping cost
  Future<double> calculateShipping({
    required Cart cart,
    required String address,
  }) async {
    try {
      // This is a simplified shipping calculation
      // In a real app, you would integrate with shipping providers
      
      if (cart.subtotal >= 100) {
        return 0.0; // Free shipping over $100
      }
      
      return 10.0; // Standard shipping rate
    } catch (e) {
      return 10.0; // Default shipping cost
    }
  }

  // Calculate tax
  Future<double> calculateTax({
    required Cart cart,
    required String address,
  }) async {
    try {
      // This is a simplified tax calculation
      // In a real app, you would use proper tax calculation services
      
      return cart.subtotal * 0.1; // 10% tax rate
    } catch (e) {
      return cart.subtotal * 0.1; // Default tax rate
    }
  }
}

class CartValidationResult {
  final bool isValid;
  final List<String> errors;
  final Cart updatedCart;

  CartValidationResult({
    required this.isValid,
    required this.errors,
    required this.updatedCart,
  });
}
