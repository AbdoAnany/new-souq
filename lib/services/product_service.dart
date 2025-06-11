import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:souq/core/constants/app_constants.dart';
import 'package:souq/models/category.dart' as models;
import 'package:souq/models/offer.dart';
import 'package:souq/models/product.dart';

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
  // Get products by category (including subcategories)
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
      // First, get all subcategory IDs for this category
      List<String> categoryIds = [categoryId];
      
      try {
        final subcategories = await getSubcategories(categoryId);
        categoryIds.addAll(subcategories.map((cat) => cat.id).toList());
      } catch (e) {
        if (kDebugMode) {
          print('Warning: Could not fetch subcategories for $categoryId: $e');
        }
        // Continue with just the parent category if subcategories fail
      }

      // Get products from all category IDs (parent + subcategories)
      List<Product> allProducts = [];
      
      for (String catId in categoryIds) {
        try {
          Query query = _firestore
              .collection(AppConstants.productsCollection)
              .where('categoryId', isEqualTo: catId)
              .where('inStock', isEqualTo: true);

          QuerySnapshot querySnapshot = await query.get();
          List<Product> categoryProducts = querySnapshot.docs
              .map((doc) => Product.fromJson(
                  {...(doc.data() as Map<String, dynamic>), 'id': doc.id}))
              .toList();
              
          allProducts.addAll(categoryProducts);
        } catch (e) {
          if (kDebugMode) {
            print('Warning: Could not fetch products for category $catId: $e');
          }
          // Continue with other categories if one fails
        }
      }

      // Remove duplicates (in case a product appears in multiple queries)
      final uniqueProducts = <String, Product>{};
      for (final product in allProducts) {
        uniqueProducts[product.id] = product;
      }
      List<Product> products = uniqueProducts.values.toList();

      // Apply price and rating filters client-side to avoid composite index issues
      if (minPrice != null) {
        products = products.where((product) => product.price >= minPrice).toList();
      }
      if (maxPrice != null) {
        products = products.where((product) => product.price <= maxPrice).toList();
      }
      if (minRating != null && minRating > 0) {
        products = products.where((product) => product.rating >= minRating).toList();
      }

      // Apply pagination
      if (lastProductId != null && products.isNotEmpty) {
        final lastProductIndex = products.indexWhere((p) => p.id == lastProductId);
        if (lastProductIndex >= 0 && lastProductIndex < products.length - 1) {
          products = products.sublist(lastProductIndex + 1);
        }
      }

      // Limit results
      if (products.length > limit) {
        products = products.sublist(0, limit);
      }

      return products;
    } catch (e) {
      throw Exception('Failed to fetch products: ${e.toString()}');
    }
  }

  // Search products
  Future<List<Product>> searchProducts({
    required String query,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? sortBy,
    bool descending = false,
  }) async {
    try {
      var firebaseQuery = _firestore
          .collection(AppConstants.productsCollection)
          .where('inStock', isEqualTo: true);

      // Search by name (basic text search)
      if (query.isNotEmpty) {
        firebaseQuery = firebaseQuery
            .where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThanOrEqualTo: '$query\uf8ff');
      }

      if (sortBy != null) {
        firebaseQuery = firebaseQuery.orderBy(sortBy, descending: descending);
      } else {
        firebaseQuery = firebaseQuery.orderBy('createdAt', descending: true);
      }

      final querySnapshot = await firebaseQuery.get();
      var products = querySnapshot.docs
          .map((doc) => Product.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      // Apply filters client-side
      if (minPrice != null) {
        products = products.where((product) => product.price >= minPrice).toList();
      }
      if (maxPrice != null) {
        products = products.where((product) => product.price <= maxPrice).toList();
      }
      if (minRating != null) {
        products = products.where((product) => product.rating >= minRating).toList();
      }

      return products;
    } catch (e) {
      throw Exception('Failed to search products: ${e.toString()}');
    }
  }

  // Get product by ID
  Future<Product?> getProductById(String productId) async {
    try {
      final productDoc = await _firestore
          .collection(AppConstants.productsCollection)
          .doc(productId)
          .get();

      if (!productDoc.exists) {
        return null;
      }

      final product = Product.fromJson({...productDoc.data()!, 'id': productDoc.id});
      return product;
    } catch (e) {
      throw Exception('Failed to fetch product: ${e.toString()}');
    }
  }  // Get categories
  Future<List<models.Category>> getCategories() async {
    try {
      // Fetch all categories without filters to avoid index issues
      final querySnapshot = await _firestore
          .collection(AppConstants.categoriesCollection)
          .get();

      // Filter and sort on the client side
      final categories = querySnapshot.docs
          .map((doc) => models.Category.fromJson({...doc.data(), 'id': doc.id}))
          .where((category) {
            // Filter only active categories
            return category.isActive == true; // Explicitly check for true value
          })
          .toList();
        // Sort by name
      categories.sort((a, b) {
        return a.name.compareTo(b.name);
      });

      return categories;
    } catch (e) {
      if (kDebugMode) {
        print('Error in getCategories: ${e.toString()}');
      }
      throw Exception('Failed to fetch categories: ${e.toString()}');
    }
  }
  // Get parent categories
  Future<List<models.Category>> getParentCategories() async {
    try {
      // Fetch categories without complex filters/ordering to avoid index issues
      final querySnapshot = await _firestore
          .collection(AppConstants.categoriesCollection)
          .get();

      // Filter and sort on the client side
      final categories = querySnapshot.docs
          .map((doc) => models.Category.fromJson({...doc.data(), 'id': doc.id}))
          .where((category) => 
            category.isActive == true && 
            category.parentId == null)
          .toList();
        // Sort by name
      categories.sort((a, b) {
        return a.name.compareTo(b.name);
      });

      return categories;
    } catch (e) {
      if (kDebugMode) {
        print('Error in getParentCategories: ${e.toString()}');
      }
      throw Exception('Failed to fetch parent categories: ${e.toString()}');
    }
  }
  // Get subcategories
  Future<List<models.Category>> getSubcategories(String parentCategoryId) async {
    try {
      // Use a simplified query that doesn't require complex indexes
      final querySnapshot = await _firestore
          .collection(AppConstants.categoriesCollection)
          .where('parentId', isEqualTo: parentCategoryId)
          .get();

      // Filter active categories and sort client-side
      final categories = querySnapshot.docs
          .map((doc) => models.Category.fromJson({...doc.data(), 'id': doc.id}))
          .where((category) => category.isActive == true)
          .toList();
        // Sort by name
      categories.sort((a, b) {
        return a.name.compareTo(b.name);
      });

      return categories;
    } catch (e) {
      if (kDebugMode) {
        print('Error in getSubcategories: ${e.toString()}');
      }
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
      // Simplify the query to avoid complex index requirements
      // Only filter on isActive and endDate (keeping offers that haven't expired yet)
      final querySnapshot = await _firestore
          .collection(AppConstants.offersCollection)
          // .where('isActive', isEqualTo: true)
          // .where('endDate', isGreaterThan: Timestamp.fromDate(now))
          // .orderBy('endDate')
          .get();      // Filter the valid offers client-side
      final offers = querySnapshot.docs
          .map((doc) => Offer.fromJson({...doc.data(), 'id': doc.id}))
          .where((offer) => 
              offer.isValid && 
              (offer.startDate.isBefore(now) || offer.startDate.isAtSameMomentAs(now)))
          .toList();// Sort by discount percentage client-side (handling potential nulls)
      offers.sort((a, b) {
        // Handle cases where discountPercentage might be null
        final aDiscount = a.discountPercentage ?? 0;
        final bDiscount = b.discountPercentage ?? 0;
        return bDiscount.compareTo(aDiscount);
      });

      return offers;
    } catch (e) {
      if (kDebugMode) {
        print('Error in getActiveOffers: ${e.toString()}');
      }
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
  Future<Map<String, double>> getPriceRangeForCategory(
      String categoryId) async {
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
