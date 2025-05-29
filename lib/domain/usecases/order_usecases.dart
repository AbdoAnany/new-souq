import '../../core/result.dart';
import '../../core/failure.dart';
import '../../core/usecase/usecase.dart';
import '../repositories/repositories.dart';
import '../entities/order.dart';

/// Parameters for getting order by ID
class GetOrderByIdParams {
  final String orderId;

  const GetOrderByIdParams({required this.orderId});
}

/// Use case for getting order by ID
class GetOrderByIdUseCase implements UseCase<Order, GetOrderByIdParams> {
  final OrderRepository _repository;

  GetOrderByIdUseCase(this._repository);

  @override
  Future<Result<Order, Failure>> call(GetOrderByIdParams params) async {
    return await _repository.getOrderById(params.orderId);
  }
}

/// Parameters for getting user orders
class GetUserOrdersParams {
  final String userId;
  final int? limit;

  const GetUserOrdersParams({
    required this.userId,
    this.limit,
  });
}

/// Use case for getting user orders
class GetUserOrdersUseCase implements UseCase<List<Order>, GetUserOrdersParams> {
  final OrderRepository _repository;

  GetUserOrdersUseCase(this._repository);

  @override
  Future<Result<List<Order>, Failure>> call(GetUserOrdersParams params) async {
    return await _repository.getUserOrders(params.userId, limit: params.limit);
  }
}

/// Parameters for creating an order
class CreateOrderParams {
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final String deliveryAddress;
  final String? notes;

  const CreateOrderParams({
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.deliveryAddress,
    this.notes,
  });
}

/// Use case for creating an order
class CreateOrderUseCase implements UseCase<Order, CreateOrderParams> {
  final OrderRepository _repository;

  CreateOrderUseCase(this._repository);

  @override
  Future<Result<Order, Failure>> call(CreateOrderParams params) async {
    // Validate order before creating
    if (params.items.isEmpty) {
      return Result.failure(const ValidationFailure('Order must contain at least one item'));
    }

    if (params.totalAmount <= 0) {
      return Result.failure(const ValidationFailure('Order total must be greater than 0'));
    }

    if (params.deliveryAddress.trim().isEmpty) {
      return Result.failure(const ValidationFailure('Delivery address is required'));
    }

    return await _repository.createOrder(
      userId: params.userId,
      items: params.items,
      totalAmount: params.totalAmount,
      deliveryAddress: params.deliveryAddress,
      notes: params.notes,
    );
  }
}

/// Parameters for updating order status
class UpdateOrderStatusParams {
  final String orderId;
  final OrderStatus status;

  const UpdateOrderStatusParams({
    required this.orderId,
    required this.status,
  });
}

/// Use case for updating order status
class UpdateOrderStatusUseCase implements UseCase<Order, UpdateOrderStatusParams> {
  final OrderRepository _repository;

  UpdateOrderStatusUseCase(this._repository);

  @override
  Future<Result<Order, Failure>> call(UpdateOrderStatusParams params) async {
    return await _repository.updateOrderStatus(params.orderId, params.status);
  }
}

/// Parameters for cancelling an order
class CancelOrderParams {
  final String orderId;

  const CancelOrderParams({required this.orderId});
}

/// Use case for cancelling an order
class CancelOrderUseCase implements UseCase<Order, CancelOrderParams> {
  final OrderRepository _repository;

  CancelOrderUseCase(this._repository);

  @override
  Future<Result<Order, Failure>> call(CancelOrderParams params) async {
    return await _repository.cancelOrder(params.orderId);
  }
}

/// Parameters for watching user orders
class WatchUserOrdersParams {
  final String userId;

  const WatchUserOrdersParams({required this.userId});
}

/// Use case for watching user orders
class WatchUserOrdersUseCase implements StreamUseCase<List<Order>, WatchUserOrdersParams> {
  final OrderRepository _repository;

  WatchUserOrdersUseCase(this._repository);

  @override
  Stream<Result<List<Order>, Failure>> call(WatchUserOrdersParams params) {
    return _repository.watchUserOrders(params.userId);
  }
}

/// Use case for getting order by ID
class GetOrderByIdUseCase implements UseCase<UserOrder, String> {
  final OrderRepository _repository;

  GetOrderByIdUseCase(this._repository);

  @override
  Future<Result<UserOrder>> call(String orderId) async {
    return await _repository.getOrderById(orderId);
  }
}

/// Use case for getting user orders
class GetUserOrdersUseCase implements UseCase<List<UserOrder>, String> {
  final OrderRepository _repository;

  GetUserOrdersUseCase(this._repository);

  @override
  Future<Result<List<UserOrder>>> call(String userId) async {
    return await _repository.getUserOrders(userId);
  }
}

/// Parameters for getting all orders with filters
class GetAllOrdersParams {
  final int? page;
  final int? limit;
  final OrderStatus? status;
  final String? search;

  const GetAllOrdersParams({
    this.page,
    this.limit,
    this.status,
    this.search,
  });
}

/// Use case for getting all orders (admin)
class GetAllOrdersUseCase implements UseCase<List<UserOrder>, GetAllOrdersParams> {
  final OrderRepository _repository;

  GetAllOrdersUseCase(this._repository);

  @override
  Future<Result<List<UserOrder>>> call(GetAllOrdersParams params) async {
    return await _repository.getAllOrders(
      page: params.page,
      limit: params.limit,
      status: params.status,
      search: params.search,
    );
  }
}

/// Use case for creating an order
class CreateOrderUseCase implements UseCase<UserOrder, UserOrder> {
  final OrderRepository _repository;

  CreateOrderUseCase(this._repository);

  @override
  Future<Result<UserOrder>> call(UserOrder order) async {
    // Validate order before creating
    if (order.items.isEmpty) {
      return Result.failure('Order must contain at least one item');
    }

    if (order.total <= 0) {
      return Result.failure('Order total must be greater than 0');
    }

    return await _repository.createOrder(order);
  }
}

/// Use case for updating an order
class UpdateOrderUseCase implements UseCase<UserOrder, UserOrder> {
  final OrderRepository _repository;

  UpdateOrderUseCase(this._repository);

  @override
  Future<Result<UserOrder>> call(UserOrder order) async {
    return await _repository.updateOrder(order);
  }
}

/// Parameters for updating order status
class UpdateOrderStatusParams {
  final String orderId;
  final OrderStatus status;

  const UpdateOrderStatusParams({
    required this.orderId,
    required this.status,
  });
}

/// Use case for updating order status
class UpdateOrderStatusUseCase implements UseCase<UserOrder, UpdateOrderStatusParams> {
  final OrderRepository _repository;

  UpdateOrderStatusUseCase(this._repository);

  @override
  Future<Result<UserOrder>> call(UpdateOrderStatusParams params) async {
    return await _repository.updateOrderStatus(
      params.orderId,
      params.status,
    );
  }
}

/// Use case for cancelling an order
class CancelOrderUseCase implements UseCase<void, String> {
  final OrderRepository _repository;

  CancelOrderUseCase(this._repository);

  @override
  Future<Result<void>> call(String orderId) async {
    return await _repository.cancelOrder(orderId);
  }
}

/// Use case for watching order changes
class WatchOrderUseCase {
  final OrderRepository _repository;

  WatchOrderUseCase(this._repository);

  Stream<UserOrder> call(String orderId) {
    return _repository.watchOrder(orderId);
  }
}
