import 'package:souq/models/product.dart';

class Review {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String? userImage;
  final double rating;
  final String title;
  final String comment;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerifiedPurchase;
  final int helpfulCount;
  final List<String> helpfulUserIds;

  Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.rating,
    required this.title,
    required this.comment,
    this.images = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isVerifiedPurchase = false,
    this.helpfulCount = 0,
    this.helpfulUserIds = const [],
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userImage: json['userImage'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      title: json['title'] ?? '',
      comment: json['comment'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      isVerifiedPurchase: json['isVerifiedPurchase'] ?? false,
      helpfulCount: json['helpfulCount'] ?? 0,
      helpfulUserIds: List<String>.from(json['helpfulUserIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'rating': rating,
      'title': title,
      'comment': comment,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isVerifiedPurchase': isVerifiedPurchase,
      'helpfulCount': helpfulCount,
      'helpfulUserIds': helpfulUserIds,
    };
  }

  bool isHelpfulByUser(String userId) {
    return helpfulUserIds.contains(userId);
  }

  Review copyWith({
    String? id,
    String? productId,
    String? userId,
    String? userName,
    String? userImage,
    double? rating,
    String? title,
    String? comment,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerifiedPurchase,
    int? helpfulCount,
    List<String>? helpfulUserIds,
  }) {
    return Review(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerifiedPurchase: isVerifiedPurchase ?? this.isVerifiedPurchase,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      helpfulUserIds: helpfulUserIds ?? this.helpfulUserIds,
    );
  }
}

class Wishlist {
  final String id;
  final String userId;
  final List<WishlistItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  Wishlist({
    required this.id,
    required this.userId,
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Wishlist.fromJson(Map<String, dynamic> json) {
    return Wishlist(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => WishlistItem.fromJson(item))
              .toList() ??
          [],
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
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

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  int get itemCount => items.length;

  bool containsProduct(String productId) {
    return items.any((item) => item.productId == productId);
  }

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
}

class WishlistItem {
  final String id;
  final String productId;
  final Product product;
  final DateTime addedAt;

  WishlistItem({
    required this.id,
    required this.productId,
    required this.product,
    required this.addedAt,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      product: Product.fromJson(json['product'] ?? {}),
      addedAt:
          DateTime.parse(json['addedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'product': product.toJson(),
      'addedAt': addedAt.toIso8601String(),
    };
  }

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
}

class Offer {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final OfferType type;
  final double? discountPercentage;
  final double? discountAmount;
  final double? minimumPurchase;
  final List<String> applicableProducts;
  final List<String> applicableCategories;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int usageLimit;
  final int usedCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Offer({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.type,
    this.discountPercentage,
    this.discountAmount,
    this.minimumPurchase,
    this.applicableProducts = const [],
    this.applicableCategories = const [],
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.usageLimit = 0,
    this.usedCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      type: OfferType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => OfferType.percentage,
      ),
      discountPercentage: json['discountPercentage']?.toDouble(),
      discountAmount: json['discountAmount']?.toDouble(),
      minimumPurchase: json['minimumPurchase']?.toDouble(),
      applicableProducts: List<String>.from(json['applicableProducts'] ?? []),
      applicableCategories:
          List<String>.from(json['applicableCategories'] ?? []),
      startDate:
          DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ??
          DateTime.now().add(const Duration(days: 30)).toIso8601String()),
      isActive: json['isActive'] ?? true,
      usageLimit: json['usageLimit'] ?? 0,
      usedCount: json['usedCount'] ?? 0,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'type': type.name,
      'discountPercentage': discountPercentage,
      'discountAmount': discountAmount,
      'minimumPurchase': minimumPurchase,
      'applicableProducts': applicableProducts,
      'applicableCategories': applicableCategories,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'usageLimit': usageLimit,
      'usedCount': usedCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isValid {
    final now = DateTime.now();
    return isActive &&
        now.isAfter(startDate) &&
        now.isBefore(endDate) &&
        (usageLimit == 0 || usedCount < usageLimit);
  }

  bool get isExpired => DateTime.now().isAfter(endDate);

  bool get isUpcoming => DateTime.now().isBefore(startDate);

  Duration get timeLeft => endDate.difference(DateTime.now());

  bool canApplyToProduct(String productId) {
    return applicableProducts.isEmpty || applicableProducts.contains(productId);
  }

  bool canApplyToCategory(String categoryId) {
    return applicableCategories.isEmpty ||
        applicableCategories.contains(categoryId);
  }

  double calculateDiscount(double amount) {
    if (!isValid || (minimumPurchase != null && amount < minimumPurchase!)) {
      return 0.0;
    }

    switch (type) {
      case OfferType.percentage:
        return discountPercentage != null
            ? amount * (discountPercentage! / 100)
            : 0.0;
      case OfferType.fixed:
        return discountAmount ?? 0.0;
      case OfferType.buyOneGetOne:
        return 0.0; // Special handling required
      case OfferType.freeShipping:
        return 0.0; // Applied to shipping, not amount
    }
  }

  Offer copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    OfferType? type,
    double? discountPercentage,
    double? discountAmount,
    double? minimumPurchase,
    List<String>? applicableProducts,
    List<String>? applicableCategories,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    int? usageLimit,
    int? usedCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Offer(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountAmount: discountAmount ?? this.discountAmount,
      minimumPurchase: minimumPurchase ?? this.minimumPurchase,
      applicableProducts: applicableProducts ?? this.applicableProducts,
      applicableCategories: applicableCategories ?? this.applicableCategories,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      usageLimit: usageLimit ?? this.usageLimit,
      usedCount: usedCount ?? this.usedCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum OfferType {
  percentage,
  fixed,
  buyOneGetOne,
  freeShipping,
}

extension OfferTypeExtension on OfferType {
  String get displayName {
    switch (this) {
      case OfferType.percentage:
        return 'Percentage Discount';
      case OfferType.fixed:
        return 'Fixed Amount Discount';
      case OfferType.buyOneGetOne:
        return 'Buy One Get One';
      case OfferType.freeShipping:
        return 'Free Shipping';
    }
  }
}
