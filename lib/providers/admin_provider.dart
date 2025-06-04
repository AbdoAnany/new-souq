import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:souq/models/category.dart';
import 'package:souq/models/offer.dart';
import 'package:souq/models/product.dart';
import 'package:souq/services/admin_service.dart';
import 'package:souq/services/dummy_data_service.dart';

// Admin Service Provider
final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService();
});

// Dummy Data Service Provider
final dummyDataServiceProvider = Provider<DummyDataService>((ref) {
  return DummyDataService();
});

// Products Notifier for Admin
class AdminProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final AdminService _adminService;

  AdminProductsNotifier(this._adminService)
      : super(const AsyncValue.loading()) {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    state = const AsyncValue.loading();
    try {
      final products = await _adminService.getAllProducts();
      state = AsyncValue.data(products);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      await _adminService.addProduct(productData);
      await fetchProducts(); // Refresh the list
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateProduct(
      String productId, Map<String, dynamic> updates) async {
    try {
      await _adminService.updateProduct(productId, updates);
      await fetchProducts(); // Refresh the list
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _adminService.deleteProduct(productId);
      await fetchProducts(); // Refresh the list
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> toggleFeatured(String productId, bool isFeatured) async {
    try {
      await _adminService.toggleProductFeatured(productId, isFeatured);
      await fetchProducts(); // Refresh the list
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateStock(String productId, int quantity) async {
    try {
      await _adminService.updateProductStock(productId, quantity);
      await fetchProducts(); // Refresh the list
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Categories Notifier for Admin
class AdminCategoriesNotifier
    extends StateNotifier<AsyncValue<List<Category>>> {
  final AdminService _adminService;

  AdminCategoriesNotifier(this._adminService)
      : super(const AsyncValue.loading()) {
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    state = const AsyncValue.loading();
    try {
      final categories = await _adminService.getAllCategories();
      state = AsyncValue.data(categories);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addCategory(Map<String, dynamic> categoryData) async {
    try {
      await _adminService.addCategory(categoryData);
      await fetchCategories(); // Refresh the list
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateCategory(
      String categoryId, Map<String, dynamic> updates) async {
    try {
      await _adminService.updateCategory(categoryId, updates);
      await fetchCategories(); // Refresh the list
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _adminService.deleteCategory(categoryId);
      await fetchCategories(); // Refresh the list
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> toggleStatus(String categoryId, bool isActive) async {
    try {
      await _adminService.toggleCategoryStatus(categoryId, isActive);
      await fetchCategories(); // Refresh the list
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Offers Notifier for Admin
class AdminOffersNotifier extends StateNotifier<AsyncValue<List<Offer>>> {
  final AdminService _adminService;

  AdminOffersNotifier(this._adminService) : super(const AsyncValue.loading()) {
    fetchOffers();
  }

  Future<void> fetchOffers() async {
    state = const AsyncValue.loading();
    try {
      final offers = await _adminService.getAllOffers();
      state = AsyncValue.data(offers);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addOffer(Map<String, dynamic> offerData) async {
    try {
      await _adminService.addOffer(offerData);
      await fetchOffers(); // Refresh the list
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateOffer(String offerId, Map<String, dynamic> updates) async {
    try {
      await _adminService.updateOffer(offerId, updates);
      await fetchOffers(); // Refresh the list
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteOffer(String offerId) async {
    try {
      await _adminService.deleteOffer(offerId);
      await fetchOffers(); // Refresh the list
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> toggleStatus(String offerId, bool isActive) async {
    try {
      await _adminService.toggleOfferStatus(offerId, isActive);
      await fetchOffers(); // Refresh the list
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Statistics Notifier
class StatisticsNotifier extends StateNotifier<AsyncValue<Map<String, int>>> {
  final AdminService _adminService;

  StatisticsNotifier(this._adminService) : super(const AsyncValue.loading()) {
    fetchStatistics();
  }

  Future<void> fetchStatistics() async {
    state = const AsyncValue.loading();
    try {
      final stats = await _adminService.getStatistics();
      state = AsyncValue.data(stats);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// Providers
final adminProductsProvider =
    StateNotifierProvider<AdminProductsNotifier, AsyncValue<List<Product>>>(
        (ref) {
  final adminService = ref.watch(adminServiceProvider);
  return AdminProductsNotifier(adminService);
});

final adminCategoriesProvider =
    StateNotifierProvider<AdminCategoriesNotifier, AsyncValue<List<Category>>>(
        (ref) {
  final adminService = ref.watch(adminServiceProvider);
  return AdminCategoriesNotifier(adminService);
});

final adminOffersProvider =
    StateNotifierProvider<AdminOffersNotifier, AsyncValue<List<Offer>>>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  return AdminOffersNotifier(adminService);
});

final statisticsProvider =
    StateNotifierProvider<StatisticsNotifier, AsyncValue<Map<String, int>>>(
        (ref) {
  final adminService = ref.watch(adminServiceProvider);
  return StatisticsNotifier(adminService);
});
