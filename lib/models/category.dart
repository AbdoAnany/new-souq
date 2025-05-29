
class Category {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String? parentId;
  final List<Category> subcategories;
  final int productCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.parentId,
    this.subcategories = const [],
    this.productCount = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      parentId: json['parentId'],
      subcategories: (json['subcategories'] as List<dynamic>?)
              ?.map((cat) => Category.fromJson(cat))
              .toList() ??
          [],
      productCount: json['productCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'parentId': parentId,
      'subcategories': subcategories.map((cat) => cat.toJson()).toList(),
      'productCount': productCount,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get hasSubcategories => subcategories.isNotEmpty;
  
  bool get isParentCategory => parentId == null;

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? parentId,
    List<Category>? subcategories,
    int? productCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      parentId: parentId ?? this.parentId,
      subcategories: subcategories ?? this.subcategories,
      productCount: productCount ?? this.productCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
