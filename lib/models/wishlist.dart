class WishlistItem {
  final String productId;
  final DateTime addedAt;

  WishlistItem({
    required this.productId,
    required this.addedAt,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      productId: json['productId'],
      addedAt: json['addedAt'] != null 
          ? (json['addedAt'] is DateTime 
              ? json['addedAt'] 
              : DateTime.parse(json['addedAt']))
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'addedAt': addedAt.toIso8601String(),
    };
  }
}

class Wishlist {
  final String userId;
  final List<WishlistItem> items;

  Wishlist({
    required this.userId,
    required this.items,
  });

  factory Wishlist.fromJson(Map<String, dynamic> json) {
    return Wishlist(
      userId: json['userId'],
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => WishlistItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  bool contains(String productId) {
    return items.any((item) => item.productId == productId);
  }

  int get itemCount => items.length;

  bool get isEmpty => items.isEmpty;
}
