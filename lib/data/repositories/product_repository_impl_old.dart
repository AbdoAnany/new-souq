import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/result.dart';
import '../../domain/repositories/repositories.dart';
import '../../models/product.dart';
import '../../models/category.dart';
import '../../models/offer.dart';
import '../../constants/app_constants.dart';

class ProductRepositoryImpl implements ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Result<List<Product>>> getFeaturedProducts({int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where('isFeatured', isEqualTo: true)
          .where('inStock', isEqualTo: true)
          .limit(limit)
          .get();

      final products = querySnapshot.docs
          .map((doc) => Product.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      return Result.success(products);
    } catch (e) {
      return Result.failure('Failed to fetch featured products: ${e.toString()}');
    }
  }

  @override
  Future<Result<Product>> getProductById(String productId) async {
    try {
      final docSnapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .doc(productId)
          .get();

      if (!docSnapshot.exists) {
        return Result.failure('Product not found');
      }

      final product = Product.fromJson({...docSnapshot.data()!, 'id': docSnapshot.id});
      return Result.success(product);
    } catch (e) {
      return Result.failure('Failed to fetch product: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Product>>> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? sortBy,
    bool? descending,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConstants.productsCollection)
          .where('inStock', isEqualTo: true);

      // Apply category filter
      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.where('categoryId', isEqualTo: categoryId);
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
      if (sortBy != null && sortBy.isNotEmpty) {
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
          case 'newest':
            query = query.orderBy('createdAt', descending: true);
            break;
          default:
            query = query.orderBy(sortBy, descending: descending ?? false);
        }
      } else {
        query = query.orderBy('createdAt', descending: true);
      }

      // Apply pagination
      final offset = (page - 1) * limit;
      query = query.limit(limit);
      
      if (offset > 0) {
        // For pagination beyond the first page, we would need to implement cursor-based pagination
        // For now, using offset which is less efficient but simpler
      }

      final querySnapshot = await query.get();
      var products = querySnapshot.docs
          .map((doc) => Product.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();

      // Apply search filter (in-memory since Firestore doesn't support full-text search)
      if (search != null && search.isNotEmpty) {
        final lowercaseQuery = search.toLowerCase();
        products = products.where((product) {
          return product.name.toLowerCase().contains(lowercaseQuery) ||
                 product.description.toLowerCase().contains(lowercaseQuery) ||
                 product.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery)) ||
                 (product.brand?.toLowerCase().contains(lowercaseQuery) ?? false);
        }).toList();
      }

      return Result.success(products);
    } catch (e) {
      return Result.failure('Failed to fetch products: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Product>>> getNewArrivals({int limit = 20}) async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final querySnapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where('inStock', isEqualTo: true)
          .where('createdAt', isGreaterThan: thirtyDaysAgo.toIso8601String())
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final products = querySnapshot.docs
          .map((doc) => Product.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      return Result.success(products);
    } catch (e) {
      return Result.failure('Failed to fetch new arrivals: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Product>>> getRelatedProducts(String productId) async {
    try {
      // First get the product to find its category
      final productResult = await getProductById(productId);
      if (productResult.isFailure) {
        return Result.failure('Failed to get product for related products');
      }

      final product = productResult.data!;
      
      final querySnapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where('categoryId', isEqualTo: product.categoryId)
          .where('inStock', isEqualTo: true)
          .where(FieldPath.documentId, isNotEqualTo: productId)
          .limit(6)
          .get();

      final products = querySnapshot.docs
          .map((doc) => Product.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      return Result.success(products);
    } catch (e) {
      return Result.failure('Failed to fetch related products: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Category>>> getCategories() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.categoriesCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      final categories = querySnapshot.docs
          .map((doc) => Category.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      return Result.success(categories);
    } catch (e) {
      return Result.failure('Failed to fetch categories: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Category>>> getSubcategories(String parentId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.categoriesCollection)
          .where('isActive', isEqualTo: true)
          .where('parentId', isEqualTo: parentId)
          .orderBy('name')
          .get();

      final categories = querySnapshot.docs
          .map((doc) => Category.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      return Result.success(categories);
    } catch (e) {
      return Result.failure('Failed to fetch subcategories: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Offer>>> getActiveOffers() async {
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

      final offers = querySnapshot.docs
          .map((doc) => Offer.fromJson({...doc.data(), 'id': doc.id}))
          .where((offer) => offer.isValid)
          .toList();

      return Result.success(offers);
    } catch (e) {
      return Result.failure('Failed to fetch active offers: ${e.toString()}');
    }
  }

  @override
  Future<Result<Map<String, double>>> getPriceRange(String? categoryId) async {
    try {
      Query query = _firestore
          .collection(AppConstants.productsCollection)
          .where('inStock', isEqualTo: true);

      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }

      final querySnapshot = await query.get();

      if (querySnapshot.docs.isEmpty) {
        return Result.success({'min': 0.0, 'max': 0.0});
      }

      final prices = querySnapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['price'] as num)
          .map((price) => price.toDouble())
          .toList();

      final minPrice = prices.reduce((a, b) => a < b ? a : b);
      final maxPrice = prices.reduce((a, b) => a > b ? a : b);

      return Result.success({'min': minPrice, 'max': maxPrice});
    } catch (e) {
      return Result.failure('Failed to get price range: ${e.toString()}');
    }
  }
}
