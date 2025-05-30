import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/product_service.dart';
import '../models/product.dart';
import '../models/category.dart' as model;
import '../models/offer.dart';
import '../core/result.dart';
import '../core/failure.dart';

class ProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final ProductService _productService;
  bool _mounted = true;

  ProductsNotifier(this._productService) : super(const AsyncValue.loading()) {
    fetchFeaturedProducts();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }
  Future<void> fetchFeaturedProducts() async {
    if (!_mounted) return;
    state = const AsyncValue.loading();
    
    try {
      final result = await _productService.getFeaturedProducts();
      if (!_mounted) return;
      
      result.fold(
        (failure) {
          state = AsyncValue.error(failure, StackTrace.current);
          if (kDebugMode) {
            print('Error loading featured products: $failure');
          }
        },
        (products) => state = AsyncValue.data(products),
      );
    } catch (e, stackTrace) {
      if (!_mounted) return;
      state = AsyncValue.error(e, stackTrace);
    }
  }
  Future<void> fetchProductsByCategory(String categoryId) async {
    if (!_mounted) return;
    state = const AsyncValue.loading();
    
    try {
      final result = await _productService.getProductsByCategory(
        categoryId: categoryId,
      );
      if (!_mounted) return;
      
      result.fold(
        (failure) {
          state = AsyncValue.error(failure, StackTrace.current);
          if (kDebugMode) {
            print('Error loading products by category: $failure');
          }
        },
        (products) => state = AsyncValue.data(products),
      );
    } catch (e, stackTrace) {
      if (!_mounted) return;
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    await fetchFeaturedProducts();
  }
}

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

final productsProvider = StateNotifierProvider<ProductsNotifier, AsyncValue<List<Product>>>((ref) {
  final productService = ref.watch(productServiceProvider);
  return ProductsNotifier(productService);
});
