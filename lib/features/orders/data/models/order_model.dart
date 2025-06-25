import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/order_entity.dart';
import 'order_item_model.dart';
import 'shipping_address_model.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.userId,
    required super.orderNumber,
    required super.items,
    required super.subtotal,
    required super.shipping,
    required super.tax,
    required super.total,
    required super.status,
    required super.paymentStatus,
    required super.paymentMethod,
    required super.shippingAddress,
    required super.orderDate,
    super.shippedDate,
    super.deliveredDate,
    super.trackingNumber,
    super.notes,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Handle timestamp conversions with better error handling
    DateTime orderDate;
    try {
      if (json['createdAt'] is Timestamp) {
        orderDate = (json['createdAt'] as Timestamp).toDate();
      } else if (json['orderDate'] is String) {
        orderDate = DateTime.parse(json['orderDate'] as String);
      } else if (json['orderDate'] is Timestamp) {
        orderDate = (json['orderDate'] as Timestamp).toDate();
      } else if (json['createdAt'] != null) {
        // Handle various timestamp formats
        final createdAt = json['createdAt'];
        if (createdAt is Map) {
          orderDate = DateTime.fromMillisecondsSinceEpoch(
              (createdAt['seconds'] as int) * 1000);
        } else if (createdAt is int) {
          orderDate = DateTime.fromMillisecondsSinceEpoch(createdAt);
        } else {
          orderDate = DateTime.now();
        }
      } else {
        orderDate = DateTime.now();
      }
    } catch (e) {
      orderDate = DateTime.now();
    }

    DateTime? shippedDate;
    try {
      final shippedAt = json['shippedAt'] ?? json['shippedDate'];
      if (shippedAt is Timestamp) {
        shippedDate = shippedAt.toDate();
      } else if (shippedAt is String) {
        shippedDate = DateTime.parse(shippedAt);
      } else if (shippedAt is Map && shippedAt['seconds'] != null) {
        shippedDate = DateTime.fromMillisecondsSinceEpoch(
            (shippedAt['seconds'] as int) * 1000);
      }
    } catch (e) {
      // shippedDate remains null
    }

    DateTime? deliveredDate;
    try {
      final deliveredAt = json['deliveredAt'] ?? json['deliveredDate'];
      if (deliveredAt is Timestamp) {
        deliveredDate = deliveredAt.toDate();
      } else if (deliveredAt is String) {
        deliveredDate = DateTime.parse(deliveredAt);
      } else if (deliveredAt is Map && deliveredAt['seconds'] != null) {
        deliveredDate = DateTime.fromMillisecondsSinceEpoch(
            (deliveredAt['seconds'] as int) * 1000);
      }
    } catch (e) {
      // deliveredDate remains null
    }

    // Safely extract userId with null safety
    String userId = '';
    try {
      if (json.containsKey('userId') && json['userId'] != null) {
        userId = json['userId'].toString();
      }
    } catch (e) {
      // userId remains empty
    }

    // Handle order items with backward compatibility
    List<OrderItemModel> items = [];
    try {
      if (json['items'] != null) {
        items = (json['items'] as List<dynamic>).map((item) {
          try {
            return OrderItemModel.fromJson(item as Map<String, dynamic>);
          } catch (e) {
            // Try legacy format conversion
            return _convertLegacyOrderItem(item as Map<String, dynamic>);
          }
        }).toList();
      }
    } catch (e) {
      items = [];
    }

    // Handle shipping address with error handling
    ShippingAddressModel? shippingAddress;
    try {
      if (json['shippingAddress'] != null) {
        shippingAddress = ShippingAddressModel.fromJson(
            json['shippingAddress'] as Map<String, dynamic>);
      }
    } catch (e) {
      // Create a default shipping address if parsing fails
      shippingAddress = _createDefaultShippingAddress();
    }

    shippingAddress ??= _createDefaultShippingAddress();

    return OrderModel(
      id: (json['id'] as String?) ?? '',
      userId: userId,
      orderNumber: (json['orderNumber'] as String?) ?? '',
      items: items,
      subtotal: _parseDouble(json['subtotal']) ?? 0.0,
      shipping: _parseDouble(json['shipping']) ?? 0.0,
      tax: _parseDouble(json['tax']) ?? 0.0,
      total: _parseDouble(json['total']) ?? 0.0,
      status: _parseOrderStatus(json['status']),
      paymentStatus: _parsePaymentStatus(json['paymentStatus']),
      paymentMethod: _parsePaymentMethod(json['paymentMethod']),
      shippingAddress: shippingAddress,
      orderDate: orderDate,
      shippedDate: shippedDate,
      deliveredDate: deliveredDate,
      trackingNumber: json['trackingNumber'] as String?,
      notes: json['notes'] as String? ?? json['cancellationReason'] as String?,
    );
  }

  // Helper methods for safe parsing
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static OrderStatus _parseOrderStatus(dynamic value) {
    if (value == null) return OrderStatus.pending;
    final statusString = value.toString();
    return OrderStatus.values.firstWhere(
      (status) => status.name == statusString,
      orElse: () => OrderStatus.pending,
    );
  }

  static PaymentStatus _parsePaymentStatus(dynamic value) {
    if (value == null) return PaymentStatus.pending;
    final statusString = value.toString();
    return PaymentStatus.values.firstWhere(
      (status) => status.name == statusString,
      orElse: () => PaymentStatus.pending,
    );
  }

  static PaymentMethod _parsePaymentMethod(dynamic value) {
    if (value == null) return PaymentMethod.cashOnDelivery;
    final methodString = value.toString();
    return PaymentMethod.values.firstWhere(
      (method) => method.name == methodString,
      orElse: () => PaymentMethod.cashOnDelivery,
    );
  }

  static OrderItemModel _convertLegacyOrderItem(Map<String, dynamic> json) {
    return OrderItemModel(
      id: (json['id'] as String?) ?? '',
      productId: (json['productId'] as String?) ?? '',
      productName:
          (json['title'] as String?) ?? (json['productName'] as String?) ?? '',
      productImageUrl:
          (json['image'] as String?) ?? (json['productImageUrl'] as String?),
      unitPrice:
          _parseDouble(json['price']) ?? _parseDouble(json['unitPrice']) ?? 0.0,
      quantity: (json['quantity'] as int?) ?? 1,
    );
  }

  static ShippingAddressModel _createDefaultShippingAddress() {
    return const ShippingAddressModel(
      fullName: 'Unknown Customer',
      address: 'Address not provided',
      city: 'Unknown',
      state: 'Unknown',
      country: 'Unknown',
      postalCode: '00000',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'orderNumber': orderNumber,
      'items': items
          .map((item) => OrderItemModel.fromEntity(item).toJson())
          .toList(),
      'subtotal': subtotal,
      'shipping': shipping,
      'tax': tax,
      'total': total,
      'status': status.name,
      'paymentStatus': paymentStatus.name,
      'paymentMethod': paymentMethod.name,
      'shippingAddress':
          ShippingAddressModel.fromEntity(shippingAddress).toJson(),
      'orderDate': orderDate.toIso8601String(),
      'shippedDate': shippedDate?.toIso8601String(),
      'deliveredDate': deliveredDate?.toIso8601String(),
      'trackingNumber': trackingNumber,
      'notes': notes,
    };
  }

  factory OrderModel.fromEntity(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      userId: entity.userId,
      orderNumber: entity.orderNumber,
      items: entity.items,
      subtotal: entity.subtotal,
      shipping: entity.shipping,
      tax: entity.tax,
      total: entity.total,
      status: entity.status,
      paymentStatus: entity.paymentStatus,
      paymentMethod: entity.paymentMethod,
      shippingAddress: entity.shippingAddress,
      orderDate: entity.orderDate,
      shippedDate: entity.shippedDate,
      deliveredDate: entity.deliveredDate,
      trackingNumber: entity.trackingNumber,
      notes: entity.notes,
    );
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    String? orderNumber,
    List<OrderItemEntity>? items,
    double? subtotal,
    double? shipping,
    double? tax,
    double? total,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    PaymentMethod? paymentMethod,
    ShippingAddressEntity? shippingAddress,
    DateTime? orderDate,
    DateTime? shippedDate,
    DateTime? deliveredDate,
    String? trackingNumber,
    String? notes,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orderNumber: orderNumber ?? this.orderNumber,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      shipping: shipping ?? this.shipping,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      orderDate: orderDate ?? this.orderDate,
      shippedDate: shippedDate ?? this.shippedDate,
      deliveredDate: deliveredDate ?? this.deliveredDate,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      notes: notes ?? this.notes,
    );
  }
}
