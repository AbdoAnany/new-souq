/// Migration helper for gradually transitioning from old providers to new clean architecture providers
/// This file provides backward compatibility during the migration process

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/offer.dart';

// Re-export new clean architecture providers with legacy names for backward compatibility
export '../../presentation/providers/product_provider.dart';

// Legacy provider aliases for smooth migration
// These can be gradually replaced throughout the codebase

/// Legacy alias for featuredProductsProvider
final productsProvider = featuredProductsProvider;

/// Legacy alias for productDetailProvider
final productDetailsProvider = productDetailProvider;

/// Legacy alias for categoriesProvider (already same name)
// final categoryProvider = categoriesProvider;

/// Legacy alias for offersProvider (already same name)  
// final offerProvider = offersProvider;

// Migration notes:
// 1. Replace all instances of `productsProvider` with `featuredProductsProvider`
// 2. Replace all instances of `productDetailsProvider` with `productDetailProvider` 
// 3. Update screens to use new provider methods:
//    - `loadFeaturedProducts()` instead of `fetchFeaturedProducts()`
//    - `loadProduct(productId)` instead of `fetchProductDetails(productId)`
//    - `loadCategories()` instead of `fetchCategories()`
//    - `loadOffers()` instead of `fetchOffers()`
// 4. Use Result pattern for error handling instead of AsyncValue.error
// 5. Leverage new features like pagination, search, and responsive design

/// Helper functions for common operations during migration
class ProductProviderMigrationHelper {
  /// Get featured products with error handling
  static Future<List<Product>> getFeaturedProducts(WidgetRef ref) async {
    final asyncValue = ref.read(featuredProductsProvider);
    return asyncValue.when(
      data: (products) => products,
      loading: () => <Product>[],
      error: (error, stack) => <Product>[],
    );
  }

  /// Get product by ID with error handling
  static Future<Product?> getProductById(WidgetRef ref, String productId) async {
    final asyncValue = ref.read(productDetailProvider(productId));
    return asyncValue.when(
      data: (product) => product,
      loading: () => null,
      error: (error, stack) => null,
    );
  }

  /// Get categories with error handling
  static Future<List<Category>> getCategories(WidgetRef ref) async {
    final asyncValue = ref.read(categoriesProvider);
    return asyncValue.when(
      data: (categories) => categories,
      loading: () => <Category>[],
      error: (error, stack) => <Category>[],
    );
  }

  /// Get offers with error handling
  static Future<List<Offer>> getOffers(WidgetRef ref) async {
    final asyncValue = ref.read(offersProvider);
    return asyncValue.when(
      data: (offers) => offers,
      loading: () => <Offer>[],
      error: (error, stack) => <Offer>[],
    );
  }
}
