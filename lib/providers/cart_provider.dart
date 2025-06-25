import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:souq/models/cart.dart';
import 'package:souq/models/product.dart';
import 'package:souq/providers/auth_provider.dart';
import 'package:souq/services/cart_service.dart';

class CartNotifier extends StateNotifier<AsyncValue<Cart?>> {
  final CartService _cartService;
  final String? _userId;

  CartNotifier(this._cartService, this._userId)
      : super(const AsyncValue.loading()) {
    if (_userId != null) {
      fetchCart();
    } else {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> fetchCart() async {
    if (_userId == null) {
      state = const AsyncValue.data(null);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final cart = await _cartService.getCart(_userId);
      state = AsyncValue.data(cart);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addToCart(Product product, int quantity,
      {Map<String, dynamic>? variants}) async {
    if (_userId == null) {
      throw Exception('User must be logged in to add items to cart');
    }

    try {
      final updatedCart = await _cartService.addToCart(
        userId: _userId,
        product: product,
        quantity: quantity,
        selectedVariants: variants,
      );
      state = AsyncValue.data(updatedCart);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    if (_userId == null) return;

    try {
      final updatedCart = await _cartService.removeFromCart(
        userId: _userId,
        cartItemId: cartItemId,
      );
      state = AsyncValue.data(updatedCart);
    } catch (e) {
      // If removal fails, refresh the cart to get the current state
      await fetchCart();
      // Re-throw the error so UI can show appropriate message
      rethrow;
    }
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    if (_userId == null || quantity < 1) return;

    try {
      final updatedCart = await _cartService.updateCartItemQuantity(
        userId: _userId,
        cartItemId: cartItemId,
        quantity: quantity,
      );
      state = AsyncValue.data(updatedCart);
    } catch (e) {
      // If update fails, refresh the cart to get the current state
      await fetchCart();
      // Re-throw the error so UI can show appropriate message
      rethrow;
    }
  }

  Future<void> applyCoupon(String couponCode) async {
    if (_userId == null || couponCode.trim().isEmpty) return;

    try {
      final updatedCart = await _cartService.applyCoupon(
        userId: _userId,
        couponCode: couponCode,
      );
      state = AsyncValue.data(updatedCart);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> clearCart() async {
    if (_userId == null) return;

    try {
      final updatedCart = await _cartService.clearCart(_userId);
      state = AsyncValue.data(updatedCart);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  double get total {
    return state.when(
      data: (cart) {
        if (cart == null || cart.items.isEmpty) {
          return 0.0;
        }
        return cart.items
            .map((item) => item.totalPrice)
            .reduce((sum, price) => sum + price);
      },
      loading: () => 0.0,
      error: (_, __) => 0.0,
    );
  }

  int get itemCount => state.when(
        data: (cart) => cart?.items.length ?? 0,
        loading: () => 0,
        error: (_, __) => 0,
      );

  bool get isEmpty => itemCount == 0;

  CartItem? getItem(String productId) => state.when(
        data: (cart) {
          if (cart?.items == null) return null;
          try {
            return cart!.items
                .firstWhere((item) => item.productId == productId);
          } catch (e) {
            return null;
          }
        },
        loading: () => null,
        error: (_, __) => null,
      );

  bool hasProduct(String productId) => state.when(
        data: (cart) =>
            cart?.items.any((item) => item.productId == productId) ?? false,
        loading: () => false,
        error: (_, __) => false,
      );
}

final cartServiceProvider = Provider<CartService>((ref) {
  return CartService();
});

final cartProvider =
    StateNotifierProvider<CartNotifier, AsyncValue<Cart?>>((ref) {
  final cartService = ref.watch(cartServiceProvider);
  final authState = ref.watch(authProvider);
  final userId = authState.value?.id;
  return CartNotifier(cartService, userId);
});
