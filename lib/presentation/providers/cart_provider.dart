import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/result.dart';
import '../../core/config/app_config.dart';
import '../../data/providers/repository_providers.dart';
import '../../domain/usecases/cart_usecases.dart';
import '../../models/cart.dart';
import '../../models/product.dart';

/// Cart state for managing cart data and operations
class CartState {
  final Cart? cart;
  final bool isLoading;
  final String? error;
  final bool isUpdating;

  const CartState({
    this.cart,
    this.isLoading = false,
    this.error,
    this.isUpdating = false,
  });

  CartState copyWith({
    Cart? cart,
    bool? isLoading,
    String? error,
    bool? isUpdating,
  }) {
    return CartState(
      cart: cart ?? this.cart,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  bool get hasError => error != null;
  bool get hasData => cart != null;
  int get itemCount => cart?.items.length ?? 0;
  double get totalAmount => cart?.total ?? 0.0;
  bool get isEmpty => cart?.items.isEmpty ?? true;
}

/// Cart provider for managing cart state and operations
class CartNotifier extends StateNotifier<CartState> {
  final GetCartUseCase _getCartUseCase;
  final AddToCartUseCase _addToCartUseCase;
  final UpdateCartItemUseCase _updateCartItemUseCase;
  final RemoveFromCartUseCase _removeFromCartUseCase;
  final ClearCartUseCase _clearCartUseCase;
  final WatchCartUseCase _watchCartUseCase;

  CartNotifier({
    required GetCartUseCase getCartUseCase,
    required AddToCartUseCase addToCartUseCase,
    required UpdateCartItemUseCase updateCartItemUseCase,
    required RemoveFromCartUseCase removeFromCartUseCase,
    required ClearCartUseCase clearCartUseCase,
    required WatchCartUseCase watchCartUseCase,
  })  : _getCartUseCase = getCartUseCase,
        _addToCartUseCase = addToCartUseCase,
        _updateCartItemUseCase = updateCartItemUseCase,
        _removeFromCartUseCase = removeFromCartUseCase,
        _clearCartUseCase = clearCartUseCase,
        _watchCartUseCase = watchCartUseCase,
        super(const CartState());

  /// Load cart for user
  Future<void> loadCart(String userId) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    final result = await _getCartUseCase.call(userId);

    result.fold(
      onSuccess: (cart) {
        state = state.copyWith(
          cart: cart,
          isLoading: false,
        );
      },
      onFailure: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.toString(),
        );
        if (kDebugMode) {
          print('Error loading cart: $error');
        }
      },
    );
  }

  /// Watch cart changes in real-time
  void watchCart(String userId) {
    _watchCartUseCase.call(userId).listen(
      (cart) {
        if (!mounted) return;
        state = state.copyWith(cart: cart);
      },
      onError: (error) {
        if (!mounted) return;
        state = state.copyWith(error: error.toString());
        if (kDebugMode) {
          print('Error watching cart: $error');
        }
      },
    );
  }

  /// Add item to cart
  Future<bool> addToCart({
    required String userId,
    required String productId,
    int quantity = 1,
  }) async {
    if (state.isUpdating) return false;

    state = state.copyWith(isUpdating: true, error: null);

    final result = await _addToCartUseCase.call(
      AddToCartParams(
        userId: userId,
        productId: productId,
        quantity: quantity,
      ),
    );

    return result.fold(
      onSuccess: (cart) {
        state = state.copyWith(
          cart: cart,
          isUpdating: false,
        );
        return true;
      },
      onFailure: (error) {
        state = state.copyWith(
          isUpdating: false,
          error: error.toString(),
        );
        if (kDebugMode) {
          print('Error adding to cart: $error');
        }
        return false;
      },
    );
  }

  /// Update cart item quantity
  Future<bool> updateCartItem({
    required String userId,
    required String productId,
    required int quantity,
  }) async {
    if (state.isUpdating) return false;

    state = state.copyWith(isUpdating: true, error: null);

    final result = await _updateCartItemUseCase.call(
      UpdateCartItemParams(
        userId: userId,
        productId: productId,
        quantity: quantity,
      ),
    );

    return result.fold(
      onSuccess: (cart) {
        state = state.copyWith(
          cart: cart,
          isUpdating: false,
        );
        return true;
      },
      onFailure: (error) {
        state = state.copyWith(
          isUpdating: false,
          error: error.toString(),
        );
        if (kDebugMode) {
          print('Error updating cart item: $error');
        }
        return false;
      },
    );
  }

  /// Remove item from cart
  Future<bool> removeFromCart({
    required String userId,
    required String productId,
  }) async {
    if (state.isUpdating) return false;

    state = state.copyWith(isUpdating: true, error: null);

    final result = await _removeFromCartUseCase.call(
      RemoveFromCartParams(
        userId: userId,
        productId: productId,
      ),
    );

    return result.fold(
      onSuccess: (cart) {
        state = state.copyWith(
          cart: cart,
          isUpdating: false,
        );
        return true;
      },
      onFailure: (error) {
        state = state.copyWith(
          isUpdating: false,
          error: error.toString(),
        );
        if (kDebugMode) {
          print('Error removing from cart: $error');
        }
        return false;
      },
    );
  }

  /// Clear cart
  Future<bool> clearCart(String userId) async {
    if (state.isUpdating) return false;

    state = state.copyWith(isUpdating: true, error: null);

    final result = await _clearCartUseCase.call(userId);

    return result.fold(
      onSuccess: (_) {
        state = state.copyWith(
          cart: Cart(
            id: userId,
            userId: userId,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          isUpdating: false,
        );
        return true;
      },
      onFailure: (error) {
        state = state.copyWith(
          isUpdating: false,
          error: error.toString(),
        );
        if (kDebugMode) {
          print('Error clearing cart: $error');
        }
        return false;
      },
    );
  }

  /// Get cart item quantity for a specific product
  int getItemQuantity(String productId) {
    if (state.cart == null) return 0;
    
    final item = state.cart!.items.firstWhere(
      (item) => item.productId == productId,
      orElse: () => CartItem(
        id: '',
        productId: '',
        product: Product.empty(),
        quantity: 0,
        price: 0,
        addedAt: DateTime.now(),
      ),
    );
    
    return item.quantity;
  }

  /// Check if product is in cart
  bool isInCart(String productId) {
    return getItemQuantity(productId) > 0;
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Use case providers
final getCartUseCaseProvider = Provider<GetCartUseCase>((ref) {
  return GetCartUseCase(ref.read(cartRepositoryProvider));
});

final addToCartUseCaseProvider = Provider<AddToCartUseCase>((ref) {
  return AddToCartUseCase(ref.read(cartRepositoryProvider));
});

final updateCartItemUseCaseProvider = Provider<UpdateCartItemUseCase>((ref) {
  return UpdateCartItemUseCase(ref.read(cartRepositoryProvider));
});

final removeFromCartUseCaseProvider = Provider<RemoveFromCartUseCase>((ref) {
  return RemoveFromCartUseCase(ref.read(cartRepositoryProvider));
});

final clearCartUseCaseProvider = Provider<ClearCartUseCase>((ref) {
  return ClearCartUseCase(ref.read(cartRepositoryProvider));
});

final watchCartUseCaseProvider = Provider<WatchCartUseCase>((ref) {
  return WatchCartUseCase(ref.read(cartRepositoryProvider));
});

/// Main cart provider
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(
    getCartUseCase: ref.read(getCartUseCaseProvider),
    addToCartUseCase: ref.read(addToCartUseCaseProvider),
    updateCartItemUseCase: ref.read(updateCartItemUseCaseProvider),
    removeFromCartUseCase: ref.read(removeFromCartUseCaseProvider),
    clearCartUseCase: ref.read(clearCartUseCaseProvider),
    watchCartUseCase: ref.read(watchCartUseCaseProvider),
  );
});

/// Cart summary provider for quick access to cart totals
final cartSummaryProvider = Provider<Map<String, dynamic>>((ref) {
  final cartState = ref.watch(cartProvider);
  
  return {
    'itemCount': cartState.itemCount,
    'totalAmount': cartState.totalAmount,
    'isEmpty': cartState.isEmpty,
    'isLoading': cartState.isLoading,
    'hasError': cartState.hasError,
  };
});
