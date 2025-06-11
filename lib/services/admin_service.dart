import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:souq/core/constants/app_constants.dart';
import 'package:souq/models/category.dart';
import 'package:souq/models/offer.dart';
import 'package:souq/models/product.dart';
import 'package:uuid/uuid.dart';

class AdminService {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Product Management
  Future<String> addProduct(Map<String, dynamic> productData) async {
    try {
      final productId = _uuid.v4();
      final now = DateTime.now();

      final product = {
        ...productData,
        'id': productId,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      await _firestore
          .collection(AppConstants.productsCollection)
          .doc(productId)
          .set(product);

      return productId;
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  Future<void> updateProduct(
      String productId, Map<String, dynamic> updates) async {
    try {
      final updateData = {
        ...updates,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _firestore
          .collection(AppConstants.productsCollection)
          .doc(productId)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore
          .collection(AppConstants.productsCollection)
          .doc(productId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  Future<List<Product>> getAllProducts() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Product.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  // Category Management
  Future<String> addCategory(Map<String, dynamic> categoryData) async {
    try {
      final categoryId = _uuid.v4();
      final now = DateTime.now();

      final category = {
        ...categoryData,
        'id': categoryId,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'productCount': 0,
        'isActive': true,
      };

      await _firestore
          .collection(AppConstants.categoriesCollection)
          .doc(categoryId)
          .set(category);

      return categoryId;
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }

  Future<void> updateCategory(
      String categoryId, Map<String, dynamic> updates) async {
    try {
      final updateData = {
        ...updates,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _firestore
          .collection(AppConstants.categoriesCollection)
          .doc(categoryId)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore
          .collection(AppConstants.categoriesCollection)
          .doc(categoryId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  Future<List<Category>> getAllCategories() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.categoriesCollection)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => Category.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  // Offer Management
  Future<String> addOffer(Map<String, dynamic> offerData) async {
    try {
      final offerId = _uuid.v4();
      final now = DateTime.now();

      final offer = {
        ...offerData,
        'id': offerId,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'usedCount': 0,
        'isActive': true,
      };

      await _firestore
          .collection(AppConstants.offersCollection)
          .doc(offerId)
          .set(offer);

      return offerId;
    } catch (e) {
      throw Exception('Failed to add offer: $e');
    }
  }

  Future<void> updateOffer(String offerId, Map<String, dynamic> updates) async {
    try {
      final updateData = {
        ...updates,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _firestore
          .collection(AppConstants.offersCollection)
          .doc(offerId)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to update offer: $e');
    }
  }

  Future<void> deleteOffer(String offerId) async {
    try {
      await _firestore
          .collection(AppConstants.offersCollection)
          .doc(offerId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete offer: $e');
    }
  }

  Future<List<Offer>> getAllOffers() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.offersCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Offer.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch offers: $e');
    }
  }

  // Statistics
  Future<Map<String, int>> getStatistics() async {
    try {
      final productCount = await _firestore
          .collection(AppConstants.productsCollection)
          .count()
          .get();

      final categoryCount = await _firestore
          .collection(AppConstants.categoriesCollection)
          .count()
          .get();

      final offerCount = await _firestore
          .collection(AppConstants.offersCollection)
          .count()
          .get();

      final orderCount = await _firestore
          .collection(AppConstants.ordersCollection)
          .count()
          .get();

      final userCount = await _firestore
          .collection(AppConstants.usersCollection)
          .count()
          .get();

      return {
        'products': productCount.count ?? 0,
        'categories': categoryCount.count ?? 0,
        'offers': offerCount.count ?? 0,
        'orders': orderCount.count ?? 0,
        'users': userCount.count ?? 0,
      };
    } catch (e) {
      throw Exception('Failed to fetch statistics: $e');
    }
  }

  // Bulk operations
  Future<void> toggleProductFeatured(String productId, bool isFeatured) async {
    try {
      await _firestore
          .collection(AppConstants.productsCollection)
          .doc(productId)
          .update({
        'isFeatured': isFeatured,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to toggle product featured status: $e');
    }
  }

  Future<void> updateProductStock(String productId, int quantity) async {
    try {
      await _firestore
          .collection(AppConstants.productsCollection)
          .doc(productId)
          .update({
        'quantity': quantity,
        'inStock': quantity > 0,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update product stock: $e');
    }
  }

  Future<void> toggleCategoryStatus(String categoryId, bool isActive) async {
    try {
      await _firestore
          .collection(AppConstants.categoriesCollection)
          .doc(categoryId)
          .update({
        'isActive': isActive,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to toggle category status: $e');
    }
  }

  Future<void> toggleOfferStatus(String offerId, bool isActive) async {
    try {
      await _firestore
          .collection(AppConstants.offersCollection)
          .doc(offerId)
          .update({
        'isActive': isActive,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to toggle offer status: $e');
    }
  }
}
