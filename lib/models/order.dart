import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:souq/models/cart.dart';
import 'package:souq/models/user.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  returned
}

class Order {
  final String id;
  final String userId;
  final String orderNumber;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double shipping;
  final double discount;
  final double total;
  final OrderStatus status;
  final Address shippingAddress;
  final Address? billingAddress;
  final PaymentMethod paymentMethod;
  final String? paymentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;
  final DateTime? confirmedAt;
  final DateTime? processedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final String? trackingNumber;
  final String? trackingUrl;

  Order({
    required this.id,
    required this.userId,
    required this.orderNumber,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
    required this.status,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
    this.discount = 0.0,
    this.billingAddress,
    this.paymentId,
    this.notes,
    this.confirmedAt,
    this.processedAt,
    this.shippedAt,
    this.deliveredAt,
    this.cancelledAt,
    this.cancellationReason,
    this.trackingNumber,
    this.trackingUrl,
  });

  bool get canBeCancelled => status == OrderStatus.pending || status == OrderStatus.confirmed;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'orderNumber': orderNumber,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'shipping': shipping,
      'discount': discount,
      'total': total,
      'status': status.name,
      'shippingAddress': shippingAddress.toJson(),
      'billingAddress': billingAddress?.toJson(),
      'paymentMethod': paymentMethodToString(paymentMethod),
      'paymentId': paymentId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'notes': notes,
      'confirmedAt': confirmedAt != null ? Timestamp.fromDate(confirmedAt!) : null,
      'processedAt': processedAt != null ? Timestamp.fromDate(processedAt!) : null,
      'shippedAt': shippedAt != null ? Timestamp.fromDate(shippedAt!) : null,
      'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'cancellationReason': cancellationReason,
      'trackingNumber': trackingNumber,
      'trackingUrl': trackingUrl,
    };
  }
static String paymentMethodToString(PaymentMethod method) {
  switch (method) {
    case PaymentMethod.creditCard:
      return 'creditCard';
    case PaymentMethod.paypal:
      return 'paypal';
    case PaymentMethod.cashOnDelivery:
      return 'cashOnDelivery';
    // case PaymentMethod.bankTransfer:
    //   return 'bankTransfer';
    default:
      return 'unknown';
  }
}
static PaymentMethod stringToPaymentMethod(String method) {
  switch (method) {
    case 'creditCard':
      return PaymentMethod.creditCard;
    case 'paypal':
      return PaymentMethod.paypal;
    case 'cashOnDelivery':
      return PaymentMethod.cashOnDelivery;
    // case 'bankTransfer':
    //   return PaymentMethod.bankTransfer;
    default:
      return PaymentMethod.unknown;
  }
}
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['userId'],
      orderNumber: json['orderNumber'],
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      shipping: (json['shipping'] as num).toDouble(),
      discount: json['discount'] != null ? (json['discount'] as num).toDouble() : 0.0,
      total: (json['total'] as num).toDouble(),
      status: _parseOrderStatus(json['status']),
      shippingAddress: Address.fromJson(json['shippingAddress']),
      billingAddress: json['billingAddress'] != null
          ? Address.fromJson(json['billingAddress'])
          : null,
      paymentMethod: Order.stringToPaymentMethod(json['paymentMethod']),
      paymentId: json['paymentId'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      notes: json['notes'],
      confirmedAt: json['confirmedAt'] != null
          ? (json['confirmedAt'] as Timestamp).toDate()
          : null,
      processedAt: json['processedAt'] != null
          ? (json['processedAt'] as Timestamp).toDate()
          : null,
      shippedAt: json['shippedAt'] != null
          ? (json['shippedAt'] as Timestamp).toDate()
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? (json['deliveredAt'] as Timestamp).toDate()
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? (json['cancelledAt'] as Timestamp).toDate()
          : null,
      cancellationReason: json['cancellationReason'],
      trackingNumber: json['trackingNumber'],
      trackingUrl: json['trackingUrl'],
    );
  }

  static OrderStatus _parseOrderStatus(String status) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => OrderStatus.pending,
    );
  }

  Order copyWith({
    String? id,
    String? userId,
    String? orderNumber,
    List<OrderItem>? items,
    double? subtotal,
    double? tax,
    double? shipping,
    double? discount,
    double? total,
    OrderStatus? status,
    Address? shippingAddress,
    Address? billingAddress,
    PaymentMethod? paymentMethod,
    String? paymentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    DateTime? confirmedAt,
    DateTime? processedAt,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    String? trackingNumber,
    String? trackingUrl,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orderNumber: orderNumber ?? this.orderNumber,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      shipping: shipping ?? this.shipping,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      status: status ?? this.status,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentId: paymentId ?? this.paymentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      processedAt: processedAt ?? this.processedAt,
      shippedAt: shippedAt ?? this.shippedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      trackingUrl: trackingUrl ?? this.trackingUrl,
    );
  }
}

class OrderItem {
  final String productId;
  final String title;
  final String? image;
  final double price;
  final int quantity;
  final double total;
  final Map<String, dynamic>? customizations;

  OrderItem({
    required this.productId,
    required this.title,
    this.image,
    required this.price,
    required this.quantity,
    required this.total,
    this.customizations,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'image': image,
      'price': price,
      'quantity': quantity,
      'total': total,
      'customizations': customizations,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'],
      title: json['title'],
      image: json['image'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
      total: (json['total'] as num).toDouble(),
      customizations: json['customizations'],
    );
  }

  factory OrderItem.fromCartItem(CartItem cartItem) {
    // Calculate the total including any variant prices
    double itemPrice = cartItem.price;
    Map<String, dynamic>? variants = cartItem.selectedVariants;
    
    return OrderItem(
      productId: cartItem.productId,
      title: cartItem.product.name,
      image: cartItem.product.images.isNotEmpty ? cartItem.product.images[0] : null,
      price: itemPrice,
      quantity: cartItem.quantity,
      total: cartItem.totalPrice,
      customizations: variants,
    );
  }
}
