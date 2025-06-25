import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../data/services/order_cache_service.dart';
import '../entities/order_entity.dart';
import '../entities/tracking_entity.dart';
import '../usecases/paginated_orders_usecases.dart';

abstract class OrderRepository {
  // Get user orders
  Future<Either<Failure, List<OrderEntity>>> getUserOrders({
    required String userId,
    int page = 1,
    int limit = 20,
    OrderStatus? status,
  });

  // Get order by ID
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId);

  // Place order
  Future<Either<Failure, OrderEntity>> placeOrder({
    required String userId,
    required List<OrderItemEntity> items,
    required ShippingAddressEntity shippingAddress,
    required PaymentMethod paymentMethod,
    String? notes,
  });

  // Update order status
  Future<Either<Failure, OrderEntity>> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    String? trackingNumber,
    String? notes,
  });

  // Cancel order
  Future<Either<Failure, OrderEntity>> cancelOrder(String orderId);

  // Track order
  Future<Either<Failure, OrderTrackingEntity>> trackOrder(String orderNumber);

  // Get order stream for real-time updates
  Stream<Either<Failure, OrderEntity>> getOrderStream(String orderId);

  // Search orders
  Future<Either<Failure, List<OrderEntity>>> searchOrders({
    required String userId,
    required String query,
    OrderStatus? status,
  });

  // Get paginated orders with advanced filtering
  Future<Either<Failure, PaginatedResult<OrderEntity>>> getPaginatedOrders(
    PaginatedOrdersParams params,
  );

  // Get recent orders for caching
  Future<Either<Failure, List<OrderEntity>>> getRecentOrders({
    required String userId,
    int limit = 10,
  });
}
