class Category {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String? parentId;
  final int productCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Category({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.parentId,
    this.productCount = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  bool get isParentCategory => parentId == null;
  bool get isSubcategory => parentId != null;
  
  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? parentId,
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
      productCount: productCount ?? this.productCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.imageUrl == imageUrl &&
        other.parentId == parentId &&
        other.productCount == productCount &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      name,
      description,
      imageUrl,
      parentId,
      productCount,
      isActive,
      createdAt,
      updatedAt,
    ]);
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, isActive: $isActive)';
  }
}
