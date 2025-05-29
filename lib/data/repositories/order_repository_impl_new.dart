import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/result.dart';
import '../../core/failure.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/entities/order.dart';
import '../../constants/app_constants.dart';

class OrderRepositoryImpl implements OrderRepository {
  final FirebaseFirestore _firestore;

  OrderRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Result<UserOrder, Failure>> getOrderById(String orderId) async {
    try {
      final orderDoc = await _firestore
          .collection(AppConstants.ordersCollection)
          .doc(orderId)
          .get();

      if (orderDoc.exists) {
        final orderData = orderDoc.data()!;
        final order = _mapDocumentToOrder(orderData, orderDoc.id);
        return Result.success(order);
      } else {
        return Result.failure(const NotFoundFailure('Order not found'));
      }
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to get order: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<UserOrder>, Failure>> getUserOrders(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.ordersCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final orders = querySnapshot.docs
          .map((doc) => _mapDocumentToOrder(doc.data(), doc.id))
          .toList();

      return Result.success(orders);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to get user orders: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<UserOrder>, Failure>> getAllOrders({
    int? page,
    int? limit,
    OrderStatus? status,
    String? search,
  }) async {
    try {
      Query query = _firestore.collection(AppConstants.ordersCollection);

      // Apply status filter if provided
      if (status != null) {
        query = query.where('status', isEqualTo: status.toString());
      }

      // Apply search filter if provided
      if (search != null && search.isNotEmpty) {
        query = query
            .where('orderNumber', isGreaterThanOrEqualTo: search)
            .where('orderNumber', isLessThanOrEqualTo: search + '\uf8ff');
      }

      // Apply ordering
      query = query.orderBy('createdAt', descending: true);

      // Apply pagination
      if (limit != null) {
        query = query.limit(limit);
      }

      if (page != null && page > 1 && limit != null) {
        final offset = (page - 1) * limit;
        query = query.offset(offset);
      }

      final querySnapshot = await query.get();

      final orders = querySnapshot.docs
          .map((doc) => _mapDocumentToOrder(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      return Result.success(orders);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to get all orders: ${e.toString()}'));
    }
  }

  @override
  Future<Result<UserOrder, Failure>> createOrder(UserOrder order) async {
    try {
      final orderRef = _firestore
          .collection(AppConstants.ordersCollection)
          .doc();

      final orderWithId = order.copyWith(
        id: orderRef.id,
        orderNumber: _generateOrderNumber(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await orderRef.set(_mapOrderToDocument(orderWithId));

      return Result.success(orderWithId);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to create order: ${e.toString()}'));
    }
  }

  @override
  Future<Result<UserOrder, Failure>> updateOrder(UserOrder order) async {
    try {
      final orderRef = _firestore
          .collection(AppConstants.ordersCollection)
          .doc(order.id);

      final updatedOrder = order.copyWith(updatedAt: DateTime.now());

      await orderRef.update(_mapOrderToDocument(updatedOrder));

      return Result.success(updatedOrder);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to update order: ${e.toString()}'));
    }
  }

  @override
  Future<Result<UserOrder, Failure>> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final orderRef = _firestore
          .collection(AppConstants.ordersCollection)
          .doc(orderId);

      await orderRef.update({
        'status': status.toString(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Get updated order
      final orderDoc = await orderRef.get();
      if (orderDoc.exists) {
        final orderData = orderDoc.data()!;
        final order = _mapDocumentToOrder(orderData, orderDoc.id);
        return Result.success(order);
      } else {
        return Result.failure(const NotFoundFailure('Order not found'));
      }
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to update order status: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void, Failure>> cancelOrder(String orderId) async {
    try {
      final orderRef = _firestore
          .collection(AppConstants.ordersCollection)
          .doc(orderId);

      await orderRef.update({
        'status': OrderStatus.cancelled.toString(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return Result.success(null);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to cancel order: ${e.toString()}'));
    }
  }

  @override
  Stream<Result<List<UserOrder>, Failure>> watchUserOrders(String userId) {
    return _firestore
        .collection(AppConstants.ordersCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      try {
        final orders = snapshot.docs
            .map((doc) => _mapDocumentToOrder(doc.data(), doc.id))
            .toList();

        return Result.success(orders);
      } catch (e) {
        return Result.failure(NetworkFailure('Failed to watch user orders: ${e.toString()}'));
      }
    });
  }

  @override
  Stream<UserOrder> watchOrder(String orderId) {
    return _firestore
        .collection(AppConstants.ordersCollection)
        .doc(orderId)
        .snapshots()
        .map((snapshot) {
      final orderData = snapshot.data()!;
      return _mapDocumentToOrder(orderData, snapshot.id);
    });
  }

  // Helper methods
  UserOrder _mapDocumentToOrder(Map<String, dynamic> data, String id) {
    final itemsData = data['items'] as List<dynamic>? ?? [];
    final items = itemsData.map((itemData) => _mapDocumentToOrderItem(itemData)).toList();

    return UserOrder(
      id: id,
      orderNumber: data['orderNumber'] as String,
      userId: data['userId'] as String,
      items: items,
      status: OrderStatus.values.firstWhere(
        (status) => status.toString() == data['status'],
        orElse: () => OrderStatus.pending,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (method) => method.toString() == data['paymentMethod'],
        orElse: () => PaymentMethod.card,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (status) => status.toString() == data['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      shippingAddress: Address.fromMap(Map<String, dynamic>.from(data['shippingAddress'])),
      billingAddress: data['billingAddress'] != null
          ? Address.fromMap(Map<String, dynamic>.from(data['billingAddress']))
          : null,
      subtotal: (data['subtotal'] as num).toDouble(),
      shippingCost: (data['shippingCost'] as num).toDouble(),
      tax: (data['tax'] as num).toDouble(),
      total: (data['total'] as num).toDouble(),
      currency: data['currency'] as String? ?? 'USD',
      notes: data['notes'] as String?,
      trackingNumber: data['trackingNumber'] as String?,
      estimatedDeliveryDate: data['estimatedDeliveryDate'] != null
          ? (data['estimatedDeliveryDate'] as Timestamp).toDate()
          : null,
      deliveredAt: data['deliveredAt'] != null
          ? (data['deliveredAt'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  OrderItem _mapDocumentToOrderItem(Map<String, dynamic> data) {
    return OrderItem(
      id: data['id'] as String,
      productId: data['productId'] as String,
      productName: data['productName'] as String,
      productImage: data['productImage'] as String?,
      quantity: data['quantity'] as int,
      unitPrice: (data['unitPrice'] as num).toDouble(),
      totalPrice: (data['totalPrice'] as num).toDouble(),
      selectedVariants: Map<String, dynamic>.from(data['selectedVariants'] ?? {}),
    );
  }

  Map<String, dynamic> _mapOrderToDocument(UserOrder order) {
    return {
      'orderNumber': order.orderNumber,
      'userId': order.userId,
      'items': order.items.map(_mapOrderItemToDocument).toList(),
      'status': order.status.toString(),
      'paymentMethod': order.paymentMethod.toString(),
      'paymentStatus': order.paymentStatus.toString(),
      'shippingAddress': order.shippingAddress.toMap(),
      'billingAddress': order.billingAddress?.toMap(),
      'subtotal': order.subtotal,
      'shippingCost': order.shippingCost,
      'tax': order.tax,
      'total': order.total,
      'currency': order.currency,
      'notes': order.notes,
      'trackingNumber': order.trackingNumber,
      'estimatedDeliveryDate': order.estimatedDeliveryDate != null
          ? Timestamp.fromDate(order.estimatedDeliveryDate!)
          : null,
      'deliveredAt': order.deliveredAt != null
          ? Timestamp.fromDate(order.deliveredAt!)
          : null,
      'createdAt': Timestamp.fromDate(order.createdAt),
      'updatedAt': Timestamp.fromDate(order.updatedAt),
    };
  }

  Map<String, dynamic> _mapOrderItemToDocument(OrderItem item) {
    return {
      'id': item.id,
      'productId': item.productId,
      'productName': item.productName,
      'productImage': item.productImage,
      'quantity': item.quantity,
      'unitPrice': item.unitPrice,
      'totalPrice': item.totalPrice,
      'selectedVariants': item.selectedVariants,
    };
  }

  String _generateOrderNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    return 'ORD-${timestamp.toString().substring(timestamp.toString().length - 8)}';
  }
}
