import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:souq/constants/app_constants.dart';
import 'package:souq/models/product.dart';
import 'package:souq/models/category.dart';
import 'package:souq/models/user_order.dart';
import 'package:souq/models/user.dart' as user_model;

class AdminService {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final adminDoc = await _firestore
          .collection('admin_users')
          .doc(user.uid)
          .get();
      
      return adminDoc.exists;
    } catch (e) {
      return false;
    }
  }

  // Get admin user details
  Future<Map<String, dynamic>?> getAdminDetails(String userId) async {
    try {
      final adminDoc = await _firestore
          .collection('admin_users')
          .doc(userId)
          .get();
      
      if (adminDoc.exists) {
        return adminDoc.data();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get admin details: $e');
    }
  }

  // PRODUCT MANAGEMENT
  
  // Add new product
  Future<void> addProduct(Product product) async {
    try {
      await _firestore
          .collection(AppConstants.productsCollection)
          .doc(product.id)
          .set(product.toJson());
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  // Update product
  Future<void> updateProduct(Product product) async {
    try {
      await _firestore
          .collection(AppConstants.productsCollection)
          .doc(product.id)
          .update(product.toJson());
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  // Delete product
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

  // Get all products for admin
  Future<List<Product>> getAllProducts({
    int? limit,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConstants.productsCollection)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final querySnapshot = await query.get();
      
      return querySnapshot.docs
          .map((doc) => Product.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get products: $e');
    }
  }

  // CATEGORY MANAGEMENT

  // Add new category
  Future<void> addCategory(Category category) async {
    try {
      await _firestore
          .collection(AppConstants.categoriesCollection)
          .doc(category.id)
          .set(category.toJson());
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }

  // Update category
  Future<void> updateCategory(Category category) async {
    try {
      await _firestore
          .collection(AppConstants.categoriesCollection)
          .doc(category.id)
          .update(category.toJson());
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  // Delete category
  Future<void> deleteCategory(String categoryId) async {
    try {
      // Check if category has products
      final productsQuery = await _firestore
          .collection(AppConstants.productsCollection)
          .where('categoryId', isEqualTo: categoryId)
          .limit(1)
          .get();

      if (productsQuery.docs.isNotEmpty) {
        throw Exception('Cannot delete category with existing products');
      }      await _firestore
          .collection(AppConstants.categoriesCollection)
          .doc(categoryId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  // Get all categories
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
      throw Exception('Failed to get categories: $e');
    }
  }

  // ORDER MANAGEMENT
  // Get all orders
  Future<List<UserOrder>> getAllOrders({
    int? limit,
    DocumentSnapshot? lastDocument,
    OrderStatus? status,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConstants.ordersCollection)
          .orderBy('createdAt', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final querySnapshot = await query.get();
      
      return querySnapshot.docs
          .map((doc) => UserOrder.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get orders: $e');
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final updateData = <String, dynamic>{
        'status': status.name,
        'updatedAt': Timestamp.now(),
      };

      // Add timestamp for status changes
      switch (status) {
        case OrderStatus.confirmed:
          updateData['confirmedAt'] = Timestamp.now();
          break;
        case OrderStatus.processing:
          updateData['processedAt'] = Timestamp.now();
          break;
        case OrderStatus.shipped:
          updateData['shippedAt'] = Timestamp.now();
          break;
        case OrderStatus.delivered:
          updateData['deliveredAt'] = Timestamp.now();
          break;
        case OrderStatus.cancelled:
          updateData['cancelledAt'] = Timestamp.now();
          break;
        default:
          break;
      }

      await _firestore
          .collection(AppConstants.ordersCollection)
          .doc(orderId)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // USER MANAGEMENT

  // Get all users
  Future<List<user_model.User>> getAllUsers({
    int? limit,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConstants.usersCollection)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final querySnapshot = await query.get();
      
      return querySnapshot.docs
          .map((doc) => user_model.User.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  // ANALYTICS

  // Get dashboard analytics
  Future<Map<String, dynamic>> getDashboardAnalytics() async {
    try {
      // Get counts
      final [
        totalProducts,
        totalOrders,
        totalUsers,
        totalCategories
      ] = await Future.wait([
        _firestore.collection(AppConstants.productsCollection).count().get(),
        _firestore.collection(AppConstants.ordersCollection).count().get(),
        _firestore.collection(AppConstants.usersCollection).count().get(),
        _firestore.collection(AppConstants.categoriesCollection).count().get(),
      ]);

      // Get recent orders
      final recentOrdersQuery = await _firestore
          .collection(AppConstants.ordersCollection)
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();      final recentOrders = recentOrdersQuery.docs
          .map((doc) => UserOrder.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      // Calculate total revenue
      double totalRevenue = 0;
      for (final order in recentOrders) {
        totalRevenue += order.total;
      }

      // Get orders by status
      final orderStatusCounts = <String, int>{};
      for (final status in OrderStatus.values) {
        final count = await _firestore
            .collection(AppConstants.ordersCollection)
            .where('status', isEqualTo: status.name)
            .count()
            .get();
        orderStatusCounts[status.name] = count.count ?? 0;
      }

      return {
        'totalProducts': totalProducts.count ?? 0,
        'totalOrders': totalOrders.count ?? 0,
        'totalUsers': totalUsers.count ?? 0,
        'totalCategories': totalCategories.count ?? 0,
        'totalRevenue': totalRevenue,
        'recentOrders': recentOrders.map((o) => o.toJson()).toList(),
        'orderStatusCounts': orderStatusCounts,
      };
    } catch (e) {
      throw Exception('Failed to get analytics: $e');
    }
  }

  // Get monthly sales data
  Future<List<Map<String, dynamic>>> getMonthlySalesData() async {
    try {
      final now = DateTime.now();
      final startOfYear = DateTime(now.year, 1, 1);
      
      final ordersQuery = await _firestore
          .collection(AppConstants.ordersCollection)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfYear))
          .where('status', whereIn: ['delivered', 'shipped'])
          .get();

      final monthlyData = <int, double>{};
        for (final orderDoc in ordersQuery.docs) {
        final order = UserOrder.fromJson({...orderDoc.data(), 'id': orderDoc.id});
        final month = order.createdAt.month;
        monthlyData[month] = (monthlyData[month] ?? 0) + order.total;
      }

      final result = <Map<String, dynamic>>[];
      for (int month = 1; month <= 12; month++) {
        result.add({
          'month': month,
          'monthName': _getMonthName(month),
          'sales': monthlyData[month] ?? 0,
        });
      }

      return result;
    } catch (e) {
      throw Exception('Failed to get monthly sales data: $e');
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  // INVENTORY MANAGEMENT

  // Get low stock products
  Future<List<Product>> getLowStockProducts({int threshold = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where('quantity', isLessThanOrEqualTo: threshold)
          .where('inStock', isEqualTo: true)
          .orderBy('quantity')
          .get();

      return querySnapshot.docs
          .map((doc) => Product.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get low stock products: $e');
    }
  }

  // Update product stock
  Future<void> updateProductStock(String productId, int newQuantity) async {
    try {
      await _firestore
          .collection(AppConstants.productsCollection)
          .doc(productId)
          .update({
        'quantity': newQuantity,
        'inStock': newQuantity > 0,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update product stock: $e');
    }
  }
}
