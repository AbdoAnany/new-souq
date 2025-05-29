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

enum PaymentMethod {
  cashOnDelivery,
  creditCard,
  paypal,
  stripe,
  unknown
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cashOnDelivery:
        return 'Cash on Delivery';
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.stripe:
        return 'Stripe';
      case PaymentMethod.unknown:
        return 'Unknown';
    }
  }
}
  
class UserOrder {
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

  const UserOrder({
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

  // Convert order to JSON for Firestore
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
      return 'credit_card';
    case PaymentMethod.paypal:
      return 'paypal';
    case PaymentMethod.cashOnDelivery:
      return 'cash_on_delivery';
    // case PaymentMethod.bankTransfer:
    //   return 'bank_transfer';
    default:
      return 'unknown';
  }
}

static PaymentMethod stringToPaymentMethod(String? method) {
  if (method == null) return PaymentMethod.unknown;
  switch (method) {
    case 'credit_card':
      return PaymentMethod.creditCard;
    case 'paypal':
      return PaymentMethod.paypal;
    case 'cash_on_delivery':
      return PaymentMethod.cashOnDelivery;
    // case 'bank_transfer':
    //   return PaymentMethod.bankTransfer;
    default:
      return PaymentMethod.unknown;
  }
}

  // Create order from Firestore document
  factory UserOrder.fromJson(Map<String, dynamic> json) {
    return UserOrder(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      shipping: (json['shipping'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      status: _stringToOrderStatus(json['status']),
      shippingAddress: Address.fromJson(json['shippingAddress'] ?? {}),
      billingAddress: json['billingAddress'] != null ? Address.fromJson(json['billingAddress']) : null,
      paymentMethod: stringToPaymentMethod(json['paymentMethod']),
      paymentId: json['paymentId'],
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      notes: json['notes'],
      confirmedAt: json['confirmedAt'] is Timestamp
          ? (json['confirmedAt'] as Timestamp).toDate()
          : json['confirmedAt'] != null ? DateTime.parse(json['confirmedAt']) : null,
      processedAt: json['processedAt'] is Timestamp
          ? (json['processedAt'] as Timestamp).toDate()
          : json['processedAt'] != null ? DateTime.parse(json['processedAt']) : null,
      shippedAt: json['shippedAt'] is Timestamp
          ? (json['shippedAt'] as Timestamp).toDate()
          : json['shippedAt'] != null ? DateTime.parse(json['shippedAt']) : null,
      deliveredAt: json['deliveredAt'] is Timestamp
          ? (json['deliveredAt'] as Timestamp).toDate()
          : json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt']) : null,
      cancelledAt: json['cancelledAt'] is Timestamp
          ? (json['cancelledAt'] as Timestamp).toDate()
          : json['cancelledAt'] != null ? DateTime.parse(json['cancelledAt']) : null,
      cancellationReason: json['cancellationReason'],
      trackingNumber: json['trackingNumber'],
      trackingUrl: json['trackingUrl'],
    );
  }

  static OrderStatus _stringToOrderStatus(String? status) {
    if (status == null) return OrderStatus.pending;
    switch (status) {
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'returned':
        return OrderStatus.returned;
      default:
        return OrderStatus.pending;
    }
  }

  UserOrder copyWith({
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
    return UserOrder(
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

  @override
  String toString() {
    return 'UserOrder(id: $id, orderNumber: $orderNumber, status: $status, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserOrder && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  String get formattedCreatedAt {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  String get statusDisplayName {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.returned:
        return 'Returned';
    }
  }

  bool get canBeCancelled {
    return status == OrderStatus.pending || status == OrderStatus.confirmed;
  }

  bool get canBeReturned {
    return status == OrderStatus.delivered;
  }

  double get totalWithoutDiscount {
    return subtotal + tax + shipping;
  }
}

// Order item class
class OrderItem {
  final String productId;
  final String productName;
  final String? productImage;
  final double price;
  final int quantity;
  final String? selectedVariant;
  final String? selectedSize;
  final String? selectedColor;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.productImage,
    this.selectedVariant,
    this.selectedSize,
    this.selectedColor,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'selectedVariant': selectedVariant,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      productImage: json['productImage'],
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      selectedVariant: json['selectedVariant'],
      selectedSize: json['selectedSize'],
      selectedColor: json['selectedColor'],
    );
  }

  double get totalPrice => price * quantity;
  factory OrderItem.fromCartItem(CartItem cartItem) {
    // Calculate the total including any variant prices
    double itemPrice = cartItem.price;
    Map<String, dynamic>? variants = cartItem.selectedVariants;
    
    return OrderItem(
      productId: cartItem.productId,
      productName: cartItem.product.name,
      productImage: cartItem.product.images.isNotEmpty ? cartItem.product.images[0] : null,
      price: itemPrice,
      quantity: cartItem.quantity,
    );
  }
  OrderItem copyWith({
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    int? quantity,
    String? selectedVariant,
    String? selectedSize,
    String? selectedColor,
  }) {
    return OrderItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      selectedVariant: selectedVariant ?? this.selectedVariant,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
    );
  }

  @override
  String toString() {
    return 'OrderItem(productId: $productId, productName: $productName, quantity: $quantity, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderItem && 
           other.productId == productId && 
           other.selectedVariant == selectedVariant &&
           other.selectedSize == selectedSize &&
           other.selectedColor == selectedColor;
  }

  @override
  int get hashCode {
    return Object.hash(productId, selectedVariant, selectedSize, selectedColor);
  }
}
