import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:souq/constants/app_constants.dart';

import 'package:uuid/uuid.dart';

class DummyDataService {
  static final DummyDataService _instance = DummyDataService._internal();
  factory DummyDataService() => _instance;
  DummyDataService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Initialize dummy data
  Future<void> initializeDummyData() async {
    try {
      // Check if data already exists
      final productCount = await _firestore
          .collection(AppConstants.productsCollection)
          .limit(1)
          .get();

      if (productCount.docs.isNotEmpty) {
        print('Dummy data already exists');
        return;
      }

      print('Creating dummy data...');

      // Create categories first
      await _createDummyCategories();

      // Create products
      await _createDummyProducts();

      // Create offers
      await _createDummyOffers();

      print('Dummy data created successfully!');
    } catch (e) {
      print('Error creating dummy data: $e');
      throw Exception('Failed to create dummy data: $e');
    }
  }

  Future<void> _createDummyCategories() async {
    final categories = [
      {
        'id': 'electronics',
        'name': 'Electronics',
        'description': 'Latest electronic devices and gadgets',
        'imageUrl':
            'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=400',
        'parentId': null,
        'productCount': 0,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'fashion',
        'name': 'Fashion',
        'description': 'Trendy clothing and accessories',
        'imageUrl':
            'https://images.unsplash.com/photo-1445205170230-053b83016050?w=400',
        'parentId': null,
        'productCount': 0,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'home_garden',
        'name': 'Home & Garden',
        'description': 'Home improvement and garden supplies',
        'imageUrl':
            'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400',
        'parentId': null,
        'productCount': 0,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'sports',
        'name': 'Sports',
        'description': 'Sports equipment and fitness gear',
        'imageUrl':
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
        'parentId': null,
        'productCount': 0,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'beauty',
        'name': 'Beauty',
        'description': 'Cosmetics and personal care products',
        'imageUrl':
            'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=400',
        'parentId': null,
        'productCount': 0,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    ];

    final batch = _firestore.batch();
    for (final category in categories) {
      final docRef = _firestore
          .collection(AppConstants.categoriesCollection)
          .doc(category['id'] as String);
      batch.set(docRef, category);
    }
    await batch.commit();
  }

  Future<void> _createDummyProducts() async {
    final products = [
      // Electronics
      {
        'id': _uuid.v4(),
        'name': 'iPhone 15 Pro',
        'description':
            'Latest iPhone with advanced camera system and A17 Pro chip',
        'price': 999.99,
        'originalPrice': 1099.99,
        'categoryId': 'electronics',
        'category': 'Electronics',
        'images': [
          'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400',
          'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400',
        ],
        'inStock': true,
        'quantity': 50,
        'rating': 4.8,
        'reviewCount': 245,
        'specifications': {
          'Brand': 'Apple',
          'Color': 'Space Black',
          'Storage': '256GB',
          'Display': '6.1 inch Super Retina XDR',
        },
        'tags': ['smartphone', 'apple', 'premium', 'camera'],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'isFeatured': true,
        'discountPercentage': 9.1,
        'brand': 'Apple',
        'sku': 'IPH15-PRO-256-SB',
        'weight': 0.187,
        'dimensions': '146.6 x 70.6 x 7.8 mm',
      },
      {
        'id': _uuid.v4(),
        'name': 'MacBook Air M2',
        'description':
            'Ultra-thin laptop with M2 chip and all-day battery life',
        'price': 1199.99,
        'categoryId': 'electronics',
        'category': 'Electronics',
        'images': [
          'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400',
          'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=400',
        ],
        'inStock': true,
        'quantity': 25,
        'rating': 4.7,
        'reviewCount': 128,
        'specifications': {
          'Brand': 'Apple',
          'Processor': 'Apple M2',
          'RAM': '8GB',
          'Storage': '256GB SSD',
          'Display': '13.6-inch Liquid Retina',
        },
        'tags': ['laptop', 'apple', 'ultrabook', 'portable'],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'isFeatured': true,
        'brand': 'Apple',
        'sku': 'MBA-M2-256-SG',
        'weight': 1.24,
        'dimensions': '304 x 215 x 11.3 mm',
      },

      // Fashion
      {
        'id': _uuid.v4(),
        'name': 'Nike Air Force 1',
        'description':
            'Classic basketball-inspired sneakers with timeless style',
        'price': 89.99,
        'originalPrice': 110.0,
        'categoryId': 'fashion',
        'category': 'Fashion',
        'images': [
          'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400',
          'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?w=400',
        ],
        'inStock': true,
        'quantity': 100,
        'rating': 4.6,
        'reviewCount': 892,
        'specifications': {
          'Brand': 'Nike',
          'Material': 'Leather',
          'Sole': 'Rubber',
          'Type': 'Sneakers',
        },
        'tags': ['shoes', 'sneakers', 'nike', 'casual', 'white'],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'isFeatured': true,
        'discountPercentage': 18.2,
        'brand': 'Nike',
        'sku': 'NAF1-WHT-42',
        'weight': 0.8,
      },
      {
        'id': _uuid.v4(),
        'name': 'Levi\'s 501 Original Jeans',
        'description': 'Iconic straight-leg jeans with classic fit',
        'price': 59.99,
        'categoryId': 'fashion',
        'category': 'Fashion',
        'images': [
          'https://images.unsplash.com/photo-1542272604-787c3835535d?w=400',
          'https://images.unsplash.com/photo-1582418702059-97ebafb35d09?w=400',
        ],
        'inStock': true,
        'quantity': 75,
        'rating': 4.4,
        'reviewCount': 456,
        'specifications': {
          'Brand': 'Levi\'s',
          'Material': '100% Cotton',
          'Fit': 'Original',
          'Color': 'Blue',
        },
        'tags': ['jeans', 'levis', 'denim', 'classic', 'men'],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'isFeatured': false,
        'brand': 'Levi\'s',
        'sku': 'LEV-501-BLU-32',
        'weight': 0.6,
      },

      // Home & Garden
      {
        'id': _uuid.v4(),
        'name': 'KitchenAid Stand Mixer',
        'description':
            'Professional-grade stand mixer for all your baking needs',
        'price': 349.99,
        'originalPrice': 399.99,
        'categoryId': 'home_garden',
        'category': 'Home & Garden',
        'images': [
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
          'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400',
        ],
        'inStock': true,
        'quantity': 30,
        'rating': 4.9,
        'reviewCount': 234,
        'specifications': {
          'Brand': 'KitchenAid',
          'Capacity': '4.5 Quart',
          'Power': '275 Watts',
          'Material': 'Metal',
        },
        'tags': ['kitchen', 'mixer', 'baking', 'appliance'],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'isFeatured': true,
        'discountPercentage': 12.5,
        'brand': 'KitchenAid',
        'sku': 'KA-SM-45-RED',
        'weight': 10.9,
        'dimensions': '35.3 x 22.1 x 35.3 cm',
      },

      // Sports
      {
        'id': _uuid.v4(),
        'name': 'Yoga Mat Premium',
        'description': 'Non-slip yoga mat with extra cushioning for comfort',
        'price': 29.99,
        'categoryId': 'sports',
        'category': 'Sports',
        'images': [
          'https://images.unsplash.com/photo-1506629905238-02133d088e50?w=400',
          'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=400',
        ],
        'inStock': true,
        'quantity': 200,
        'rating': 4.3,
        'reviewCount': 156,
        'specifications': {
          'Material': 'TPE',
          'Thickness': '6mm',
          'Size': '183 x 61 cm',
          'Weight': '1.2kg',
        },
        'tags': ['yoga', 'fitness', 'mat', 'exercise', 'meditation'],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'isFeatured': false,
        'brand': 'YogaPro',
        'sku': 'YP-MAT-PUR-6MM',
        'weight': 1.2,
        'dimensions': '183 x 61 x 0.6 cm',
      },

      // Beauty
      {
        'id': _uuid.v4(),
        'name': 'Skincare Gift Set',
        'description':
            'Complete skincare routine with cleanser, toner, and moisturizer',
        'price': 79.99,
        'originalPrice': 120.0,
        'categoryId': 'beauty',
        'category': 'Beauty',
        'images': [
          'https://images.unsplash.com/photo-1556228453-efd6c1ff04f6?w=400',
          'https://images.unsplash.com/photo-1570194065650-d99fb4bedf0a?w=400',
        ],
        'inStock': true,
        'quantity': 60,
        'rating': 4.5,
        'reviewCount': 89,
        'specifications': {
          'Brand': 'GlowSkin',
          'Type': 'Gift Set',
          'Skin Type': 'All',
          'Items': '3 pieces',
        },
        'tags': ['skincare', 'beauty', 'gift', 'moisturizer', 'routine'],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'isFeatured': true,
        'discountPercentage': 33.3,
        'brand': 'GlowSkin',
        'sku': 'GS-SET-001',
        'weight': 0.5,
      },
    ];

    final batch = _firestore.batch();
    for (final product in products) {
      final docRef = _firestore
          .collection(AppConstants.productsCollection)
          .doc(product['id'] as String);
      batch.set(docRef, product);
    }
    await batch.commit();
  }

  Future<void> _createDummyOffers() async {
    final offers = [
      {
        'id': _uuid.v4(),
        'title': 'Summer Sale',
        'description': 'Get up to 50% off on all fashion items',
        'imageUrl':
            'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=400',
        'type': 'percentage',
        'discountPercentage': 50.0,
        'minimumPurchase': 100.0,
        'applicableProducts': [],
        'applicableCategories': ['fashion'],
        'startDate':
            DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
        'endDate':
            DateTime.now().add(const Duration(days: 23)).toIso8601String(),
        'isActive': true,
        'usageLimit': 1000,
        'usedCount': 45,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': _uuid.v4(),
        'title': 'Tech Week',
        'description': 'Special discounts on electronics and gadgets',
        'imageUrl':
            'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400',
        'type': 'fixed',
        'discountAmount': 100.0,
        'minimumPurchase': 500.0,
        'applicableProducts': [],
        'applicableCategories': ['electronics'],
        'startDate': DateTime.now().toIso8601String(),
        'endDate':
            DateTime.now().add(const Duration(days: 14)).toIso8601String(),
        'isActive': true,
        'usageLimit': 500,
        'usedCount': 12,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': _uuid.v4(),
        'title': 'Free Shipping Weekend',
        'description': 'Free shipping on all orders this weekend',
        'imageUrl':
            'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
        'type': 'freeShipping',
        'discountAmount': 0.0,
        'minimumPurchase': 50.0,
        'applicableProducts': [],
        'applicableCategories': [],
        'startDate': DateTime.now().toIso8601String(),
        'endDate':
            DateTime.now().add(const Duration(days: 3)).toIso8601String(),
        'isActive': true,
        'usageLimit': 0,
        'usedCount': 78,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    ];

    final batch = _firestore.batch();
    for (final offer in offers) {
      final docRef = _firestore
          .collection(AppConstants.offersCollection)
          .doc(offer['id'] as String);
      batch.set(docRef, offer);
    }
    await batch.commit();
  }

  // Clear all dummy data
  Future<void> clearDummyData() async {
    try {
      print('Clearing dummy data...');

      // Clear products
      final productSnapshot =
          await _firestore.collection(AppConstants.productsCollection).get();

      final productBatch = _firestore.batch();
      for (final doc in productSnapshot.docs) {
        productBatch.delete(doc.reference);
      }
      await productBatch.commit();

      // Clear categories
      final categorySnapshot =
          await _firestore.collection(AppConstants.categoriesCollection).get();

      final categoryBatch = _firestore.batch();
      for (final doc in categorySnapshot.docs) {
        categoryBatch.delete(doc.reference);
      }
      await categoryBatch.commit();

      // Clear offers
      final offerSnapshot =
          await _firestore.collection(AppConstants.offersCollection).get();

      final offerBatch = _firestore.batch();
      for (final doc in offerSnapshot.docs) {
        offerBatch.delete(doc.reference);
      }
      await offerBatch.commit();

      print('Dummy data cleared successfully!');
    } catch (e) {
      print('Error clearing dummy data: $e');
      throw Exception('Failed to clear dummy data: $e');
    }
  }
}
