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
    int? limit,
    String? startAfter,
    String? categoryId,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? sortBy,
    bool? descending,
  }) async {
    try {
      Query query = _firestore.collection(AppConstants.productsCollection);

      // Apply category filter
      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }

      // Apply search filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchTerms = searchQuery.toLowerCase().split(' ');
        for (final term in searchTerms) {
          query = query.where('searchTerms', arrayContains: term);
        }
      }

      // Apply price filters
      if (minPrice != null) {
        query = query.where('price', isGreaterThanOrEqualTo: minPrice);
      }
      if (maxPrice != null) {
        query = query.where('price', isLessThanOrEqualTo: maxPrice);
      }

      // Apply rating filter
      if (minRating != null) {
        query = query.where('rating', isGreaterThanOrEqualTo: minRating);
      }

      // Apply sorting
      if (sortBy != null) {
        query = query.orderBy(sortBy, descending: descending ?? false);
      } else {
        query = query.orderBy('createdAt', descending: true);
      }

      // Apply pagination
      if (startAfter != null) {
        final startAfterDoc = await _firestore
            .collection(AppConstants.productsCollection)
            .doc(startAfter)
            .get();
        if (startAfterDoc.exists) {
          query = query.startAfterDocument(startAfterDoc);
        }
      }      if (limit != null) {
        query = query.limit(limit);
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
  Future<Result<List<Product>, Failure>> getFeaturedProducts({int? limit}) async {
    try {
      Query query = _firestore
          .collection(AppConstants.productsCollection)
          .where('isFeatured', isEqualTo: true)
          .where('inStock', isEqualTo: true)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }      final querySnapshot = await query.get();

      final products = querySnapshot.docs
          .map((doc) => _mapDocumentToProduct(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      return Result.success(products);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to get featured products: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<Product>, Failure>> getNewArrivals({int? limit}) async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      Query query = _firestore
          .collection(AppConstants.productsCollection)
          .where('inStock', isEqualTo: true)
          .where('createdAt', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }      final querySnapshot = await query.get();

      final products = querySnapshot.docs
          .map((doc) => _mapDocumentToProduct(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      return Result.success(products);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to get new arrivals: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<Product>, Failure>> getRelatedProducts(String productId, {int? limit}) async {
    try {
      // First get the product to find its category
      final productResult = await getProductById(productId);
      if (productResult.isFailure) {
        return Result.failure((productResult as ResultFailure).failure);
      }

      final product = (productResult as Success).value;

      // Get related products from the same category
      Query query = _firestore
          .collection(AppConstants.productsCollection)
          .where('categoryId', isEqualTo: product.categoryId)
          .where('inStock', isEqualTo: true)
          .orderBy('rating', descending: true);

      if (limit != null) {
        query = query.limit(limit + 1); // Get one extra to exclude the current product
      }

      final querySnapshot = await query.get();      final products = querySnapshot.docs
          .map((doc) => _mapDocumentToProduct(doc.data() as Map<String, dynamic>, doc.id))
          .where((p) => p.id != productId) // Exclude the current product
          .take(limit ?? 5)
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
          .update({'inStock': false});

      return Result.success(null);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to delete product: ${e.toString()}'));
    }
  }
  // Helper methods
  Product _mapDocumentToProduct(Map<String, dynamic> data, String id) {
    final imagesData = data['images'] as List<dynamic>? ?? [];
    final images = imagesData.map((img) => img as String).toList();

    final specificationsData = data['specifications'] as Map<String, dynamic>? ?? {};
    final tagsData = data['tags'] as List<dynamic>? ?? [];
    final tags = tagsData.map((tag) => tag as String).toList();

    return Product(
      id: id,
      name: data['name'] as String,
      description: data['description'] as String,
      price: (data['price'] as num).toDouble(),
      originalPrice: data['originalPrice'] != null ? (data['originalPrice'] as num).toDouble() : null,
      categoryId: data['categoryId'] as String,
      category: data['category'] as String,
      images: images,
      inStock: data['inStock'] as bool? ?? true,
      quantity: data['quantity'] as int? ?? 0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: data['reviewCount'] as int? ?? 0,
      specifications: specificationsData,
      tags: tags,
      createdAt: data['createdAt'] is Timestamp 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.parse(data['createdAt'] as String),
      updatedAt: data['updatedAt'] is Timestamp 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : DateTime.parse(data['updatedAt'] as String),
      isFeatured: data['isFeatured'] as bool? ?? false,
      discountPercentage: data['discountPercentage'] != null ? (data['discountPercentage'] as num).toDouble() : null,
      brand: data['brand'] as String?,
      sku: data['sku'] as String?,
      weight: data['weight'] != null ? (data['weight'] as num).toDouble() : null,
      dimensions: data['dimensions'] as String?,
    );
  }

  Map<String, dynamic> _mapProductToDocument(Product product) {
    return {
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'originalPrice': product.originalPrice,
      'categoryId': product.categoryId,
      'category': product.category,
      'images': product.images,
      'inStock': product.inStock,
      'quantity': product.quantity,
      'rating': product.rating,
      'reviewCount': product.reviewCount,
      'specifications': product.specifications,
      'tags': product.tags,
      'searchTerms': _generateSearchTerms(product),
      'isFeatured': product.isFeatured,
      'discountPercentage': product.discountPercentage,
      'brand': product.brand,
      'sku': product.sku,
      'weight': product.weight,
      'dimensions': product.dimensions,
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
    
    // Add category terms
    terms.addAll(product.category.toLowerCase().split(' '));
    
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
  
  @override
  Future<Result<List<Product>, Failure>> getProductsByCategory(String categoryId, {int? limit}) async {
    try {
      Query query = _firestore.collection(AppConstants.productsCollection)
          .where('categoryId', isEqualTo: categoryId)
          .where('inStock', isEqualTo: true)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      final products = snapshot.docs.map((doc) => _mapDocumentToProduct(doc.data() as Map<String, dynamic>, doc.id)).toList();

      return Result.success(products);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to fetch products by category: ${e.toString()}'));
    }
  }
}
