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

  Product({
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

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      originalPrice: json['originalPrice']?.toDouble(),
      categoryId: json['categoryId'] ?? '',
      category: json['category'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      inStock: json['inStock'] ?? true,
      quantity: json['quantity'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      specifications: Map<String, dynamic>.from(json['specifications'] ?? {}),
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      isFeatured: json['isFeatured'] ?? false,
      discountPercentage: json['discountPercentage']?.toDouble(),
      brand: json['brand'],
      sku: json['sku'],
      weight: json['weight']?.toDouble(),
      dimensions: json['dimensions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'categoryId': categoryId,
      'category': category,
      'images': images,
      'inStock': inStock,
      'quantity': quantity,
      'rating': rating,
      'reviewCount': reviewCount,
      'specifications': specifications,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFeatured': isFeatured,
      'discountPercentage': discountPercentage,
      'brand': brand,
      'sku': sku,
      'weight': weight,
      'dimensions': dimensions,
    };
  }

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  double get discountAmount => hasDiscount ? originalPrice! - price : 0.0;

  String get mainImage => images.isNotEmpty ? images.first : '';

  bool get isAvailable => inStock && quantity > 0;

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
}

