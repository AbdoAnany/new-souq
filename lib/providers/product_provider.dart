import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:souq/models/category.dart' as models;
import 'package:souq/models/offer.dart';
import 'package:souq/models/product.dart';
import 'package:souq/services/product_service.dart';

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
      final products = await _productService.getFeaturedProducts();
      if (!_mounted) return;
      state = AsyncValue.data(products);
      if (kDebugMode) {
        print('Featured products loaded: ${products.length}');
      }
    } catch (e, stackTrace) {
      if (!_mounted) return;
      state = AsyncValue.error(e, stackTrace);
      if (kDebugMode) {
        print('Error fetching featured products: $e');
      }
    }
  }

  Future<void> fetchProductsByCategory(String categoryId) async {
    if (!_mounted) return;
    state = const AsyncValue.loading();
    try {
      final products = await _productService.getProductsByCategory(
        categoryId: categoryId,
      );
      if (!_mounted) return;
      state = AsyncValue.data(products);
      if (kDebugMode) {
        print('Category products loaded: ${products.length}');
      }
    } catch (e, stackTrace) {
      if (!_mounted) return;
      state = AsyncValue.error(e, stackTrace);
      if (kDebugMode) {
        print('Error fetching products by category: $e');
      }
    }
  }
  
  Future<void> searchProducts(String searchQuery, {
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? sortBy,
  }) async {
    if (!_mounted) return;
    state = const AsyncValue.loading();
    try {
      final products = await _productService.searchProducts(
        query: searchQuery,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minRating: minRating,
        sortBy: sortBy,
      );
      if (!_mounted) return;
      state = AsyncValue.data(products);
      if (kDebugMode) {
        print('Search results loaded: ${products.length}');
      }
    } catch (e, stackTrace) {
      if (!_mounted) return;
      state = AsyncValue.error(e, stackTrace);
      if (kDebugMode) {
        print('Error searching products: $e');
      }
    }
  }
}

class OfferNotifier extends StateNotifier<AsyncValue<List<Offer>>> {
  final ProductService _productService;
  bool _mounted = true;

  OfferNotifier(this._productService) : super(const AsyncValue.loading()) {
    fetchOffers();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> fetchOffers() async {
    if (!_mounted) return;
    state = const AsyncValue.loading();
    try {
      final offers = await _productService.getActiveOffers();
      if (!_mounted) return;
      state = AsyncValue.data(offers);
      if (kDebugMode) {
        print('Offers loaded: ${offers.length}');
      }    } catch (e, stackTrace) {
      if (!_mounted) return;
      state = AsyncValue.error(e, stackTrace);
      if (kDebugMode) {
        print('Error fetching offers: $e');
      }
    }
  }
}

class ProductDetailNotifier extends StateNotifier<AsyncValue<Product?>> {
  final ProductService _productService;
  bool _mounted = true;

  ProductDetailNotifier(this._productService) : super(const AsyncValue.data(null));

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }
  Future<void> fetchProductDetails(String productId) async {
    if (!_mounted) return;
    state = const AsyncValue.loading();
    try {
      final product = await _productService.getProductById(productId);
      if (!_mounted) return;
      state = AsyncValue.data(product);
      if (kDebugMode) {
        print('Product details loaded: ${product?.name}');
      }
    } catch (e, stackTrace) {
      if (!_mounted) return;
      state = AsyncValue.error(e, stackTrace);
      if (kDebugMode) {
        print('Error fetching product details: $e');
      }
    }
  }
}

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

final productsProvider = StateNotifierProvider<ProductsNotifier, AsyncValue<List<Product>>>((ref) {
  final productService = ref.watch(productServiceProvider);
  return ProductsNotifier(productService);
});

final offerProvider = StateNotifierProvider<OfferNotifier, AsyncValue<List<Offer>>>((ref) {
  final productService = ref.watch(productServiceProvider);
  return OfferNotifier(productService);
});

final productDetailsProvider = StateNotifierProvider.family<ProductDetailNotifier, AsyncValue<Product?>, String>((ref, productId) {
  final productService = ref.watch(productServiceProvider);
  final notifier = ProductDetailNotifier(productService);
  notifier.fetchProductDetails(productId);
  return notifier;
});

class CategoryNotifier extends StateNotifier<AsyncValue<List<models.Category>>> {
  final ProductService _productService;
  bool _mounted = true;

  CategoryNotifier(this._productService) : super(const AsyncValue.loading()) {
    fetchCategories();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> fetchCategories() async {
    if (!_mounted) return;
    state = const AsyncValue.loading();
    
    try {
      final categories = await _productService.getCategories();
      if (!_mounted) return;
      
      if (kDebugMode) {
        print('Categories loaded: ${categories.length}');
      }
      state = AsyncValue.data(categories);
    } catch (e, stackTrace) {
      if (!_mounted) return;
      state = AsyncValue.error(e, stackTrace);
      if (kDebugMode) {
        print('Error fetching categories: $e');
      }
    }
  }

  Future<void> fetchParentCategories() async {
    if (!_mounted) return;
    state = const AsyncValue.loading();
    
    try {
      final categories = await _productService.getParentCategories();
      if (!_mounted) return;
      state = AsyncValue.data(categories);
    } catch (e, stackTrace) {
      if (!_mounted) return;
      state = AsyncValue.error(e, stackTrace);
      if (kDebugMode) {
        print('Error fetching parent categories: $e');
      }
    }
  }

  Future<void> fetchSubcategories(String parentCategoryId) async {
    if (!_mounted) return;
    state = const AsyncValue.loading();
    
    try {
      final categories = await _productService.getSubcategories(parentCategoryId);
      if (!_mounted) return;
      state = AsyncValue.data(categories);
    } catch (e, stackTrace) {
      if (!_mounted) return;
      state = AsyncValue.error(e, stackTrace);
      if (kDebugMode) {
        print('Error fetching subcategories: $e');
      }
    }
  }

  Future<void> refresh() async {
    await fetchCategories();
  }
}

final categoryProvider = StateNotifierProvider<CategoryNotifier, AsyncValue<List<models.Category>>>((ref) {
  final productService = ref.watch(productServiceProvider);
  final notifier = CategoryNotifier(productService);
  return notifier;
});

// Family provider for subcategories
final subcategoriesProvider = StateNotifierProvider.family<SubcategoryNotifier, AsyncValue<List<models.Category>>, String>((ref, parentCategoryId) {
  final productService = ref.watch(productServiceProvider);
  final notifier = SubcategoryNotifier(productService);
  notifier.fetchSubcategories(parentCategoryId);
  return notifier;
});

class SubcategoryNotifier extends StateNotifier<AsyncValue<List<models.Category>>> {
  final ProductService _productService;
  bool _mounted = true;

  SubcategoryNotifier(this._productService) : super(const AsyncValue.loading());

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> fetchSubcategories(String parentCategoryId) async {
    if (!_mounted) return;
    state = const AsyncValue.loading();
    
    try {
      final categories = await _productService.getSubcategories(parentCategoryId);
      if (!_mounted) return;
      state = AsyncValue.data(categories);
    } catch (e, stackTrace) {
      if (!_mounted) return;
      state = AsyncValue.error(e, stackTrace);
      if (kDebugMode) {
        print('Error fetching subcategories: $e');
      }
    }
  }
}

// Family provider for category products
final categoryProductsProvider = StateNotifierProvider.family<CategoryProductsNotifier, AsyncValue<List<Product>>, String>((ref, categoryId) {
  final productService = ref.watch(productServiceProvider);
  final notifier = CategoryProductsNotifier(productService);
  notifier.fetchProductsByCategory(categoryId);
  return notifier;
});

class CategoryProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final ProductService _productService;
  bool _mounted = true;

  CategoryProductsNotifier(this._productService) : super(const AsyncValue.loading());

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> fetchProductsByCategory(String categoryId, {
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? sortBy,
  }) async {
    if (!_mounted) return;
    state = const AsyncValue.loading();
    
    try {
      final products = await _productService.getProductsByCategory(
        categoryId: categoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minRating: minRating,
        sortBy: sortBy,
      );
      if (!_mounted) return;
      state = AsyncValue.data(products);
    } catch (e, stackTrace) {
      if (!_mounted) return;
      state = AsyncValue.error(e, stackTrace);
      if (kDebugMode) {
        print('Error fetching products for category: $e');
      }
    }
  }

  Future<void> loadMore(String categoryId, String lastProductId, {
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? sortBy,
  }) async {
    if (!_mounted) return;
    
    final currentState = state;
    if (currentState is! AsyncData<List<Product>>) return;
    
    try {
      final moreProducts = await _productService.getProductsByCategory(
        categoryId: categoryId,
        lastProductId: lastProductId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minRating: minRating,
        sortBy: sortBy,
      );
      
      if (!_mounted) return;
        final allProducts = [...currentState.value, ...moreProducts];
      state = AsyncValue.data(allProducts);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading more products: $e');
      }
      // Don't change state on load more error, just log it
    }
  }
}

// Family provider for related products
final relatedProductsProvider = StateNotifierProvider.family<RelatedProductsNotifier, AsyncValue<List<Product>>, RelatedProductsParams>((ref, params) {
  final productService = ref.watch(productServiceProvider);
  final notifier = RelatedProductsNotifier(productService);
  notifier.fetchRelatedProducts(params.productId, params.categoryId);
  return notifier;
});

class RelatedProductsParams {
  final String productId;
  final String categoryId;
  
  RelatedProductsParams({required this.productId, required this.categoryId});
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RelatedProductsParams &&
          runtimeType == other.runtimeType &&
          productId == other.productId &&
          categoryId == other.categoryId;

  @override
  int get hashCode => productId.hashCode ^ categoryId.hashCode;
}

class RelatedProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final ProductService _productService;
  bool _mounted = true;

  RelatedProductsNotifier(this._productService) : super(const AsyncValue.loading());

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> fetchRelatedProducts(String productId, String categoryId, {int limit = 6}) async {
    if (!_mounted) return;
    state = const AsyncValue.loading();
    
    try {
      final products = await _productService.getRelatedProducts(
        productId: productId,
        categoryId: categoryId,
        limit: limit,
      );
      if (!_mounted) return;
      state = AsyncValue.data(products);
    } catch (e, stackTrace) {
      if (!_mounted) return;
      state = AsyncValue.error(e, stackTrace);
      if (kDebugMode) {
        print('Error fetching related products: $e');
      }
    }
  }
}
