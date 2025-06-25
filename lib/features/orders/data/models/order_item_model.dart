import '../../domain/entities/order_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.id,
    required super.productId,
    required super.productName,
    super.productImageUrl,
    required super.unitPrice,
    required super.quantity,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: (json['id'] as String?) ?? '',
      productId: (json['productId'] as String?) ?? '',
      // Handle both legacy and new field names
      productName:
          (json['productName'] as String?) ?? (json['title'] as String?) ?? '',
      productImageUrl:
          (json['productImageUrl'] as String?) ?? (json['image'] as String?),
      // Handle both legacy and new field names for price
      unitPrice: _parseDouble(json['unitPrice'] ?? json['price']),
      quantity: (json['quantity'] as int?) ?? 1,
    );
  }

  // Helper method for safe double parsing
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'unitPrice': unitPrice,
      'quantity': quantity,
    };
  }

  factory OrderItemModel.fromEntity(OrderItemEntity entity) {
    return OrderItemModel(
      id: entity.id,
      productId: entity.productId,
      productName: entity.productName,
      productImageUrl: entity.productImageUrl,
      unitPrice: entity.unitPrice,
      quantity: entity.quantity,
    );
  }
}
