import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:souq/models/product.dart';
import 'package:souq/services/wishlist_service.dart';

class WishlistNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final WishlistService _wishlistService;
  
  WishlistNotifier(this._wishlistService) : super(const AsyncValue.loading()) {
    loadWishlist();
  }

  Future<void> loadWishlist() async {
    try {
      state = const AsyncValue.loading();
      final products = await _wishlistService.getWishlistProducts();
      state = AsyncValue.data(products);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addToWishlist(String productId) async {
    try {
      await _wishlistService.addToWishlist(productId);
      // Reload wishlist
      loadWishlist();
    } catch (e) {
      // Let the error propagate to the UI
      rethrow;
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    try {
      await _wishlistService.removeFromWishlist(productId);
      
      // Update the state optimistically
      state.whenData((products) {
        state = AsyncValue.data(
          products.where((product) => product.id != productId).toList(),
        );
      });
    } catch (e) {
      // Reload wishlist in case of error
      loadWishlist();
      rethrow;
    }
  }

  Future<void> clearWishlist() async {
    try {
      await _wishlistService.clearWishlist();
      state = const AsyncValue.data([]);
    } catch (e) {
      // Let the error propagate to the UI
      rethrow;
    }
  }
}

class ProductInWishlistNotifier extends StateNotifier<AsyncValue<bool>> {
  final WishlistService _wishlistService;
  final String productId;

  ProductInWishlistNotifier(this._wishlistService, this.productId)
      : super(const AsyncValue.loading()) {
    checkIfInWishlist();
  }

  Future<void> checkIfInWishlist() async {
    try {
      state = const AsyncValue.loading();
      final isInWishlist = await _wishlistService.isInWishlist(productId);
      state = AsyncValue.data(isInWishlist);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleWishlistStatus() async {
    state.whenData((isInWishlist) async {
      try {
        if (isInWishlist) {
          await _wishlistService.removeFromWishlist(productId);
          state = const AsyncValue.data(false);
        } else {
          await _wishlistService.addToWishlist(productId);
          state = const AsyncValue.data(true);
        }
      } catch (e, stack) {
        state = AsyncValue.error(e, stack);
      }
    });
  }
}

final wishlistServiceProvider = Provider<WishlistService>((ref) {
  return WishlistService();
});

final wishlistProvider = StateNotifierProvider<WishlistNotifier, AsyncValue<List<Product>>>((ref) {
  final wishlistService = ref.watch(wishlistServiceProvider);
  return WishlistNotifier(wishlistService);
});

final productInWishlistProvider = StateNotifierProvider.family<ProductInWishlistNotifier, AsyncValue<bool>, String>((ref, productId) {
  final wishlistService = ref.watch(wishlistServiceProvider);
  return ProductInWishlistNotifier(wishlistService, productId);
});
