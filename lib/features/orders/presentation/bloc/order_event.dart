import 'package:equatable/equatable.dart';

import '../../domain/entities/order_entity.dart';

// Order Events
abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class GetUserOrdersEvent extends OrderEvent {
  final String userId;
  final int page;
  final int limit;
  final OrderStatus? status;

  const GetUserOrdersEvent({
    required this.userId,
    this.page = 1,
    this.limit = 20,
    this.status,
  });

  @override
  List<Object?> get props => [userId, page, limit, status];
}

class GetOrderByIdEvent extends OrderEvent {
  final String orderId;

  const GetOrderByIdEvent(this.orderId);

  @override
  List<Object> get props => [orderId];
}

class PlaceOrderEvent extends OrderEvent {
  final String userId;
  final List<OrderItemEntity> items;
  final ShippingAddressEntity shippingAddress;
  final PaymentMethod paymentMethod;
  final String? notes;

  const PlaceOrderEvent({
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

class UpdateOrderStatusEvent extends OrderEvent {
  final String orderId;
  final OrderStatus status;
  final String? trackingNumber;
  final String? notes;

  const UpdateOrderStatusEvent({
    required this.orderId,
    required this.status,
    this.trackingNumber,
    this.notes,
  });

  @override
  List<Object?> get props => [orderId, status, trackingNumber, notes];
}

class CancelOrderEvent extends OrderEvent {
  final String orderId;

  const CancelOrderEvent(this.orderId);

  @override
  List<Object> get props => [orderId];
}

class SearchOrdersEvent extends OrderEvent {
  final String userId;
  final String query;
  final OrderStatus? status; // Added status filter for search

  const SearchOrdersEvent({
    required this.userId,
    required this.query,
    this.status,
  });

  @override
  List<Object?> get props => [userId, query, status];
}

class RefreshOrdersEvent extends OrderEvent {
  final String userId;

  const RefreshOrdersEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

// Enhanced order management events
class UpdateOrderWithAdminPermissionsEvent extends OrderEvent {
  final String orderId;
  final OrderStatus newStatus;
  final String? adminNotes;
  final Map<String, int>? quantityUpdates;
  final String userRole;
  final String? trackingNumber;

  const UpdateOrderWithAdminPermissionsEvent({
    required this.orderId,
    required this.newStatus,
    this.adminNotes,
    this.quantityUpdates,
    required this.userRole,
    this.trackingNumber,
  });

  @override
  List<Object?> get props => [
        orderId,
        newStatus,
        adminNotes,
        quantityUpdates,
        userRole,
        trackingNumber,
      ];
}

class UpdateOrderWithValidationEvent extends OrderEvent {
  final String orderId;
  final OrderStatus newStatus;
  final String? customerNotes;
  final Map<String, int>? quantityUpdates;

  const UpdateOrderWithValidationEvent({
    required this.orderId,
    required this.newStatus,
    this.customerNotes,
    this.quantityUpdates,
  });

  @override
  List<Object?> get props => [
        orderId,
        newStatus,
        customerNotes,
        quantityUpdates,
      ];
}

class GetOrderStreamEvent extends OrderEvent {
  final String orderId;

  const GetOrderStreamEvent(this.orderId);

  @override
  List<Object> get props => [orderId];
}

class ValidateOrderUpdateEvent extends OrderEvent {
  final String orderId;
  final OrderStatus newStatus;
  final String? trackingNumber;
  final Map<String, int>? quantityUpdates;

  const ValidateOrderUpdateEvent({
    required this.orderId,
    required this.newStatus,
    this.trackingNumber,
    this.quantityUpdates,
  });

  @override
  List<Object?> get props =>
      [orderId, newStatus, trackingNumber, quantityUpdates];
}
