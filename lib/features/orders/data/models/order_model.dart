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
    return OrderModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      orderNumber: json['orderNumber'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      shipping: (json['shipping'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      status: OrderStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (status) => status.name == json['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (method) => method.name == json['paymentMethod'],
        orElse: () => PaymentMethod.cashOnDelivery,
      ),
      shippingAddress: ShippingAddressModel.fromJson(
        json['shippingAddress'] as Map<String, dynamic>,
      ),
      orderDate: DateTime.parse(json['orderDate'] as String),
      shippedDate: json['shippedDate'] != null
          ? DateTime.parse(json['shippedDate'] as String)
          : null,
      deliveredDate: json['deliveredDate'] != null
          ? DateTime.parse(json['deliveredDate'] as String)
          : null,
      trackingNumber: json['trackingNumber'] as String?,
      notes: json['notes'] as String?,
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
