import 'package:equatable/equatable.dart';

// Product entity
class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final String categoryId;
  final String categoryName;
  final List<String> imageUrls;
  final int stockQuantity;
  final double rating;
  final int reviewCount;
  final Map<String, dynamic> specifications;
  final List<String> tags;
  final bool isActive;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.categoryId,
    required this.categoryName,
    required this.imageUrls,
    required this.stockQuantity,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.specifications = const {},
    this.tags = const [],
    this.isActive = true,
    this.isFeatured = false,
    required this.createdAt,
    this.updatedAt,
  });

  // Get effective price (discount price if available, otherwise regular price)
  double get effectivePrice => discountPrice ?? price;

  // Check if product has discount
  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  // Get discount percentage
  double get discountPercentage {
    if (!hasDiscount) return 0.0;
    return ((price - discountPrice!) / price) * 100;
  }

  // Check if product is in stock
  bool get isInStock => stockQuantity > 0;

  // Get primary image URL
  String? get primaryImageUrl => imageUrls.isNotEmpty ? imageUrls.first : null;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        discountPrice,
        categoryId,
        categoryName,
        imageUrls,
        stockQuantity,
        rating,
        reviewCount,
        specifications,
        tags,
        isActive,
        isFeatured,
        createdAt,
        updatedAt,
      ];
}
