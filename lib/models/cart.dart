import 'package:souq/models/product.dart';


class CartItem {
  final String id;
  final String productId;
  final Product product;
  final int quantity;
  final double price;
  final DateTime addedAt;
  final Map<String, dynamic>? selectedVariants;

  CartItem({
    required this.id,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.price,
    required this.addedAt,
    this.selectedVariants,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      product: Product.fromJson(json['product'] ?? {}),
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
      addedAt: DateTime.parse(json['addedAt'] ?? DateTime.now().toIso8601String()),
      selectedVariants: json['selectedVariants'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'product': product.toJson(),
      'quantity': quantity,
      'price': price,
      'addedAt': addedAt.toIso8601String(),
      'selectedVariants': selectedVariants,
    };
  }

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
}

class Cart {
  final String id;
  final String userId;
  final List<CartItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cart({
    required this.id,
    required this.userId,
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromJson(item))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

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
}


// class OrderItem {
//   final String id;
//   final String productId;
//   final String productName;
//   final String productImage;
//   final int quantity;
//   final double price;
//   final double totalPrice;
//   final Map<String, dynamic>? selectedVariants;

//   OrderItem({
//     required this.id,
//     required this.productId,
//     required this.productName,
//     required this.productImage,
//     required this.quantity,
//     required this.price,
//     required this.totalPrice,
//     this.selectedVariants,
//   });

//   factory OrderItem.fromJson(Map<String, dynamic> json) {
//     return OrderItem(
//       id: json['id'] ?? '',
//       productId: json['productId'] ?? '',
//       productName: json['productName'] ?? '',
//       productImage: json['productImage'] ?? '',
//       quantity: json['quantity'] ?? 1,
//       price: (json['price'] ?? 0).toDouble(),
//       totalPrice: (json['totalPrice'] ?? 0).toDouble(),
//       selectedVariants: json['selectedVariants'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'productId': productId,
//       'productName': productName,
//       'productImage': productImage,
//       'quantity': quantity,
//       'price': price,
//       'totalPrice': totalPrice,
//       'selectedVariants': selectedVariants,
//     };
//   }

//   factory OrderItem.fromCartItem(CartItem cartItem) {
//     return OrderItem(
//       id: cartItem.id,
//       productId: cartItem.productId,
//       productName: cartItem.product.name,
//       productImage: cartItem.product.mainImage,
//       quantity: cartItem.quantity,
//       price: cartItem.price,
//       totalPrice: cartItem.totalPrice,
//       selectedVariants: cartItem.selectedVariants,
//     );
//   }
// }

// enum PaymentMethod {
//   cashOnDelivery,
//   creditCard,
//   paypal,
//   stripe,
//   unknown
// }

// extension PaymentMethodExtension on PaymentMethod {
//   String get displayName {
//     switch (this) {
//       case PaymentMethod.cashOnDelivery:
//         return 'Cash on Delivery';
//       case PaymentMethod.creditCard:
//         return 'Credit Card';
//       case PaymentMethod.paypal:
//         return 'PayPal';
//       case PaymentMethod.stripe:
//         return 'Stripe';
//       case PaymentMethod.unknown:
//         // TODO: Handle this case.
//         return 'Unknown';
//     }
//   }
// }
