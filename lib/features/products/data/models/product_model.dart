import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/product_entity.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel extends ProductEntity {
  const ProductModel({
    required String id,
    required String name,
    required String description,
    required double price,
    double? discountPrice,
    required String categoryId,
    required String categoryName,
    required List<String> imageUrls,
    required int stockQuantity,
    double rating = 0.0,
    int reviewCount = 0,
    Map<String, dynamic> specifications = const {},
    List<String> tags = const [],
    bool isActive = true,
    bool isFeatured = false,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) : super(
          id: id,
          name: name,
          description: description,
          price: price,
          discountPrice: discountPrice,
          categoryId: categoryId,
          categoryName: categoryName,
          imageUrls: imageUrls,
          stockQuantity: stockQuantity,
          rating: rating,
          reviewCount: reviewCount,
          specifications: specifications,
          tags: tags,
          isActive: isActive,
          isFeatured: isFeatured,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      discountPrice: entity.discountPrice,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      imageUrls: entity.imageUrls,
      stockQuantity: entity.stockQuantity,
      rating: entity.rating,
      reviewCount: entity.reviewCount,
      specifications: entity.specifications,
      tags: entity.tags,
      isActive: entity.isActive,
      isFeatured: entity.isFeatured,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      name: name,
      description: description,
      price: price,
      discountPrice: discountPrice,
      categoryId: categoryId,
      categoryName: categoryName,
      imageUrls: imageUrls,
      stockQuantity: stockQuantity,
      rating: rating,
      reviewCount: reviewCount,
      specifications: specifications,
      tags: tags,
      isActive: isActive,
      isFeatured: isFeatured,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    String? categoryId,
    String? categoryName,
    List<String>? imageUrls,
    int? stockQuantity,
    double? rating,
    int? reviewCount,
    Map<String, dynamic>? specifications,
    List<String>? tags,
    bool? isActive,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      imageUrls: imageUrls ?? this.imageUrls,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      specifications: specifications ?? this.specifications,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
