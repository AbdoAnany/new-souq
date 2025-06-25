import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/base_classes.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

// Get user orders use case
class GetUserOrdersUseCase
    implements UseCase<List<OrderEntity>, GetUserOrdersParams> {
  final OrderRepository repository;

  const GetUserOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, List<OrderEntity>>> call(
      GetUserOrdersParams params) async {
    return await repository.getUserOrders(
      userId: params.userId,
      page: params.page,
      limit: params.limit,
      status: params.status,
    );
  }
}

class GetUserOrdersParams extends Equatable {
  final String userId;
  final int page;
  final int limit;
  final OrderStatus? status;

  const GetUserOrdersParams({
    required this.userId,
    this.page = 1,
    this.limit = 20,
    this.status,
  });

  @override
  List<Object?> get props => [userId, page, limit, status];
}

// Get order by ID use case
class GetOrderByIdUseCase implements UseCase<OrderEntity, String> {
  final OrderRepository repository;

  const GetOrderByIdUseCase(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(String orderId) async {
    return await repository.getOrderById(orderId);
  }
}

// Place order use case
class PlaceOrderUseCase implements UseCase<OrderEntity, PlaceOrderParams> {
  final OrderRepository repository;

  const PlaceOrderUseCase(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(PlaceOrderParams params) async {
    return await repository.placeOrder(
      userId: params.userId,
      items: params.items,
      shippingAddress: params.shippingAddress,
      paymentMethod: params.paymentMethod,
      notes: params.notes,
    );
  }
}

class PlaceOrderParams extends Equatable {
  final String userId;
  final List<OrderItemEntity> items;
  final ShippingAddressEntity shippingAddress;
  final PaymentMethod paymentMethod;
  final String? notes;

  const PlaceOrderParams({
    required this.userId,
    required this.items,
    required this.shippingAddress,
    required this.paymentMethod,
    this.notes,
  });

  @override
  List<Object?> get props => [
        userId,
        items,
        shippingAddress,
        paymentMethod,
        notes,
      ];
}

// Update order status use case
class UpdateOrderStatusUseCase
    implements UseCase<OrderEntity, UpdateOrderStatusParams> {
  final OrderRepository repository;

  const UpdateOrderStatusUseCase(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(
      UpdateOrderStatusParams params) async {
    return await repository.updateOrderStatus(
      orderId: params.orderId,
      status: params.status,
      trackingNumber: params.trackingNumber,
      notes: params.notes,
    );
  }
}

class UpdateOrderStatusParams extends Equatable {
  final String orderId;
  final OrderStatus status;
  final String? trackingNumber;
  final String? notes;

  const UpdateOrderStatusParams({
    required this.orderId,
    required this.status,
    this.trackingNumber,
    this.notes,
  });

  @override
  List<Object?> get props => [orderId, status, trackingNumber, notes];
}

// Cancel order use case
class CancelOrderUseCase implements UseCase<OrderEntity, String> {
  final OrderRepository repository;

  const CancelOrderUseCase(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(String orderId) async {
    return await repository.cancelOrder(orderId);
  }
}

// Search orders use case
class SearchOrdersUseCase
    implements UseCase<List<OrderEntity>, SearchOrdersParams> {
  final OrderRepository repository;

  const SearchOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, List<OrderEntity>>> call(
      SearchOrdersParams params) async {
    return await repository.searchOrders(
      userId: params.userId,
      query: params.query,
      status: params.status, // Pass status to repository
    );
  }
}

class SearchOrdersParams extends Equatable {
  final String userId;
  final String query;
  final OrderStatus? status; // Added status filter

  const SearchOrdersParams({
    required this.userId,
    required this.query,
    this.status,
  });

  @override
  List<Object?> get props => [userId, query, status];
}
