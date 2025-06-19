import 'package:equatable/equatable.dart';

// Cart item entity
class CartItemEntity extends Equatable {
  final String productId;
  final String productName;
  final String? productImageUrl;
  final double unitPrice;
  final int quantity;
  final DateTime addedAt;

  const CartItemEntity({
    required this.productId,
    required this.productName,
    this.productImageUrl,
    required this.unitPrice,
    required this.quantity,
    required this.addedAt,
  });

  // Get total price for this item
  double get totalPrice => unitPrice * quantity;

  @override
  List<Object?> get props => [
        productId,
        productName,
        productImageUrl,
        unitPrice,
        quantity,
        addedAt,
      ];
}

// Cart entity
class CartEntity extends Equatable {
  final String id;
  final String userId;
  final List<CartItemEntity> items;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CartEntity({
    required this.id,
    required this.userId,
    required this.items,
    required this.createdAt,
    this.updatedAt,
  });

  // Get total items count
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  // Get total price
  double get totalPrice => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  // Check if cart is empty
  bool get isEmpty => items.isEmpty;

  // Check if cart has items
  bool get isNotEmpty => items.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        userId,
        items,
        createdAt,
        updatedAt,
      ];
}
