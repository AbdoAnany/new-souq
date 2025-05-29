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

  const Offer({
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

  // Computed properties
  bool get isValid {
    final now = DateTime.now();
    return isActive && 
           startDate.isBefore(now) && 
           endDate.isAfter(now) &&
           (usageLimit == 0 || usedCount < usageLimit);
  }

  bool get hasUsageLimit => usageLimit > 0;
  
  bool get isExpired => DateTime.now().isAfter(endDate);
  
  bool get isNotStarted => DateTime.now().isBefore(startDate);
  
  double get remainingUsage {
    if (!hasUsageLimit) return double.infinity;
    return (usageLimit - usedCount).toDouble();
  }

  bool get hasMinimumPurchase => minimumPurchase != null && minimumPurchase! > 0;

  // Calculate discount for a given amount
  double calculateDiscount(double amount) {
    if (!isValid) return 0.0;
    if (hasMinimumPurchase && amount < minimumPurchase!) return 0.0;

    switch (type) {
      case OfferType.percentage:
        if (discountPercentage == null) return 0.0;
        return amount * (discountPercentage! / 100);
      case OfferType.fixed:
        if (discountAmount == null) return 0.0;
        return discountAmount!;
      case OfferType.freeShipping:
        // Free shipping discount would be calculated elsewhere
        return 0.0;
      case OfferType.buyOneGetOne:
        // BOGO discount would be calculated based on products
        return 0.0;
    }
  }

  // Check if offer applies to a specific product
  bool appliesTo({String? productId, String? categoryId}) {
    if (applicableProducts.isNotEmpty && productId != null) {
      return applicableProducts.contains(productId);
    }
    if (applicableCategories.isNotEmpty && categoryId != null) {
      return applicableCategories.contains(categoryId);
    }
    return applicableProducts.isEmpty && applicableCategories.isEmpty;
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Offer &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.imageUrl == imageUrl &&
        other.type == type &&
        other.discountPercentage == discountPercentage &&
        other.discountAmount == discountAmount &&
        other.minimumPurchase == minimumPurchase &&
        _listEquals(other.applicableProducts, applicableProducts) &&
        _listEquals(other.applicableCategories, applicableCategories) &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.isActive == isActive &&
        other.usageLimit == usageLimit &&
        other.usedCount == usedCount &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      title,
      description,
      imageUrl,
      type,
      discountPercentage,
      discountAmount,
      minimumPurchase,
      applicableProducts,
      applicableCategories,
      startDate,
      endDate,
      isActive,
      usageLimit,
      usedCount,
      createdAt,
      updatedAt,
    ]);
  }

  @override
  String toString() {
    return 'Offer(id: $id, title: $title, type: $type, isValid: $isValid)';
  }

  // Helper method for list comparison
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index++) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
