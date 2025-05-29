class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String categoryId;
  final String category;
  final List<String> images;
  final bool inStock;
  final int quantity;
  final double rating;
  final int reviewCount;
  final Map<String, dynamic> specifications;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFeatured;
  final double? discountPercentage;
  final String? brand;
  final String? sku;
  final double? weight;
  final String? dimensions;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.categoryId,
    required this.category,
    this.images = const [],
    this.inStock = true,
    this.quantity = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.specifications = const {},
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isFeatured = false,
    this.discountPercentage,
    this.brand,
    this.sku,
    this.weight,
    this.dimensions,
  });

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    String? categoryId,
    String? category,
    List<String>? images,
    bool? inStock,
    int? quantity,
    double? rating,
    int? reviewCount,
    Map<String, dynamic>? specifications,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFeatured,
    double? discountPercentage,
    String? brand,
    String? sku,
    double? weight,
    String? dimensions,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      images: images ?? this.images,
      inStock: inStock ?? this.inStock,
      quantity: quantity ?? this.quantity,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      specifications: specifications ?? this.specifications,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFeatured: isFeatured ?? this.isFeatured,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      brand: brand ?? this.brand,
      sku: sku ?? this.sku,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Product &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.price == price &&
        other.originalPrice == originalPrice &&
        other.categoryId == categoryId &&
        other.category == category &&
        other.images == images &&
        other.inStock == inStock &&
        other.quantity == quantity &&
        other.rating == rating &&
        other.reviewCount == reviewCount &&
        other.specifications == specifications &&
        other.tags == tags &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isFeatured == isFeatured &&
        other.discountPercentage == discountPercentage &&
        other.brand == brand &&
        other.sku == sku &&
        other.weight == weight &&
        other.dimensions == dimensions;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      name,
      description,
      price,
      originalPrice,
      categoryId,
      category,
      images,
      inStock,
      quantity,
      rating,
      reviewCount,
      specifications,
      tags,
      createdAt,
      updatedAt,
      isFeatured,
      discountPercentage,
      brand,
      sku,
      weight,
      dimensions,
    ]);
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, category: $category)';
  }

  // Getters for calculated properties
  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  
  double get discountAmount => hasDiscount ? originalPrice! - price : 0.0;
  
  double get calculatedDiscountPercentage {
    if (discountPercentage != null) return discountPercentage!;
    if (hasDiscount) {
      return ((originalPrice! - price) / originalPrice!) * 100;
    }
    return 0.0;
  }
  
  String get primaryImage => images.isNotEmpty ? images.first : '';
  
  bool get hasImages => images.isNotEmpty;
  
  bool get isOutOfStock => !inStock || quantity <= 0;
}
