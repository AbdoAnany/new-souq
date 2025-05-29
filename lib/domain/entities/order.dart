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

class OrderItem {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final int quantity;
  final double price;
  final double totalPrice;
  final Map<String, dynamic>? selectedVariants;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    this.selectedVariants,
  });

  OrderItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productImage,
    int? quantity,
    double? price,
    double? totalPrice,
    Map<String, dynamic>? selectedVariants,
  }) {
    return OrderItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      totalPrice: totalPrice ?? this.totalPrice,
      selectedVariants: selectedVariants ?? this.selectedVariants,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is OrderItem &&
        other.id == id &&
        other.productId == productId &&
        other.productName == productName &&
        other.productImage == productImage &&
        other.quantity == quantity &&
        other.price == price &&
        other.totalPrice == totalPrice &&
        other.selectedVariants == selectedVariants;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      productId,
      productName,
      productImage,
      quantity,
      price,
      totalPrice,
      selectedVariants,
    );
  }

  @override
  String toString() {
    return 'OrderItem(id: $id, productName: $productName, quantity: $quantity, totalPrice: $totalPrice)';
  }
}

class Address {
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String? name;
  final String? phone;

  const Address({
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    this.name,
    this.phone,
  });

  Address copyWith({
    String? street,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    String? name,
    String? phone,
  }) {
    return Address(
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      name: name ?? this.name,
      phone: phone ?? this.phone,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Address &&
        other.street == street &&
        other.city == city &&
        other.state == state &&
        other.zipCode == zipCode &&
        other.country == country &&
        other.name == name &&
        other.phone == phone;
  }

  @override
  int get hashCode {
    return Object.hash(
      street,
      city,
      state,
      zipCode,
      country,
      name,
      phone,
    );
  }

  @override
  String toString() {
    return '$street, $city, $state $zipCode, $country';
  }

  String get fullAddress {
    final parts = <String>[];
    if (name != null && name!.isNotEmpty) parts.add(name!);
    parts.add(street);
    parts.add('$city, $state $zipCode');
    parts.add(country);
    return parts.join('\n');
  }
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

  const Order({
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
  
  bool get isDelivered => status == OrderStatus.delivered;
  
  bool get isCancelled => status == OrderStatus.cancelled;
  
  bool get isReturned => status == OrderStatus.returned;
  
  bool get isActive => !isCancelled && !isReturned && !isDelivered;

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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Order &&
        other.id == id &&
        other.userId == userId &&
        other.orderNumber == orderNumber &&
        other.items == items &&
        other.subtotal == subtotal &&
        other.tax == tax &&
        other.shipping == shipping &&
        other.discount == discount &&
        other.total == total &&
        other.status == status &&
        other.shippingAddress == shippingAddress &&
        other.billingAddress == billingAddress &&
        other.paymentMethod == paymentMethod &&
        other.paymentId == paymentId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      userId,
      orderNumber,
      items,
      subtotal,
      tax,
      shipping,
      discount,
      total,
      status,
      shippingAddress,
      billingAddress,
      paymentMethod,
      paymentId,
      createdAt,
      updatedAt,
    ]);
  }

  @override
  String toString() {
    return 'Order(id: $id, orderNumber: $orderNumber, status: $status, total: \$${total.toStringAsFixed(2)})';
  }
}
