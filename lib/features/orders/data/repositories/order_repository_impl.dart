import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/tracking_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/usecases/paginated_orders_usecases.dart';
import '../datasources/order_local_data_source.dart';
import '../datasources/order_remote_data_source.dart';
import '../models/order_model.dart';
import '../services/order_cache_service.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;
  final OrderLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  OrderRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<OrderEntity>>> getUserOrders({
    required String userId,
    int page = 1,
    int limit = 20,
    OrderStatus? status,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final orders = await remoteDataSource.getUserOrders(
          userId: userId,
          page: page,
          limit: limit,
          status: status?.name,
        );

        // Cache the orders
        await localDataSource.cacheOrders(userId, orders);

        return Right(orders);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final cachedOrders = await localDataSource.getCachedOrders(userId);

        // Filter by status if needed
        List<OrderModel> filteredOrders = cachedOrders;
        if (status != null) {
          filteredOrders =
              cachedOrders.where((order) => order.status == status).toList();
        }

        return Right(filteredOrders);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId) async {
    if (await networkInfo.isConnected) {
      try {
        final order = await remoteDataSource.getOrderById(orderId);
        await localDataSource.cacheOrder(order);
        return Right(order);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final cachedOrder = await localDataSource.getCachedOrder(orderId);
        if (cachedOrder != null) {
          return Right(cachedOrder);
        } else {
          return Left(CacheFailure(message: 'Order not found in cache'));
        }
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> placeOrder({
    required String userId,
    required List<OrderItemEntity> items,
    required ShippingAddressEntity shippingAddress,
    required PaymentMethod paymentMethod,
    String? notes,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final orderModel = OrderModel(
          id: '', // Will be set by remote data source
          userId: userId,
          orderNumber: _generateOrderNumber(),
          items: items,
          subtotal: _calculateSubtotal(items),
          shipping: _calculateShipping(items),
          tax: _calculateTax(items),
          total: _calculateTotal(items),
          status: OrderStatus.pending,
          paymentStatus: PaymentStatus.pending,
          paymentMethod: paymentMethod,
          shippingAddress: shippingAddress,
          orderDate: DateTime.now(),
          notes: notes,
        );

        final placedOrder = await remoteDataSource.placeOrder(orderModel);
        await localDataSource.cacheOrder(placedOrder);

        return Right(placedOrder);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(ServerFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    String? trackingNumber,
    String? notes,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedOrder = await remoteDataSource.updateOrderStatus(
          orderId: orderId,
          status: status.name,
          trackingNumber: trackingNumber,
          notes: notes,
        );

        await localDataSource.cacheOrder(updatedOrder);
        return Right(updatedOrder);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(ServerFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> cancelOrder(String orderId) async {
    if (await networkInfo.isConnected) {
      try {
        final cancelledOrder = await remoteDataSource.cancelOrder(orderId);
        await localDataSource.cacheOrder(cancelledOrder);
        return Right(cancelledOrder);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(ServerFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, OrderTrackingEntity>> trackOrder(
      String orderNumber) async {
    if (await networkInfo.isConnected) {
      try {
        final tracking = await remoteDataSource.trackOrder(orderNumber);
        return Right(tracking);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(ServerFailure(message: 'No internet connection'));
    }
  }

  @override
  Stream<Either<Failure, OrderEntity>> getOrderStream(String orderId) async* {
    if (await networkInfo.isConnected) {
      try {
        await for (final order in remoteDataSource.getOrderStream(orderId)) {
          await localDataSource.cacheOrder(order);
          yield Right(order);
        }
      } on ServerException catch (e) {
        yield Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final cachedOrder = await localDataSource.getCachedOrder(orderId);
        if (cachedOrder != null) {
          yield Right(cachedOrder);
        } else {
          yield Left(CacheFailure(message: 'Order not found in cache'));
        }
      } on CacheException catch (e) {
        yield Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> searchOrders({
    required String userId,
    required String query,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final orders = await remoteDataSource.searchOrders(
          userId: userId,
          query: query,
        );
        return Right(orders);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final cachedOrders = await localDataSource.getCachedOrders(userId);
        final filteredOrders = cachedOrders.where((order) {
          final searchQuery = query.toLowerCase();
          return order.orderNumber.toLowerCase().contains(searchQuery) ||
              order.id.toLowerCase().contains(searchQuery);
        }).toList();

        return Right(filteredOrders);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  // Helper methods
  String _generateOrderNumber() {
    final now = DateTime.now();
    return 'ORD${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.millisecondsSinceEpoch.toString().substring(8)}';
  }

  double _calculateSubtotal(List<OrderItemEntity> items) {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double _calculateShipping(List<OrderItemEntity> items) {
    final subtotal = _calculateSubtotal(items);
    return subtotal >= 100 ? 0.0 : 10.0; // Free shipping over $100
  }

  double _calculateTax(List<OrderItemEntity> items) {
    final subtotal = _calculateSubtotal(items);
    return subtotal * 0.1; // 10% tax
  }

  double _calculateTotal(List<OrderItemEntity> items) {
    final subtotal = _calculateSubtotal(items);
    final shipping = _calculateShipping(items);
    final tax = _calculateTax(items);
    return subtotal + shipping + tax;
  }

  @override
  Future<Either<Failure, PaginatedResult<OrderEntity>>> getPaginatedOrders(
    PaginatedOrdersParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        // For now, we'll simulate pagination by fetching orders and paginating in memory
        final orders = await remoteDataSource.getUserOrders(
          userId: params.userId,
          page: params.page,
          limit: params.limit,
          status: params.status,
        );

        // Create pagination metadata
        final pagination = PaginationMeta.fromData(
          currentPage: params.page,
          totalItems:
              orders.length, // In a real app, this would come from the API
          itemsPerPage: params.limit,
        );

        final result = PaginatedResult<OrderEntity>(
          data: orders.cast<OrderEntity>(),
          pagination: pagination,
        );

        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final cachedOrders =
            await localDataSource.getCachedOrders(params.userId);

        // Apply pagination to cached orders
        final startIndex = (params.page - 1) * params.limit;
        final endIndex = startIndex + params.limit;
        final paginatedOrders =
            cachedOrders.skip(startIndex).take(params.limit).toList();

        final pagination = PaginationMeta.fromData(
          currentPage: params.page,
          totalItems: cachedOrders.length,
          itemsPerPage: params.limit,
        );

        final result = PaginatedResult<OrderEntity>(
          data: paginatedOrders.cast<OrderEntity>(),
          pagination: pagination,
        );

        return Right(result);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getRecentOrders({
    required String userId,
    int limit = 10,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final orders = await remoteDataSource.getUserOrders(
          userId: userId,
          page: 1,
          limit: limit,
        );

        // Cache the recent orders
        await localDataSource.cacheOrders(userId, orders);

        return Right(orders);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final cachedOrders = await localDataSource.getCachedOrders(userId);
        final recentOrders = cachedOrders.take(limit).toList();
        return Right(recentOrders);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }
}
