import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/result.dart';
import '../../core/failure.dart';
import '../../data/providers/repository_providers.dart';
import '../../domain/usecases/wishlist_usecases.dart';

/// Wishlist state for managing wishlist data and operations
class WishlistState {
  final List<String> productIds;
  final bool isLoading;
  final String? error;
  final bool isUpdating;

  const WishlistState({
    this.productIds = const [],
    this.isLoading = false,
    this.error,
    this.isUpdating = false,
  });

  WishlistState copyWith({
    List<String>? productIds,
    bool? isLoading,
    String? error,
    bool? isUpdating,
  }) {
    return WishlistState(
      productIds: productIds ?? this.productIds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  bool get hasError => error != null;
  bool get hasData => productIds.isNotEmpty;
  int get itemCount => productIds.length;
  bool get isEmpty => productIds.isEmpty;
}

/// Wishlist provider for managing wishlist state and operations
class WishlistNotifier extends StateNotifier<WishlistState> {
  final GetWishlistUseCase _getWishlistUseCase;
  final AddToWishlistUseCase _addToWishlistUseCase;
  final RemoveFromWishlistUseCase _removeFromWishlistUseCase;
  final ClearWishlistUseCase _clearWishlistUseCase;  final IsInWishlistUseCase _isInWishlistUseCase;
  final ToggleWishlistUseCase _toggleWishlistUseCase;
  WishlistNotifier({
    required GetWishlistUseCase getWishlistUseCase,
    required AddToWishlistUseCase addToWishlistUseCase,
    required RemoveFromWishlistUseCase removeFromWishlistUseCase,
    required ClearWishlistUseCase clearWishlistUseCase,
    required IsInWishlistUseCase isInWishlistUseCase,
    required ToggleWishlistUseCase toggleWishlistUseCase,
  })  : _getWishlistUseCase = getWishlistUseCase,
        _addToWishlistUseCase = addToWishlistUseCase,
        _removeFromWishlistUseCase = removeFromWishlistUseCase,
        _clearWishlistUseCase = clearWishlistUseCase,
        _isInWishlistUseCase = isInWishlistUseCase,
        _toggleWishlistUseCase = toggleWishlistUseCase,
        super(const WishlistState());
  /// Load wishlist for user
  Future<void> loadWishlist(String userId) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    final result = await _getWishlistUseCase.call(userId);
    
    result.fold(
      (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.toString(),
        );
        if (kDebugMode) {
          print('Error loading wishlist: $error');
        }
      },
      (wishlist) {
        // Extract productIds from Wishlist entity
        final productIds = wishlist.items.map((item) => item.productId).toList();
        state = state.copyWith(
          productIds: productIds,
          isLoading: false,
        );
      },
    );
  }

  /// Add item to wishlist
  Future<bool> addToWishlist({
    required String userId,
    required String productId,
  }) async {
    if (state.isUpdating) return false;

    state = state.copyWith(isUpdating: true, error: null);

    final result = await _addToWishlistUseCase.call(
      AddToWishlistParams(
        userId: userId,
        productId: productId,
      ),
    );    return result.fold(
      (error) {
        state = state.copyWith(
          isUpdating: false,
          error: error.toString(),
        );
        if (kDebugMode) {
          print('Error adding to wishlist: $error');
        }
        return false;
      },
      (_) {
        final updatedProductIds = List<String>.from(state.productIds);
        if (!updatedProductIds.contains(productId)) {
          updatedProductIds.add(productId);
        }
        
        state = state.copyWith(
          productIds: updatedProductIds,
          isUpdating: false,
        );
        return true;
      },
    );
  }

  /// Remove item from wishlist
  Future<bool> removeFromWishlist({
    required String userId,
    required String productId,
  }) async {
    if (state.isUpdating) return false;

    state = state.copyWith(isUpdating: true, error: null);

    final result = await _removeFromWishlistUseCase.call(
      RemoveFromWishlistParams(
        userId: userId,
        productId: productId,
      ),
    );    return result.fold(
      (error) {
        state = state.copyWith(
          isUpdating: false,
          error: error.toString(),
        );
        if (kDebugMode) {
          print('Error removing from wishlist: $error');
        }
        return false;
      },
      (_) {
        final updatedProductIds = List<String>.from(state.productIds);
        updatedProductIds.remove(productId);
        
        state = state.copyWith(
          productIds: updatedProductIds,
          isUpdating: false,
        );
        return true;
      },
    );
  }

  /// Toggle wishlist status for a product
  Future<bool> toggleWishlist({
    required String userId,
    required String productId,
  }) async {
    if (state.isUpdating) return false;

    state = state.copyWith(isUpdating: true, error: null);

    final result = await _toggleWishlistUseCase.call(userId, productId);    return result.fold(
      (error) {
        state = state.copyWith(
          isUpdating: false,
          error: error.toString(),
        );
        if (kDebugMode) {
          print('Error toggling wishlist: $error');
        }
        return false;
      },
      (isInWishlist) {
        final updatedProductIds = List<String>.from(state.productIds);
        
        if (isInWishlist) {
          if (!updatedProductIds.contains(productId)) {
            updatedProductIds.add(productId);
          }
        } else {
          updatedProductIds.remove(productId);
        }
        
        state = state.copyWith(
          productIds: updatedProductIds,
          isUpdating: false,
        );
        return isInWishlist;
      },
    );
  }

  /// Clear wishlist
  Future<bool> clearWishlist(String userId) async {
    if (state.isUpdating) return false;

    state = state.copyWith(isUpdating: true, error: null);

    final result = await _clearWishlistUseCase.call(userId);    return result.fold(
      (error) {
        state = state.copyWith(
          isUpdating: false,
          error: error.toString(),
        );
        if (kDebugMode) {
          print('Error clearing wishlist: $error');
        }
        return false;
      },
      (_) {
        state = state.copyWith(
          productIds: [],
          isUpdating: false,
        );
        return true;
      },
    );
  }
  /// Check if product is in wishlist synchronously (from local state)
  bool isInWishlist(String productId) {
    return state.productIds.contains(productId);
  }

  /// Check if product is in wishlist asynchronously (from remote)
  Future<Result<bool, Failure>> checkIsInWishlist({
    required String userId,
    required String productId,
  }) async {
    return await _isInWishlistUseCase.call(
      IsInWishlistParams(
        userId: userId,
        productId: productId,
      ),
    );
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Use case providers
final getWishlistUseCaseProvider = Provider<GetWishlistUseCase>((ref) {
  return GetWishlistUseCase(ref.read(wishlistRepositoryProvider));
});

final addToWishlistUseCaseProvider = Provider<AddToWishlistUseCase>((ref) {
  return AddToWishlistUseCase(ref.read(wishlistRepositoryProvider));
});

final removeFromWishlistUseCaseProvider = Provider<RemoveFromWishlistUseCase>((ref) {
  return RemoveFromWishlistUseCase(ref.read(wishlistRepositoryProvider));
});

final clearWishlistUseCaseProvider = Provider<ClearWishlistUseCase>((ref) {
  return ClearWishlistUseCase(ref.read(wishlistRepositoryProvider));
});

final isInWishlistUseCaseProvider = Provider<IsInWishlistUseCase>((ref) {
  return IsInWishlistUseCase(ref.read(wishlistRepositoryProvider));
});

final toggleWishlistUseCaseProvider = Provider<ToggleWishlistUseCase>((ref) {
  return ToggleWishlistUseCase(ref.read(wishlistRepositoryProvider));
});

/// Main wishlist provider
final wishlistProvider = StateNotifierProvider<WishlistNotifier, WishlistState>((ref) {  return WishlistNotifier(
    getWishlistUseCase: ref.read(getWishlistUseCaseProvider),
    addToWishlistUseCase: ref.read(addToWishlistUseCaseProvider),
    removeFromWishlistUseCase: ref.read(removeFromWishlistUseCaseProvider),
    clearWishlistUseCase: ref.read(clearWishlistUseCaseProvider),
    isInWishlistUseCase: ref.read(isInWishlistUseCaseProvider),
    toggleWishlistUseCase: ref.read(toggleWishlistUseCaseProvider),
  );
});

/// Wishlist summary provider for quick access to wishlist stats
final wishlistSummaryProvider = Provider<Map<String, dynamic>>((ref) {
  final wishlistState = ref.watch(wishlistProvider);
  
  return {
    'itemCount': wishlistState.itemCount,
    'isEmpty': wishlistState.isEmpty,
    'isLoading': wishlistState.isLoading,
    'hasError': wishlistState.hasError,
  };
});

/// Provider to check if a specific product is in wishlist
final isProductInWishlistProvider = Provider.family<bool, String>((ref, productId) {
  final wishlistState = ref.watch(wishlistProvider);
  return wishlistState.productIds.contains(productId);
});
