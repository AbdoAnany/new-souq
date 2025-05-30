import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/responsive_helper.dart';
import '../../data/providers/repository_providers.dart';
import '../../domain/usecases/product_usecases.dart';
import '../../domain/usecases/category_usecases.dart';
import '../../domain/usecases/offer_usecases.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/offer.dart';

// Repository Provider (imported from data layer)
// Use the repository providers from data layer

// Use Case Providers
final getFeaturedProductsProvider = Provider<GetFeaturedProducts>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetFeaturedProducts(repository);
});

final getProductByIdProvider = Provider<GetProductById>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetProductById(repository);
});

final searchProductsProvider = Provider<SearchProducts>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return SearchProducts(repository);
});

final getProductsByCategoryProvider = Provider<GetProductsByCategory>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetProductsByCategory(repository);
});

final getNewArrivalsProvider = Provider<GetNewArrivals>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetNewArrivals(repository);
});

final getRelatedProductsProvider = Provider<GetRelatedProducts>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetRelatedProducts(repository);
});

// Category Use Case Providers
final getCategoriesProvider = Provider<GetCategories>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return GetCategories(repository);
});

final getSubcategoriesProvider = Provider<GetSubcategories>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return GetSubcategories(repository);
});

// Offer Use Case Providers
final getActiveOffersProvider = Provider<GetActiveOffers>((ref) {
  final repository = ref.watch(offerRepositoryProvider);
  return GetActiveOffers(repository);
});

// State Notifiers
class FeaturedProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final GetFeaturedProducts _getFeaturedProducts;
  bool _mounted = true;

  FeaturedProductsNotifier(this._getFeaturedProducts) : super(const AsyncValue.loading()) {
    loadFeaturedProducts();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> loadFeaturedProducts() async {
    if (!_mounted) return;
    
    state = const AsyncValue.loading();
      try {
      final result = await _getFeaturedProducts();
      if (!_mounted) return;
      
      result.fold(
        (error) => state = AsyncValue.error(error, StackTrace.current),
        (products) => state = AsyncValue.data(products),
      );
    } catch (e, stackTrace) {
      if (!_mounted) return;
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    await loadFeaturedProducts();
  }
}

class ProductDetailNotifier extends StateNotifier<AsyncValue<Product?>> {
  final GetProductById _getProductById;
  bool _mounted = true;

  ProductDetailNotifier(this._getProductById) : super(const AsyncValue.data(null));

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> loadProduct(String productId) async {
    if (!_mounted) return;
    
    state = const AsyncValue.loading();
    
    try {
      final result = await _getProductById(productId);
      if (!_mounted) return;
        result.fold(
        (error) => state = AsyncValue.error(error, StackTrace.current),
        (product) => state = AsyncValue.data(product),
      );
    } catch (e, stackTrace) {
      if (!_mounted) return;
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

class CategoryProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final GetProductsByCategory _getProductsByCategory;
  bool _mounted = true;
  String? _currentCategoryId;
  GetProductsByCategoryParams? _currentParams;

  CategoryProductsNotifier(this._getProductsByCategory) : super(const AsyncValue.data([]));

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> loadProducts(GetProductsByCategoryParams params) async {
    if (!_mounted) return;
    
    _currentCategoryId = params.categoryId;
    _currentParams = params;
    
    state = const AsyncValue.loading();
    
    try {
      final result = await _getProductsByCategory(params);
      if (!_mounted) return;
      
      result.fold(
        onSuccess: (products) => state = AsyncValue.data(products),
        onFailure: (error) => state = AsyncValue.error(error, StackTrace.current),
      );
    } catch (e, stackTrace) {
      if (!_mounted) return;
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> loadMoreProducts() async {
    if (!_mounted || _currentParams == null) return;
    
    final currentData = state.asData?.value;
    if (currentData == null) return;
    
    try {
      final nextPageParams = _currentParams!.copyWith(
        page: _currentParams!.page + 1,
      );
      
      final result = await _getProductsByCategory(nextPageParams);
      if (!_mounted) return;
      
      result.fold(
        onSuccess: (newProducts) {
          final updatedProducts = [...currentData, ...newProducts];
          state = AsyncValue.data(updatedProducts);
          _currentParams = nextPageParams;
        },
        onFailure: (error) => state = AsyncValue.error(error, StackTrace.current),
      );
    } catch (e, stackTrace) {
      if (!_mounted) return;
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    if (_currentParams != null) {
      final refreshParams = _currentParams!.copyWith(page: 1);
      await loadProducts(refreshParams);
    }
  }

  bool get hasMore {
    final currentData = state.asData?.value;
    if (currentData == null || _currentParams == null) return false;
    return currentData.length >= _currentParams!.page * _currentParams!.limit;
  }
}

class SearchProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final SearchProducts _searchProducts;
  bool _mounted = true;
  SearchProductsParams? _currentParams;

  SearchProductsNotifier(this._searchProducts) : super(const AsyncValue.data([]));

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> search(SearchProductsParams params) async {
    if (!_mounted) return;
    
    _currentParams = params;
    
    if (params.query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    
    state = const AsyncValue.loading();
    
    try {
      final result = await _searchProducts(params);
      if (!_mounted) return;
      
      result.fold(
        onSuccess: (products) => state = AsyncValue.data(products),
        onFailure: (error) => state = AsyncValue.error(error, StackTrace.current),
      );
    } catch (e, stackTrace) {
      if (!_mounted) return;
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> loadMoreResults() async {
    if (!_mounted || _currentParams == null) return;
    
    final currentData = state.asData?.value;
    if (currentData == null) return;
    
    try {
      final nextPageParams = _currentParams!.copyWith(
        page: _currentParams!.page + 1,
      );
      
      final result = await _searchProducts(nextPageParams);
      if (!_mounted) return;
      
      result.fold(
        onSuccess: (newProducts) {
          final updatedProducts = [...currentData, ...newProducts];
          state = AsyncValue.data(updatedProducts);
          _currentParams = nextPageParams;
        },
        onFailure: (error) => state = AsyncValue.error(error, StackTrace.current),
      );
    } catch (e, stackTrace) {
      if (!_mounted) return;
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void clearResults() {
    state = const AsyncValue.data([]);
    _currentParams = null;
  }

  bool get hasMore {
    final currentData = state.asData?.value;
    if (currentData == null || _currentParams == null) return false;
    return currentData.length >= _currentParams!.page * _currentParams!.limit;
  }
}

class CategoriesNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final GetCategories _getCategories;
  final GetSubcategories _getSubcategories;
  bool _mounted = true;

  CategoriesNotifier(this._getCategories, this._getSubcategories) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> loadCategories() async {
    if (!_mounted) return;
    
    state = const AsyncValue.loading();
    
    try {
      final result = await _getCategories();
      if (!_mounted) return;
      
      result.fold(
        onSuccess: (categories) => state = AsyncValue.data(categories),
        onFailure: (error) => state = AsyncValue.error(error, StackTrace.current),
      );
    } catch (e, stackTrace) {
      if (!_mounted) return;
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> loadSubcategories(String parentId) async {
    if (!_mounted) return;
    
    state = const AsyncValue.loading();
    
    try {
      final result = await _getSubcategories(parentId);
      if (!_mounted) return;
      
      result.fold(
        onSuccess: (categories) => state = AsyncValue.data(categories),
        onFailure: (error) => state = AsyncValue.error(error, StackTrace.current),
      );
    } catch (e, stackTrace) {
      if (!_mounted) return;
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    await loadCategories();
  }
}

class OffersNotifier extends StateNotifier<AsyncValue<List<Offer>>> {
  final GetActiveOffers _getActiveOffers;
  bool _mounted = true;

  OffersNotifier(this._getActiveOffers) : super(const AsyncValue.loading()) {
    loadOffers();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> loadOffers() async {
    if (!_mounted) return;
    
    state = const AsyncValue.loading();
    
    try {
      final result = await _getActiveOffers();
      if (!_mounted) return;
      
      result.fold(
        onSuccess: (offers) => state = AsyncValue.data(offers),
        onFailure: (error) => state = AsyncValue.error(error, StackTrace.current),
      );
    } catch (e, stackTrace) {
      if (!_mounted) return;
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    await loadOffers();
  }
}

// Provider instances
final featuredProductsProvider = StateNotifierProvider<FeaturedProductsNotifier, AsyncValue<List<Product>>>((ref) {
  final getFeaturedProducts = ref.watch(getFeaturedProductsProvider);
  return FeaturedProductsNotifier(getFeaturedProducts);
});

final productDetailProvider = StateNotifierProvider.family<ProductDetailNotifier, AsyncValue<Product?>, String>((ref, productId) {
  final getProductById = ref.watch(getProductByIdProvider);
  final notifier = ProductDetailNotifier(getProductById);
  notifier.loadProduct(productId);
  return notifier;
});

final categoryProductsProvider = StateNotifierProvider<CategoryProductsNotifier, AsyncValue<List<Product>>>((ref) {
  final getProductsByCategory = ref.watch(getProductsByCategoryProvider);
  return CategoryProductsNotifier(getProductsByCategory);
});

final searchProductsNotifierProvider = StateNotifierProvider<SearchProductsNotifier, AsyncValue<List<Product>>>((ref) {
  final searchProducts = ref.watch(searchProductsProvider);
  return SearchProductsNotifier(searchProducts);
});

final categoriesProvider = StateNotifierProvider<CategoriesNotifier, AsyncValue<List<Category>>>((ref) {
  final getCategories = ref.watch(getCategoriesProvider);
  final getSubcategories = ref.watch(getSubcategoriesProvider);
  return CategoriesNotifier(getCategories, getSubcategories);
});

final offersProvider = StateNotifierProvider<OffersNotifier, AsyncValue<List<Offer>>>((ref) {
  final getActiveOffers = ref.watch(getActiveOffersProvider);
  return OffersNotifier(getActiveOffers);
});

// Related products provider
final relatedProductsProvider = Provider.family<AsyncValue<List<Product>>, String>((ref, productId) {
  return ref.watch(relatedProductsAsyncProvider(productId));
});

final relatedProductsAsyncProvider = FutureProvider.family<List<Product>, String>((ref, productId) async {
  final getRelatedProducts = ref.watch(getRelatedProductsProvider);
  final result = await getRelatedProducts(productId);
  
  return result.fold(
    onSuccess: (products) => products,
    onFailure: (error) => throw Exception(error),
  );
});

// New arrivals provider
final newArrivalsProvider = FutureProvider<List<Product>>((ref) async {
  final getNewArrivals = ref.watch(getNewArrivalsProvider);
  final result = await getNewArrivals();
  
  return result.fold(
    onSuccess: (products) => products,
    onFailure: (error) => throw Exception(error),
  );
});

// Price range provider
final priceRangeProvider = FutureProvider.family<Map<String, double>, String?>((ref, categoryId) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getPriceRange(categoryId);
  
  return result.fold(
    onSuccess: (priceRange) => priceRange,
    onFailure: (error) => throw Exception(error),
  );
});

// Responsive grid count provider
final gridCountProvider = Provider<int>((ref) {
  return ResponsiveHelper.getProductGridCount();
});

// Platform-aware pagination limit provider
final paginationLimitProvider = Provider<int>((ref) {
  if (ResponsiveHelper.isWeb()) {
    return AppConfig.webProductPageSize;
  } else if (ResponsiveHelper.isTablet()) {
    return AppConfig.tabletProductPageSize;
  }
  return AppConfig.mobileProductPageSize;
});
