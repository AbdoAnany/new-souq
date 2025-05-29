import 'product.dart';

class WishlistItem {
  final String id;
  final String productId;
  final Product product;
  final DateTime addedAt;

  const WishlistItem({
    required this.id,
    required this.productId,
    required this.product,
    required this.addedAt,
  });

  WishlistItem copyWith({
    String? id,
    String? productId,
    Product? product,
    DateTime? addedAt,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is WishlistItem &&
        other.id == id &&
        other.productId == productId &&
        other.product == product &&
        other.addedAt == addedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      productId,
      product,
      addedAt,
    );
  }

  @override
  String toString() {
    return 'WishlistItem(id: $id, productId: $productId, productName: ${product.name})';
  }
}

class Wishlist {
  final String id;
  final String userId;
  final List<WishlistItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Wishlist({
    required this.id,
    required this.userId,
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  int get itemCount => items.length;

  bool containsProduct(String productId) {
    return items.any((item) => item.productId == productId);
  }

  WishlistItem? getItem(String productId) {
    try {
      return items.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }

  List<Product> get products => items.map((item) => item.product).toList();

  Wishlist copyWith({
    String? id,
    String? userId,
    List<WishlistItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Wishlist(
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
    
    return other is Wishlist &&
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
    return 'Wishlist(id: $id, userId: $userId, itemCount: $itemCount)';
  }
}
