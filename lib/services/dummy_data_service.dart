import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:souq/constants/app_constants.dart';
import 'package:souq/models/category.dart';
import 'package:souq/models/offer.dart';
import 'package:souq/models/product.dart';
import 'package:souq/models/user.dart' as user_model;
import 'package:uuid/uuid.dart';

class DummyDataService {
  static final DummyDataService _instance = DummyDataService._internal();
  factory DummyDataService() => _instance;
  DummyDataService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  // Initialize all dummy data
  Future<void> initializeDummyData() async {
    try {
      await Future.wait([
        _createDummyCategories(),
        _createDummyProducts(),
        _createDummyOffers(),
        _createAdminUser(),
      ]);
      print('✅ Dummy data initialization completed successfully!');
    } catch (e) {
      print('❌ Error initializing dummy data: $e');
      throw Exception('Failed to initialize dummy data: $e');
    }
  }

  // Check if data already exists
  Future<bool> isDummyDataInitialized() async {
    try {
      final categoriesCount = await _firestore.collection(AppConstants.categoriesCollection).count().get();
      final productsCount = await _firestore.collection(AppConstants.productsCollection).count().get();
      
      return categoriesCount.count! > 0 && productsCount.count! > 0;
    } catch (e) {
      return false;
    }
  }

  // Create dummy categories
  Future<void> _createDummyCategories() async {
    print('📂 Creating dummy categories...');
    
    final categoriesData = [
      {
        'id': 'electronics',
        'name': 'Electronics',
        'description': 'Latest electronics and gadgets',
        'imageUrl': 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=400',
        'parentId': null,
        'subcategories': [
          {
            'id': 'smartphones',
            'name': 'Smartphones',
            'description': 'Latest smartphones and accessories',
            'imageUrl': 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400',
            'parentId': 'electronics',
          },
          {
            'id': 'laptops',
            'name': 'Laptops',
            'description': 'Laptops and computers',
            'imageUrl': 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=400',
            'parentId': 'electronics',
          },
          {
            'id': 'headphones',
            'name': 'Headphones',
            'description': 'Audio devices and headphones',
            'imageUrl': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
            'parentId': 'electronics',
          }
        ]
      },
      {
        'id': 'fashion',
        'name': 'Fashion',
        'description': 'Trendy clothing and accessories',
        'imageUrl': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400',
        'parentId': null,
        'subcategories': [
          {
            'id': 'mens-clothing',
            'name': "Men's Clothing",
            'description': 'Fashion for men',
            'imageUrl': 'https://images.unsplash.com/photo-1516826957135-700dedea698c?w=400',
            'parentId': 'fashion',
          },
          {
            'id': 'womens-clothing',
            'name': "Women's Clothing",
            'description': 'Fashion for women',
            'imageUrl': 'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=400',
            'parentId': 'fashion',
          }
        ]
      },
      {
        'id': 'home-garden',
        'name': 'Home & Garden',
        'description': 'Home improvement and garden supplies',
        'imageUrl': 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400',
        'parentId': null,
        'subcategories': [
          {
            'id': 'furniture',
            'name': 'Furniture',
            'description': 'Home furniture and decor',
            'imageUrl': 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400',
            'parentId': 'home-garden',
          }
        ]
      },
      {
        'id': 'sports',
        'name': 'Sports & Outdoors',
        'description': 'Sports equipment and outdoor gear',
        'imageUrl': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
        'parentId': null,
        'subcategories': []
      }
    ];

    final batch = _firestore.batch();

    for (final categoryData in categoriesData) {
      // Create parent category
      final parentCategory = Category(
        id: categoryData['id'] as String,
        name: categoryData['name'] as String,
        description: categoryData['description'] as String,
        imageUrl: categoryData['imageUrl'] as String?,
        parentId: categoryData['parentId'] as String?,
        productCount: 0,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      batch.set(
        _firestore.collection(AppConstants.categoriesCollection).doc(parentCategory.id),
        parentCategory.toJson(),
      );

      // Create subcategories
      final subcategories = categoryData['subcategories'] as List<dynamic>;
      for (final subData in subcategories) {
        final subcategory = Category(
          id: subData['id'] as String,
          name: subData['name'] as String,
          description: subData['description'] as String,
          imageUrl: subData['imageUrl'] as String?,
          parentId: subData['parentId'] as String,
          productCount: 0,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        batch.set(
          _firestore.collection(AppConstants.categoriesCollection).doc(subcategory.id),
          subcategory.toJson(),
        );
      }
    }

    await batch.commit();
    print('✅ Categories created successfully');
  }

  // Create dummy products
  Future<void> _createDummyProducts() async {
    print('📱 Creating dummy products...');
    
    final productsData = [
      // Electronics - Smartphones
      {
        'name': 'iPhone 15 Pro',
        'description': 'Latest iPhone with A17 Pro chip, titanium design, and advanced camera system.',
        'price': 999.99,
        'originalPrice': 1099.99,
        'categoryId': 'smartphones',
        'category': 'Smartphones',
        'images': [
          'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400',
          'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400'
        ],
        'inStock': true,
        'quantity': 50,
        'rating': 4.8,
        'reviewCount': 156,
        'isFeatured': true,
        'brand': 'Apple',
        'sku': 'IPH15PRO-128',
        'specifications': {
          'Screen Size': '6.1 inches',
          'Storage': '128GB',
          'RAM': '8GB',
          'Camera': '48MP + 12MP + 12MP',
          'Battery': '3274mAh',
        },
        'tags': ['smartphone', 'apple', 'premium', 'featured']
      },
      {
        'name': 'Samsung Galaxy S24',
        'description': 'Flagship Android phone with AI features and excellent camera.',
        'price': 799.99,
        'originalPrice': 899.99,
        'categoryId': 'smartphones',
        'category': 'Smartphones',
        'images': [
          'https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?w=400'
        ],
        'inStock': true,
        'quantity': 35,
        'rating': 4.6,
        'reviewCount': 89,
        'isFeatured': true,
        'brand': 'Samsung',
        'sku': 'GAL-S24-256',
        'specifications': {
          'Screen Size': '6.2 inches',
          'Storage': '256GB',
          'RAM': '8GB',
          'Camera': '50MP + 12MP + 10MP',
          'Battery': '4000mAh',
        },
        'tags': ['smartphone', 'samsung', 'android', 'ai']
      },
      // Electronics - Laptops
      {
        'name': 'MacBook Air M3',
        'description': 'Ultra-thin laptop with M3 chip, perfect for productivity and creativity.',
        'price': 1199.99,
        'originalPrice': null,
        'categoryId': 'laptops',
        'category': 'Laptops',
        'images': [
          'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=400',
          'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400'
        ],
        'inStock': true,
        'quantity': 25,
        'rating': 4.9,
        'reviewCount': 203,
        'isFeatured': true,
        'brand': 'Apple',
        'sku': 'MBA-M3-13',
        'specifications': {
          'Processor': 'Apple M3',
          'RAM': '8GB',
          'Storage': '256GB SSD',
          'Screen': '13.6-inch Liquid Retina',
          'Weight': '1.24kg',
        },
        'tags': ['laptop', 'apple', 'ultrabook', 'productivity']
      },
      {
        'name': 'Dell XPS 13',
        'description': 'Premium Windows laptop with Intel processors and stunning display.',
        'price': 999.99,
        'originalPrice': 1199.99,
        'categoryId': 'laptops',
        'category': 'Laptops',
        'images': [
          'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=400'
        ],
        'inStock': true,
        'quantity': 20,
        'rating': 4.5,
        'reviewCount': 67,
        'isFeatured': false,
        'brand': 'Dell',
        'sku': 'XPS13-I7-512',
        'specifications': {
          'Processor': 'Intel Core i7',
          'RAM': '16GB',
          'Storage': '512GB SSD',
          'Screen': '13.4-inch FHD+',
          'Weight': '1.23kg',
        },
        'tags': ['laptop', 'dell', 'windows', 'business']
      },
      // Electronics - Headphones
      {
        'name': 'Sony WH-1000XM5',
        'description': 'Industry-leading noise canceling wireless headphones.',
        'price': 349.99,
        'originalPrice': 399.99,
        'categoryId': 'headphones',
        'category': 'Headphones',
        'images': [
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
          'https://images.unsplash.com/photo-1484704849700-f032a568e944?w=400'
        ],
        'inStock': true,
        'quantity': 45,
        'rating': 4.7,
        'reviewCount': 312,
        'isFeatured': true,
        'brand': 'Sony',
        'sku': 'WH1000XM5-BLK',
        'specifications': {
          'Type': 'Over-ear',
          'Connectivity': 'Bluetooth 5.2',
          'Battery Life': '30 hours',
          'Noise Canceling': 'Yes',
          'Weight': '250g',
        },
        'tags': ['headphones', 'sony', 'wireless', 'noise-canceling']
      },
      // Fashion - Men's Clothing
      {
        'name': 'Classic White T-Shirt',
        'description': 'Premium cotton t-shirt, perfect for everyday wear.',
        'price': 29.99,
        'originalPrice': null,
        'categoryId': 'mens-clothing',
        'category': "Men's Clothing",
        'images': [
          'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400'
        ],
        'inStock': true,
        'quantity': 100,
        'rating': 4.3,
        'reviewCount': 45,
        'isFeatured': false,
        'brand': 'StyleCo',
        'sku': 'TSH-WHT-M',
        'specifications': {
          'Material': '100% Cotton',
          'Fit': 'Regular',
          'Care': 'Machine washable',
          'Origin': 'Made in USA',
        },
        'tags': ['t-shirt', 'men', 'cotton', 'casual']
      },
      {
        'name': 'Denim Jacket',
        'description': 'Classic blue denim jacket, timeless style.',
        'price': 89.99,
        'originalPrice': 109.99,
        'categoryId': 'mens-clothing',
        'category': "Men's Clothing",
        'images': [
          'https://images.unsplash.com/photo-1516826957135-700dedea698c?w=400'
        ],
        'inStock': true,
        'quantity': 30,
        'rating': 4.5,
        'reviewCount': 28,
        'isFeatured': false,
        'brand': 'DenimCo',
        'sku': 'JKT-DEN-L',
        'specifications': {
          'Material': '98% Cotton, 2% Elastane',
          'Fit': 'Regular',
          'Style': 'Classic',
          'Pockets': '4',
        },
        'tags': ['jacket', 'men', 'denim', 'casual']
      },
      // Fashion - Women's Clothing
      {
        'name': 'Floral Summer Dress',
        'description': 'Beautiful floral dress perfect for summer occasions.',
        'price': 79.99,
        'originalPrice': 99.99,
        'categoryId': 'womens-clothing',
        'category': "Women's Clothing",
        'images': [
          'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=400'
        ],
        'inStock': true,
        'quantity': 25,
        'rating': 4.6,
        'reviewCount': 52,
        'isFeatured': true,
        'brand': 'FloralFashion',
        'sku': 'DRS-FLR-M',
        'specifications': {
          'Material': 'Polyester blend',
          'Length': 'Midi',
          'Sleeves': 'Short',
          'Pattern': 'Floral',
        },
        'tags': ['dress', 'women', 'floral', 'summer']
      },
      // Home & Garden - Furniture
      {
        'name': 'Modern Coffee Table',
        'description': 'Sleek modern coffee table with storage space.',
        'price': 299.99,
        'originalPrice': 349.99,
        'categoryId': 'furniture',
        'category': 'Furniture',
        'images': [
          'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400'
        ],
        'inStock': true,
        'quantity': 15,
        'rating': 4.4,
        'reviewCount': 23,
        'isFeatured': false,
        'brand': 'ModernHome',
        'sku': 'CFT-MOD-OAK',
        'specifications': {
          'Material': 'Oak wood',
          'Dimensions': '120x60x45 cm',
          'Style': 'Modern',
          'Assembly': 'Required',
        },
        'tags': ['furniture', 'table', 'modern', 'home']
      },
      // Sports
      {
        'name': 'Yoga Mat Premium',
        'description': 'High-quality yoga mat with excellent grip and cushioning.',
        'price': 49.99,
        'originalPrice': null,
        'categoryId': 'sports',
        'category': 'Sports & Outdoors',
        'images': [
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400'
        ],
        'inStock': true,
        'quantity': 80,
        'rating': 4.7,
        'reviewCount': 95,
        'isFeatured': true,
        'brand': 'YogaPro',
        'sku': 'YOG-MAT-PRM',
        'specifications': {
          'Material': 'Natural rubber',
          'Thickness': '6mm',
          'Size': '183x61 cm',
          'Weight': '2kg',
        },
        'tags': ['yoga', 'fitness', 'sports', 'exercise']
      }
    ];

    final batch = _firestore.batch();

    for (final productData in productsData) {
      final productId = _uuid.v4();
      final product = Product(
        id: productId,
        name: productData['name'] as String,
        description: productData['description'] as String,
        price: (productData['price'] as num).toDouble(),
        originalPrice: productData['originalPrice'] != null 
          ? (productData['originalPrice'] as num).toDouble() 
          : null,
        categoryId: productData['categoryId'] as String,
        category: productData['category'] as String,
        images: List<String>.from(productData['images'] as List),
        inStock: productData['inStock'] as bool,
        quantity: productData['quantity'] as int,
        rating: (productData['rating'] as num).toDouble(),
        reviewCount: productData['reviewCount'] as int,
        specifications: Map<String, dynamic>.from(productData['specifications'] as Map),
        tags: List<String>.from(productData['tags'] as List),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFeatured: productData['isFeatured'] as bool,
        brand: productData['brand'] as String?,
        sku: productData['sku'] as String?,
      );

      batch.set(
        _firestore.collection(AppConstants.productsCollection).doc(productId),
        product.toJson(),
      );
    }

    await batch.commit();
    print('✅ Products created successfully');
  }

  // Create dummy offers
  Future<void> _createDummyOffers() async {
    print('🎁 Creating dummy offers...');
    
    final offersData = [
      {
        'title': 'Summer Sale',
        'description': 'Up to 30% off on selected fashion items',
        'imageUrl': 'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?w=400',
        'type': 'percentage',
        'discountPercentage': 30.0,
        'minimumPurchase': 50.0,
        'applicableCategories': ['fashion'],
        'startDate': DateTime.now().subtract(const Duration(days: 5)),
        'endDate': DateTime.now().add(const Duration(days: 25)),
        'isActive': true,
        'usageLimit': 1000,
        'usedCount': 45,
      },
      {
        'title': 'Tech Week',
        'description': 'Special discounts on electronics',
        'imageUrl': 'https://images.unsplash.com/photo-1526738549149-8e07eca6c147?w=400',
        'type': 'amount',
        'discountAmount': 100.0,
        'minimumPurchase': 500.0,
        'applicableCategories': ['electronics'],
        'startDate': DateTime.now(),
        'endDate': DateTime.now().add(const Duration(days: 14)),
        'isActive': true,
        'usageLimit': 500,
        'usedCount': 12,
      },
      {
        'title': 'New Customer Offer',
        'description': '15% off on your first purchase',
        'imageUrl': 'https://images.unsplash.com/photo-1607083206869-4c7672e72a8a?w=400',
        'type': 'percentage',
        'discountPercentage': 15.0,
        'minimumPurchase': 0.0,
        'applicableCategories': [],
        'startDate': DateTime.now().subtract(const Duration(days: 30)),
        'endDate': DateTime.now().add(const Duration(days: 335)),
        'isActive': true,
        'usageLimit': 0,
        'usedCount': 234,
      }
    ];

    final batch = _firestore.batch();

    for (final offerData in offersData) {
      final offerId = _uuid.v4();
      final offer = Offer(
        id: offerId,
        title: offerData['title'] as String,
        description: offerData['description'] as String,
        imageUrl: offerData['imageUrl'] as String,
        type: offerData['type'] == 'percentage' ? OfferType.percentage : OfferType.fixed,
        discountPercentage: offerData['discountPercentage'] as double?,
        discountAmount: offerData['discountAmount'] as double?,
        minimumPurchase: offerData['minimumPurchase'] as double?,
        applicableProducts: const [],
        applicableCategories: List<String>.from(offerData['applicableCategories'] as List),
        startDate: offerData['startDate'] as DateTime,
        endDate: offerData['endDate'] as DateTime,
        isActive: offerData['isActive'] as bool,
        usageLimit: offerData['usageLimit'] as int,
        usedCount: offerData['usedCount'] as int,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      batch.set(
        _firestore.collection(AppConstants.offersCollection).doc(offerId),
        offer.toJson(),
      );
    }

    await batch.commit();
    print('✅ Offers created successfully');
  }

  // Create admin user
  Future<void> _createAdminUser() async {
    print('👤 Creating admin user...');
    
    try {
      // Create admin user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: 'admin@souq.com',
        password: 'admin123456',
      );

      if (userCredential.user != null) {        final adminUser = user_model.User(
          id: userCredential.user!.uid,
          email: 'admin@souq.com',
          firstName: 'Admin',
          lastName: 'User',
          phoneNumber: '+1234567890',
          role: 'admin', // Set admin role
          addresses: [
            user_model.Address(
              id: _uuid.v4(),
              firstName: 'Admin',
              lastName: 'User',
              title: 'Office',
              street: '123 Business St',
              addressLine1: '123 Business St',
              city: 'New York',
              state: 'NY',
              postalCode: '10001',
              country: 'USA',
              isDefault: true,
            )
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isEmailVerified: true,
          isPhoneVerified: true,
        );

        // Save admin user to Firestore
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(adminUser.id)
            .set(adminUser.toJson());

        // Create admin role document
        await _firestore
            .collection('admin_users')
            .doc(adminUser.id)
            .set({
          'userId': adminUser.id,
          'role': 'super_admin',
          'permissions': [
            'manage_products',
            'manage_categories',
            'manage_orders',
            'manage_users',
            'view_analytics',
            'manage_offers'
          ],
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });

        print('✅ Admin user created successfully');
        print('📧 Email: admin@souq.com');
        print('🔑 Password: admin123456');
      }
    } catch (e) {
      if (e.toString().contains('email-already-in-use')) {
        print('⚠️  Admin user already exists');
      } else {
        print('❌ Error creating admin user: $e');
        rethrow;
      }
    }
  }

  // Update product counts for categories
  Future<void> updateCategoryProductCounts() async {
    print('🔄 Updating category product counts...');
    
    try {
      final categories = await _firestore.collection(AppConstants.categoriesCollection).get();
      
      for (final categoryDoc in categories.docs) {
        final categoryId = categoryDoc.id;
        final productsCount = await _firestore
            .collection(AppConstants.productsCollection)
            .where('categoryId', isEqualTo: categoryId)
            .count()
            .get();
        
        await _firestore
            .collection(AppConstants.categoriesCollection)
            .doc(categoryId)
            .update({
          'productCount': productsCount.count,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
      
      print('✅ Category product counts updated');
    } catch (e) {
      print('❌ Error updating category counts: $e');
    }
  }

  // Clear all dummy data
  Future<void> clearAllData() async {
    print('🗑️  Clearing all dummy data...');
    
    try {
      final batch = _firestore.batch();
      
      // Get all collections to clear
      final collections = [
        AppConstants.productsCollection,
        AppConstants.categoriesCollection,
        AppConstants.offersCollection,
      ];
      
      for (final collection in collections) {
        final docs = await _firestore.collection(collection).get();
        for (final doc in docs.docs) {
          batch.delete(doc.reference);
        }
      }
      
      await batch.commit();
      print('✅ All dummy data cleared successfully');
    } catch (e) {
      print('❌ Error clearing data: $e');
      throw Exception('Failed to clear data: $e');
    }
  }
}
