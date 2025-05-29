import 'product.dart';

class CartItem {
  final String id;
  final String productId;
  final Product product;
  final int quantity;
  final double price;
  final DateTime addedAt;
  final Map<String, dynamic>? selectedVariants;

  const CartItem({
    required this.id,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.price,
    required this.addedAt,
    this.selectedVariants,
  });

  double get totalPrice => price * quantity;

  CartItem copyWith({
    String? id,
    String? productId,
    Product? product,
    int? quantity,
    double? price,
    DateTime? addedAt,
    Map<String, dynamic>? selectedVariants,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      addedAt: addedAt ?? this.addedAt,
      selectedVariants: selectedVariants ?? this.selectedVariants,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is CartItem &&
        other.id == id &&
        other.productId == productId &&
        other.product == product &&
        other.quantity == quantity &&
        other.price == price &&
        other.addedAt == addedAt &&
        other.selectedVariants == selectedVariants;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      productId,
      product,
      quantity,
      price,
      addedAt,
      selectedVariants,
    );
  }

  @override
  String toString() {
    return 'CartItem(id: $id, productId: $productId, quantity: $quantity, price: $price)';
  }
}

class Cart {
  final String id;
  final String userId;
  final List<CartItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Cart({
    required this.id,
    required this.userId,
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get tax => subtotal * 0.1; // 10% tax

  double get shipping => subtotal > 100 ? 0.0 : 10.0; // Free shipping over $100

  double get total => subtotal + tax + shipping;

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  Cart copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cart(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Cart &&
        other.id == id &&
        other.userId == userId &&
        other.items == items &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      items,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'Cart(id: $id, userId: $userId, items: ${items.length}, total: \$${total.toStringAsFixed(2)})';
  }

  // Helper methods
  CartItem? getItem(String productId) {
    try {
      return items.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }

  bool containsProduct(String productId) {
    return items.any((item) => item.productId == productId);
  }

  int getProductQuantity(String productId) {
    final item = getItem(productId);
    return item?.quantity ?? 0;
  }
}
