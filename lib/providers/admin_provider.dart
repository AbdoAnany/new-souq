import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:souq/models/product.dart';
import 'package:souq/models/category.dart';
import 'package:souq/models/user_order.dart';
import 'package:souq/models/user.dart';
import 'package:souq/services/admin_service.dart';

// Admin Service Provider
final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService();
});

// Admin Authentication Provider
final adminAuthProvider = StateNotifierProvider<AdminAuthNotifier, AsyncValue<bool>>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  return AdminAuthNotifier(adminService);
});

class AdminAuthNotifier extends StateNotifier<AsyncValue<bool>> {
  final AdminService _adminService;

  AdminAuthNotifier(this._adminService) : super(const AsyncValue.loading()) {
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    try {
      final isAdmin = await _adminService.isCurrentUserAdmin();
      state = AsyncValue.data(isAdmin);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _checkAdminStatus();
  }
}

// Admin Products Provider
final adminProductsProvider = StateNotifierProvider<AdminProductsNotifier, AsyncValue<List<Product>>>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  return AdminProductsNotifier(adminService);
});

class AdminProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final AdminService _adminService;

  AdminProductsNotifier(this._adminService) : super(const AsyncValue.loading()) {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      state = const AsyncValue.loading();
      final products = await _adminService.getAllProducts(limit: 50);
      state = AsyncValue.data(products);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      await _adminService.addProduct(product);
      await fetchProducts(); // Refresh the list
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _adminService.updateProduct(product);
      await fetchProducts(); // Refresh the list
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _adminService.deleteProduct(productId);
      await fetchProducts(); // Refresh the list
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }
}

// Admin Categories Provider
final adminCategoriesProvider = StateNotifierProvider<AdminCategoriesNotifier, AsyncValue<List<Category>>>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  return AdminCategoriesNotifier(adminService);
});

class AdminCategoriesNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final AdminService _adminService;

  AdminCategoriesNotifier(this._adminService) : super(const AsyncValue.loading()) {
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      state = const AsyncValue.loading();
      final categories = await _adminService.getAllCategories();
      state = AsyncValue.data(categories);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      await _adminService.addCategory(category);
      await fetchCategories(); // Refresh the list
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _adminService.updateCategory(category);
      await fetchCategories(); // Refresh the list
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _adminService.deleteCategory(categoryId);
      await fetchCategories(); // Refresh the list
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }
}

// Admin Orders Provider
final adminOrdersProvider = StateNotifierProvider<AdminOrdersNotifier, AsyncValue<List<UserOrder>>>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  return AdminOrdersNotifier(adminService);
});

class AdminOrdersNotifier extends StateNotifier<AsyncValue<List<UserOrder>>> {
  final AdminService _adminService;

  AdminOrdersNotifier(this._adminService) : super(const AsyncValue.loading()) {
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      state = const AsyncValue.loading();
      final orders = await _adminService.getAllOrders(limit: 50);
      state = AsyncValue.data(orders);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _adminService.updateOrderStatus(orderId, status);
      await fetchOrders(); // Refresh the list
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }
}

// Admin Users Provider
final adminUsersProvider = StateNotifierProvider<AdminUsersNotifier, AsyncValue<List<User>>>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  return AdminUsersNotifier(adminService);
});

class AdminUsersNotifier extends StateNotifier<AsyncValue<List<User>>> {
  final AdminService _adminService;

  AdminUsersNotifier(this._adminService) : super(const AsyncValue.loading()) {
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      state = const AsyncValue.loading();
      final users = await _adminService.getAllUsers(limit: 50);
      state = AsyncValue.data(users);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Admin Analytics Provider
final adminAnalyticsProvider = StateNotifierProvider<AdminAnalyticsNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  return AdminAnalyticsNotifier(adminService);
});

class AdminAnalyticsNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final AdminService _adminService;

  AdminAnalyticsNotifier(this._adminService) : super(const AsyncValue.loading()) {
    fetchAnalytics();
  }
  Future<void> fetchAnalytics() async {
    try {
      state = const AsyncValue.loading();
      final analytics = await _adminService.getDashboardAnalytics();
      state = AsyncValue.data(analytics);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadAnalytics() async {
    await fetchAnalytics();
  }

  Future<void> refresh() async {
    await fetchAnalytics();
  }
}

// Admin Monthly Sales Provider
final adminMonthlySalesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final adminService = ref.watch(adminServiceProvider);
  return await adminService.getMonthlySalesData();
});

// Admin Low Stock Products Provider
final adminLowStockProvider = FutureProvider<List<Product>>((ref) async {
  final adminService = ref.watch(adminServiceProvider);
  return await adminService.getLowStockProducts();
});
