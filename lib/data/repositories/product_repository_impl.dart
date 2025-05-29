import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/result.dart';
import '../../core/failure.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/entities/product.dart';
import '../../constants/app_constants.dart';

class ProductRepositoryImpl implements ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Result<List<Product>, Failure>> getFeaturedProducts({int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where('isFeatured', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .limit(limit)
          .get();

      final products = querySnapshot.docs
          .map((doc) => _mapDocumentToProduct(doc.data(), doc.id))
          .toList();

      return Result.success(products);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to get featured products: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Product, Failure>> getProductById(String productId) async {
    try {
      final productDoc = await _firestore
          .collection(AppConstants.productsCollection)
          .doc(productId)
          .get();

      if (productDoc.exists) {
        final productData = productDoc.data()!;
        final product = _mapDocumentToProduct(productData, productDoc.id);
        return Result.success(product);
      } else {
        return Result.failure(const NotFoundFailure('Product not found'));
      }
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to get product: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<Product>, Failure>> getProducts({
    String? categoryId,
    int? page,
    int? limit,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? sortBy,
    bool descending = false,
  }) async {
    try {
      Query query = _firestore.collection(AppConstants.productsCollection);

      // Apply category filter
      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }

      // Apply active filter
      query = query.where('isActive', isEqualTo: true);

      // Apply price filters
      if (minPrice != null) {
        query = query.where('price', isGreaterThanOrEqualTo: minPrice);
      }
      if (maxPrice != null) {
        query = query.where('price', isLessThanOrEqualTo: maxPrice);
      }

      // Apply rating filter
      if (minRating != null) {
        query = query.where('averageRating', isGreaterThanOrEqualTo: minRating);
      }

      // Apply sorting
      if (sortBy != null) {
        query = query.orderBy(sortBy, descending: descending);
      } else {
        query = query.orderBy('createdAt', descending: true);
      }

      // Apply pagination
      if (limit != null) {
        query = query.limit(limit);
      }

      if (page != null && page > 1 && limit != null) {
        final offset = (page - 1) * limit;
        query = query.offset(offset);
      }

      final querySnapshot = await query.get();

      final products = querySnapshot.docs
          .map((doc) => _mapDocumentToProduct(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      return Result.success(products);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to get products: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<Product>, Failure>> searchProducts({
    required String query,
    int? page,
    int? limit,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? sortBy,
    bool descending = false,
  }) async {
    try {
      Query firestoreQuery = _firestore.collection(AppConstants.productsCollection);

      // Apply active filter
      firestoreQuery = firestoreQuery.where('isActive', isEqualTo: true);

      // Apply category filter
      if (categoryId != null && categoryId.isNotEmpty) {
        firestoreQuery = firestoreQuery.where('categoryId', isEqualTo: categoryId);
      }

      // Apply text search (using array-contains for search terms)
      if (query.isNotEmpty) {
        final searchTerms = query.toLowerCase().split(' ');
        for (final term in searchTerms) {
          firestoreQuery = firestoreQuery.where('searchTerms', arrayContains: term);
        }
      }

      // Apply price filters
      if (minPrice != null) {
        firestoreQuery = firestoreQuery.where('price', isGreaterThanOrEqualTo: minPrice);
      }
      if (maxPrice != null) {
        firestoreQuery = firestoreQuery.where('price', isLessThanOrEqualTo: maxPrice);
      }

      // Apply rating filter
      if (minRating != null) {
        firestoreQuery = firestoreQuery.where('averageRating', isGreaterThanOrEqualTo: minRating);
      }

      // Apply sorting
      if (sortBy != null) {
        firestoreQuery = firestoreQuery.orderBy(sortBy, descending: descending);
      }

      // Apply pagination
      if (limit != null) {
        firestoreQuery = firestoreQuery.limit(limit);
      }

      final querySnapshot = await firestoreQuery.get();

      final products = querySnapshot.docs
          .map((doc) => _mapDocumentToProduct(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      return Result.success(products);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to search products: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<Product>, Failure>> getNewArrivals({int limit = 10}) async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      final querySnapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where('isActive', isEqualTo: true)
          .where('createdAt', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final products = querySnapshot.docs
          .map((doc) => _mapDocumentToProduct(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      return Result.success(products);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to get new arrivals: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<Product>, Failure>> getRelatedProducts(String productId, {int limit = 5}) async {
    try {
      // First get the product to find its category
      final productResult = await getProductById(productId);
      if (productResult.isFailure) {
        return Result.failure(productResult.failure);
      }

      final product = productResult.value;

      // Get related products from the same category
      final querySnapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where('categoryId', isEqualTo: product.categoryId)
          .where('isActive', isEqualTo: true)
          .limit(limit + 1) // Get one extra to exclude the current product
          .get();

      final products = querySnapshot.docs
          .map((doc) => _mapDocumentToProduct(doc.data() as Map<String, dynamic>, doc.id))
          .where((p) => p.id != productId) // Exclude the current product
          .take(limit)
          .toList();

      return Result.success(products);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to get related products: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Product, Failure>> createProduct(Product product) async {
    try {
      final productRef = _firestore
          .collection(AppConstants.productsCollection)
          .doc();

      final productWithId = product.copyWith(
        id: productRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await productRef.set(_mapProductToDocument(productWithId));

      return Result.success(productWithId);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to create product: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Product, Failure>> updateProduct(Product product) async {
    try {
      final productRef = _firestore
          .collection(AppConstants.productsCollection)
          .doc(product.id);

      final updatedProduct = product.copyWith(updatedAt: DateTime.now());

      await productRef.update(_mapProductToDocument(updatedProduct));

      return Result.success(updatedProduct);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to update product: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void, Failure>> deleteProduct(String productId) async {
    try {
      await _firestore
          .collection(AppConstants.productsCollection)
          .doc(productId)
          .update({'isActive': false});

      return Result.success(null);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to delete product: ${e.toString()}'));
    }
  }

  // Helper methods
  Product _mapDocumentToProduct(Map<String, dynamic> data, String id) {
    final imagesData = data['images'] as List<dynamic>? ?? [];
    final images = imagesData.map((img) => img as String).toList();

    final variantsData = data['variants'] as List<dynamic>? ?? [];
    final variants = variantsData
        .map((variantData) => ProductVariant.fromMap(Map<String, dynamic>.from(variantData)))
        .toList();

    final specificationsData = data['specifications'] as Map<String, dynamic>? ?? {};

    return Product(
      id: id,
      name: data['name'] as String,
      description: data['description'] as String,
      price: (data['price'] as num).toDouble(),
      originalPrice: data['originalPrice'] != null ? (data['originalPrice'] as num).toDouble() : null,
      categoryId: data['categoryId'] as String,
      categoryName: data['categoryName'] as String,
      images: images,
      thumbnailUrl: data['thumbnailUrl'] as String?,
      stockQuantity: data['stockQuantity'] as int,
      variants: variants,
      specifications: specificationsData,
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: data['reviewCount'] as int? ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      isFeatured: data['isFeatured'] as bool? ?? false,
      isActive: data['isActive'] as bool? ?? true,
      weight: data['weight'] != null ? (data['weight'] as num).toDouble() : null,
      dimensions: data['dimensions'] != null 
          ? ProductDimensions.fromMap(Map<String, dynamic>.from(data['dimensions']))
          : null,
      brand: data['brand'] as String?,
      sku: data['sku'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> _mapProductToDocument(Product product) {
    return {
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'originalPrice': product.originalPrice,
      'categoryId': product.categoryId,
      'categoryName': product.categoryName,
      'images': product.images,
      'thumbnailUrl': product.thumbnailUrl,
      'stockQuantity': product.stockQuantity,
      'variants': product.variants.map((variant) => variant.toMap()).toList(),
      'specifications': product.specifications,
      'averageRating': product.averageRating,
      'reviewCount': product.reviewCount,
      'tags': product.tags,
      'searchTerms': _generateSearchTerms(product),
      'isFeatured': product.isFeatured,
      'isActive': product.isActive,
      'weight': product.weight,
      'dimensions': product.dimensions?.toMap(),
      'brand': product.brand,
      'sku': product.sku,
      'createdAt': Timestamp.fromDate(product.createdAt),
      'updatedAt': Timestamp.fromDate(product.updatedAt),
    };
  }

  List<String> _generateSearchTerms(Product product) {
    final terms = <String>{};
    
    // Add product name terms
    terms.addAll(product.name.toLowerCase().split(' '));
    
    // Add description terms
    terms.addAll(product.description.toLowerCase().split(' '));
    
    // Add category name terms
    terms.addAll(product.categoryName.toLowerCase().split(' '));
    
    // Add brand terms
    if (product.brand != null) {
      terms.addAll(product.brand!.toLowerCase().split(' '));
    }
    
    // Add tags
    terms.addAll(product.tags.map((tag) => tag.toLowerCase()));
    
    // Remove short terms and common words
    return terms
        .where((term) => term.length > 2)
        .where((term) => !['the', 'and', 'for', 'with', 'are', 'was'].contains(term))
        .toList();
  }
}
