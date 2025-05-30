import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:souq/models/category.dart';
import 'package:souq/models/product.dart';
import 'package:souq/models/offer.dart';
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
    } catch (e, stackTrace) {
      if (!_mounted) return;
      state = AsyncValue.error(e, stackTrace);
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
    } catch (e, stackTrace) {
      if (!_mounted) return;
      state = AsyncValue.error(e, stackTrace);
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
    } catch (e, stackTrace) {
      if (!_mounted) return;
      state = AsyncValue.error(e, stackTrace);
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
    } catch (e, stackTrace) {
      if (!_mounted) return;
      state = AsyncValue.error(e, stackTrace);
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
    } catch (e, stackTrace) {
      if (!_mounted) return;
      state = AsyncValue.error(e, stackTrace);
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

class CategoryNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final ProductService _productService;

  CategoryNotifier(this._productService) : super(const AsyncValue.loading());

  Future<void> fetchCategories() async {
    state = const AsyncValue.loading();
    print('Fetching categories...');
    try {
      final categories = await _productService.getCategories();
      state = AsyncValue.data(categories);
    } catch (e, stack) {
      print('Error fetching categories: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> fetchParentCategories() async {
    state = const AsyncValue.loading();
    try {
      final categories = await _productService.getParentCategories();
      state = AsyncValue.data(categories);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> fetchSubcategories(String parentCategoryId) async {
    state = const AsyncValue.loading();
    try {
      final categories = await _productService.getSubcategories(parentCategoryId);
      state = AsyncValue.data(categories);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final categoryProvider = StateNotifierProvider<CategoryNotifier, AsyncValue<List<Category>>>((ref) {
  final productService = ref.watch(productServiceProvider);
  return CategoryNotifier(productService);
});
