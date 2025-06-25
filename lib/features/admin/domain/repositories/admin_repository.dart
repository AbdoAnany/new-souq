import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../entities/analytics_entity.dart';


// Admin repository interface for dashboard operations
abstract class AdminRepository {
  // Analytics
  Future<Either<Failure, AnalyticsEntity>> getAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, List<MonthlySalesEntity>>> getMonthlySales({
    required int year,
  });

  // Order management
  Future<Either<Failure, List<OrderEntity>>> getAllOrders({
    int page = 1,
    int limit = 20,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, OrderEntity>> updateOrderStatus({
    required String orderId,
    required String status,
    String? trackingNumber,
  });

  Future<Either<Failure, void>> cancelOrder({
    required String orderId,
    required String reason,
  });

  // User management
  Future<Either<Failure, List<UserEntity>>> getAllUsers({
    int page = 1,
    int limit = 20,
    String? searchQuery,
    String? role,
  });

  Future<Either<Failure, UserEntity>> updateUserRole({
    required String userId,
    required String role,
  });

  Future<Either<Failure, void>> deactivateUser({
    required String userId,
  });

  Future<Either<Failure, void>> activateUser({
    required String userId,
  });

  // Product management
  Future<Either<Failure, List<ProductEntity>>> getAllProducts({
    int page = 1,
    int limit = 20,
    String? searchQuery,
    String? category,
    bool? isActive,
  });

  Future<Either<Failure, ProductEntity>> addProduct(ProductEntity product);

  Future<Either<Failure, ProductEntity>> updateProduct(ProductEntity product);

  Future<Either<Failure, void>> deleteProduct(String productId);

  Future<Either<Failure, void>> updateProductStatus({
    required String productId,
    required bool isActive,
  });

  Future<Either<Failure, List<ProductEntity>>> getLowStockProducts({
    int threshold = 10,
  });

  // Category management
  Future<Either<Failure, List<String>>> getAllCategories();

  Future<Either<Failure, void>> addCategory(String categoryName);

  Future<Either<Failure, void>> updateCategory({
    required String categoryId,
    required String categoryName,
  });

  Future<Either<Failure, void>> deleteCategory(String categoryId);

  // Reports
  Future<Either<Failure, Map<String, dynamic>>> generateSalesReport({
    required DateTime startDate,
    required DateTime endDate,
    String? format, // 'pdf', 'excel'
  });

  Future<Either<Failure, Map<String, dynamic>>> generateInventoryReport();

  Future<Either<Failure, Map<String, dynamic>>> generateCustomerReport({
    required DateTime startDate,
    required DateTime endDate,
  });
}
