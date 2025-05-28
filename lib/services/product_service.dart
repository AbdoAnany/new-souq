import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:souq/models/product.dart' hide Category;
import 'package:souq/models/offer.dart';
import 'package:souq/models/category.dart';
import 'package:souq/constants/app_constants.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get featured products
  Future<List<Product>> getFeaturedProducts({int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where('isFeatured', isEqualTo: true)
          .where('inStock', isEqualTo: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => Product.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch featured products: ${e.toString()}');
    }
  }

  // Get products by category
  Future<List<Product>> getProductsByCategory({
    required String categoryId,
    String? lastProductId,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? sortBy,
    int limit = AppConstants.pageSize,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConstants.productsCollection)
          .where('categoryId', isEqualTo: categoryId)
          .where('inStock', isEqualTo: true);

      // Apply price filter
      if (minPrice != null) {
        query = query.where('price', isGreaterThanOrEqualTo: minPrice);
      }
      if (maxPrice != null) {
        query = query.where('price', isLessThanOrEqualTo: maxPrice);
      }

      // Apply rating filter
      if (minRating != null && minRating > 0) {
        query = query.where('rating', isGreaterThanOrEqualTo: minRating);
      }

      // Apply sorting
      switch (sortBy) {
        case 'price_asc':
          query = query.orderBy('price', descending: false);
          break;
        case 'price_desc':
          query = query.orderBy('price', descending: true);
          break;
        case 'rating':
          query = query.orderBy('rating', descending: true);
          break;
        case 'popularity':
          query = query.orderBy('purchaseCount', descending: true);
          break;
        default:
          query = query.orderBy('createdAt', descending: true);
      }

      // Apply pagination
      if (lastProductId != null) {
        final lastDoc = await _firestore
            .collection(AppConstants.productsCollection)
            .doc(lastProductId)
            .get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      query = query.limit(limit);

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => Product.fromJson({...(doc.data() as Map<String, dynamic>), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: ${e.toString()}');
    }
  }

  // Search products
  Future<List<Product>> searchProducts({
    required String query,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? sortBy,
    bool? sortDescending,
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query firestoreQuery = _firestore
          .collection(AppConstants.productsCollection)
          .where('inStock', isEqualTo: true);

      // Add category filter
      if (categoryId != null && categoryId.isNotEmpty) {
        firestoreQuery = firestoreQuery.where('categoryId', isEqualTo: categoryId);
      }

      // Add price filters
      if (minPrice != null) {
        firestoreQuery = firestoreQuery.where('price', isGreaterThanOrEqualTo: minPrice);
      }
      if (maxPrice != null) {
        firestoreQuery = firestoreQuery.where('price', isLessThanOrEqualTo: maxPrice);
      }

      // Add rating filter
      if (minRating != null) {
        firestoreQuery = firestoreQuery.where('rating', isGreaterThanOrEqualTo: minRating);
      }

      // Add sorting
      if (sortBy != null) {
        firestoreQuery = firestoreQuery.orderBy(sortBy, descending: sortDescending ?? false);
      } else {
        firestoreQuery = firestoreQuery.orderBy('createdAt', descending: true);
      }

      firestoreQuery = firestoreQuery.limit(limit);

      if (lastDocument != null) {
        firestoreQuery = firestoreQuery.startAfterDocument(lastDocument);
      }

      final querySnapshot = await firestoreQuery.get();
      final products = querySnapshot.docs
          .map((doc) => Product.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();

      // Filter by search query in memory (since Firestore doesn't support full-text search)
      if (query.isNotEmpty) {
        final lowercaseQuery = query.toLowerCase();
        return products.where((product) {
          return product.name.toLowerCase().contains(lowercaseQuery) ||
                 product.description.toLowerCase().contains(lowercaseQuery) ||
                 product.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery)) ||
                 (product.brand?.toLowerCase().contains(lowercaseQuery) ?? false);
        }).toList();
      }

      return products;
    } catch (e) {
      throw Exception('Failed to search products: ${e.toString()}');
    }
  }

  // Get product by ID
  Future<Product?> getProductById(String productId) async {
    try {
      final docSnapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .doc(productId)
          .get();

      if (docSnapshot.exists) {
        return Product.fromJson({...docSnapshot.data()!, 'id': docSnapshot.id});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch product: ${e.toString()}');
    }
  }

  // Get categories
  Future<List<Category>> getCategories() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.categoriesCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => Category.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: ${e.toString()}');
    }
  }

  // Get parent categories
  Future<List<Category>> getParentCategories() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.categoriesCollection)
          .where('isActive', isEqualTo: true)
          .where('parentId', isNull: true)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => Category.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch parent categories: ${e.toString()}');
    }
  }

  // Get subcategories
  Future<List<Category>> getSubcategories(String parentCategoryId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.categoriesCollection)
          .where('isActive', isEqualTo: true)
          .where('parentId', isEqualTo: parentCategoryId)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => Category.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch subcategories: ${e.toString()}');
    }
  }

  // Get related products
  Future<List<Product>> getRelatedProducts({
    required String productId,
    required String categoryId,
    int limit = 6,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where('categoryId', isEqualTo: categoryId)
          .where('inStock', isEqualTo: true)
          .where(FieldPath.documentId, isNotEqualTo: productId)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => Product.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch related products: ${e.toString()}');
    }
  }

  // Get product recommendations
  Future<List<Product>> getRecommendedProducts({
    required String userId,
    int limit = 10,
  }) async {
    try {
      // This is a simplified recommendation system
      // In a real app, you would implement more sophisticated algorithms
      final querySnapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where('inStock', isEqualTo: true)
          .where('rating', isGreaterThanOrEqualTo: 4.0)
          .orderBy('rating', descending: true)
          .orderBy('reviewCount', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => Product.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch recommended products: ${e.toString()}');
    }
  }

  // Get active offers
  Future<List<Offer>> getActiveOffers() async {
    try {
      final now = DateTime.now();
      final querySnapshot = await _firestore
          .collection(AppConstants.offersCollection)
          .where('isActive', isEqualTo: true)
          .where('startDate', isLessThanOrEqualTo: now)
          .where('endDate', isGreaterThan: now)
          .orderBy('endDate')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Offer.fromJson({...doc.data(), 'id': doc.id}))
          .where((offer) => offer.isValid)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch active offers: ${e.toString()}');
    }
  }

  // Get products on sale
  Future<List<Product>> getProductsOnSale({int limit = 20}) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where('inStock', isEqualTo: true)
          .where('originalPrice', isNull: false)
          .orderBy('originalPrice')
          .orderBy('discountPercentage', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => Product.fromJson({...doc.data(), 'id': doc.id}))
          .where((product) => product.hasDiscount)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products on sale: ${e.toString()}');
    }
  }

  // Get new arrivals
  Future<List<Product>> getNewArrivals({int limit = 20}) async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final querySnapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where('inStock', isEqualTo: true)
          .where('createdAt', isGreaterThan: thirtyDaysAgo)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => Product.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch new arrivals: ${e.toString()}');
    }
  }

  // Get best sellers
  Future<List<Product>> getBestSellers({int limit = 20}) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where('inStock', isEqualTo: true)
          .orderBy('reviewCount', descending: true)
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => Product.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch best sellers: ${e.toString()}');
    }
  }

  // Update product rating
  Future<void> updateProductRating({
    required String productId,
    required double newRating,
    required int newReviewCount,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.productsCollection)
          .doc(productId)
          .update({
        'rating': newRating,
        'reviewCount': newReviewCount,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update product rating: ${e.toString()}');
    }
  }

  // Get price range for category
  Future<Map<String, double>> getPriceRangeForCategory(String categoryId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where('categoryId', isEqualTo: categoryId)
          .where('inStock', isEqualTo: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return {'min': 0.0, 'max': 0.0};
      }

      final prices = querySnapshot.docs
          .map((doc) => (doc.data()['price'] as num).toDouble())
          .toList();

      return {
        'min': prices.reduce((a, b) => a < b ? a : b),
        'max': prices.reduce((a, b) => a > b ? a : b),
      };
    } catch (e) {
      throw Exception('Failed to get price range: ${e.toString()}');
    }
  }

  // Get product count by category
  Future<int> getProductCountByCategory(String categoryId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where('categoryId', isEqualTo: categoryId)
          .where('inStock', isEqualTo: true)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }
}
