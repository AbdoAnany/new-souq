import 'package:equatable/equatable.dart';

import '../../domain/entities/order_entity.dart';

// Order States
abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrdersLoaded extends OrderState {
  final List<OrderEntity> orders;
  final bool hasReachedMax;
  final int currentPage;

  const OrdersLoaded({
    required this.orders,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  @override
  List<Object> get props => [orders, hasReachedMax, currentPage];

  OrdersLoaded copyWith({
    List<OrderEntity>? orders,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return OrdersLoaded(
      orders: orders ?? this.orders,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class OrderLoaded extends OrderState {
  final OrderEntity order;

  const OrderLoaded(this.order);

  @override
  List<Object> get props => [order];
}

class OrderPlaced extends OrderState {
  final OrderEntity order;

  const OrderPlaced(this.order);

  @override
  List<Object> get props => [order];
}

class OrderUpdated extends OrderState {
  final OrderEntity order;

  const OrderUpdated(this.order);

  @override
  List<Object> get props => [order];
}

class OrderCancelled extends OrderState {
  final OrderEntity order;

  const OrderCancelled(this.order);

  @override
  List<Object> get props => [order];
}

class OrderSearchResults extends OrderState {
  final List<OrderEntity> orders;
  final String query;

  const OrderSearchResults({
    required this.orders,
    required this.query,
  });

  @override
  List<Object> get props => [orders, query];
}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object> get props => [message];
}

class OrderLoadingMore extends OrderState {
  final List<OrderEntity> orders;

  const OrderLoadingMore(this.orders);

  @override
  List<Object> get props => [orders];
}

// Enhanced order management states
class OrderValidationSuccess extends OrderState {
  const OrderValidationSuccess();
}

class OrderValidationFailure extends OrderState {
  final String message;

  const OrderValidationFailure(this.message);

  @override
  List<Object> get props => [message];
}

class OrderStreamLoading extends OrderState {}

class OrderStreamLoaded extends OrderState {
  final OrderEntity order;

  const OrderStreamLoaded(this.order);

  @override
  List<Object> get props => [order];
}

class OrderUpdateInProgress extends OrderState {
  final String orderId;
  final String operation;

  const OrderUpdateInProgress({
    required this.orderId,
    required this.operation,
  });

  @override
  List<Object> get props => [orderId, operation];
}

class OrderUpdateSuccess extends OrderState {
  final OrderEntity order;
  final String message;

  const OrderUpdateSuccess({
    required this.order,
    required this.message,
  });

  @override
  List<Object> get props => [order, message];
}
