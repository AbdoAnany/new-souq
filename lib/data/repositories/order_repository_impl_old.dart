import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/result.dart';
import '../../core/error/app_error.dart';
import '../../domain/repositories/repositories.dart';
import '../../models/user_order.dart';
import '../../constants/app_constants.dart';

class OrderRepositoryImpl implements OrderRepository {
  final FirebaseFirestore _firestore;

  OrderRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Result<UserOrder>> getOrderById(String orderId) async {
    try {
      final orderDoc = await _firestore
          .collection(AppConstants.ordersCollection)
          .doc(orderId)
          .get();

      if (!orderDoc.exists) {
        return Result.failure(
          ValidationError('Order not found'),
        );
      }

      final order = UserOrder.fromJson({
        ...orderDoc.data()!,
        'id': orderDoc.id,
      });

      return Result.success(order);
    } catch (e) {
      return Result.failure(
        NetworkError('Failed to fetch order: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<UserOrder>>> getUserOrders(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.ordersCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final orders = querySnapshot.docs
          .map((doc) => UserOrder.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();

      return Result.success(orders);
    } catch (e) {
      return Result.failure(
        NetworkError('Failed to fetch user orders: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<UserOrder>>> getAllOrders({
    int? page,
    int? limit,
    OrderStatus? status,
    String? search,
  }) async {
    try {
      Query query = _firestore.collection(AppConstants.ordersCollection);

      // Apply status filter if provided
      if (status != null) {
        query = query.where('status', isEqualTo: status.toString().split('.').last);
      }

      // Apply search filter if provided (search by order number)
      if (search != null && search.isNotEmpty) {
        query = query
            .where('orderNumber', isGreaterThanOrEqualTo: search)
            .where('orderNumber', isLessThan: search + 'z');
      }

      // Apply ordering
      query = query.orderBy('createdAt', descending: true);

      // Apply pagination
      if (limit != null) {
        query = query.limit(limit);
      }

      if (page != null && limit != null && page > 1) {
        final offset = (page - 1) * limit;
        // Note: This is a simplified pagination implementation
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      
      final orders = querySnapshot.docs
          .map((doc) => UserOrder.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();

      return Result.success(orders);
    } catch (e) {
      return Result.failure(
        NetworkError('Failed to fetch orders: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<UserOrder>> createOrder(UserOrder order) async {
    try {
      final orderRef = _firestore
          .collection(AppConstants.ordersCollection)
          .doc();

      final orderWithId = order.copyWith(id: orderRef.id);
      
      await orderRef.set({
        ...orderWithId.toJson(),
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return Result.success(orderWithId);
    } catch (e) {
      return Result.failure(
        NetworkError('Failed to create order: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<UserOrder>> updateOrder(UserOrder order) async {
    try {
      await _firestore
          .collection(AppConstants.ordersCollection)
          .doc(order.id)
          .update({
        ...order.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return Result.success(order);
    } catch (e) {
      return Result.failure(
        NetworkError('Failed to update order: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<UserOrder>> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _firestore
          .collection(AppConstants.ordersCollection)
          .doc(orderId)
          .update({
        'status': status.toString().split('.').last,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Fetch the updated order
      final orderResult = await getOrderById(orderId);
      return orderResult;
    } catch (e) {
      return Result.failure(
        NetworkError('Failed to update order status: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void>> cancelOrder(String orderId) async {
    try {
      await _firestore
          .collection(AppConstants.ordersCollection)
          .doc(orderId)
          .update({
        'status': OrderStatus.cancelled.toString().split('.').last,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return Result.success(null);
    } catch (e) {
      return Result.failure(
        NetworkError('Failed to cancel order: ${e.toString()}'),
      );
    }
  }

  @override
  Stream<UserOrder> watchOrder(String orderId) {
    return _firestore
        .collection(AppConstants.ordersCollection)
        .doc(orderId)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return UserOrder.fromJson({
              ...doc.data()!,
              'id': doc.id,
            });
          } else {
            throw Exception('Order not found');
          }
        });
  }
}
