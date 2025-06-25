import 'package:equatable/equatable.dart';

// Order status enum
enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  returned,
  refunded
}

// Payment status enum
enum PaymentStatus { pending, completed, failed, refunded }

// Payment method enum
enum PaymentMethod {
  cashOnDelivery,
  creditCard,
  debitCard,
  bankTransfer,
  paypal,
  stripe,
  unknown
}

// Order item entity
class OrderItemEntity extends Equatable {
  final String id; // Added missing id field
  final String productId;
  final String productName;
  final String? productImageUrl;
  final double unitPrice;
  final int quantity;

  const OrderItemEntity({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImageUrl,
    required this.unitPrice,
    required this.quantity,
  });

  double get totalPrice => unitPrice * quantity;

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        productImageUrl,
        unitPrice,
        quantity,
      ];
}

// Shipping address entity
class ShippingAddressEntity extends Equatable {
  final String fullName;
  final String address;
  final String? apartment;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String? phoneNumber;

  const ShippingAddressEntity({
    required this.fullName,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    this.phoneNumber,
    this.apartment,
  });

  // Computed properties for backward compatibility
  String get firstName {
    final parts = fullName.split(' ');
    return parts.isNotEmpty ? parts.first : '';
  }

  String get lastName {
    final parts = fullName.split(' ');
    return parts.length > 1 ? parts.sublist(1).join(' ') : '';
  }

  String get streetAddress => address;
  String get zipCode => postalCode;
  String? get phone => phoneNumber;

  @override
  List<Object?> get props => [
        fullName,
        address,
        city,
        state,
        country,
        postalCode,
        phoneNumber,
        apartment,
      ];
}

// Order entity
class OrderEntity extends Equatable {
  final String id;
  final String userId;
  final String orderNumber;
  final List<OrderItemEntity> items;
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final PaymentMethod paymentMethod;
  final ShippingAddressEntity shippingAddress;
  final DateTime orderDate;
  final DateTime? shippedDate;
  final DateTime? deliveredDate;
  final String? trackingNumber;
  final String? notes;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.orderNumber,
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.shippingAddress,
    required this.orderDate,
    this.shippedDate,
    this.deliveredDate,
    this.trackingNumber,
    this.notes,
  });

  // Computed property for backward compatibility
  double get shippingCost => shipping;

  // Get total items count
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  // Check if order can be cancelled
  bool get canBeCancelled =>
      status == OrderStatus.pending || status == OrderStatus.confirmed;

  // Check if order is completed
  bool get isCompleted => status == OrderStatus.delivered;

  // Check if order is cancelled
  bool get isCancelled => status == OrderStatus.cancelled;

  @override
  List<Object?> get props => [
        id,
        userId,
        orderNumber,
        items,
        subtotal,
        shipping,
        tax,
        total,
        status,
        paymentStatus,
        paymentMethod,
        shippingAddress,
        orderDate,
        shippedDate,
        deliveredDate,
        trackingNumber,
        notes,
      ];
}
