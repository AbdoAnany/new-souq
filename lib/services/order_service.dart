import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:souq/models/cart.dart' show Cart, CartItem, PaymentMethod;
import 'package:souq/models/user.dart';
import 'package:souq/models/order.dart';
import 'package:souq/constants/app_constants.dart';
import 'package:souq/services/tracking_service.dart';
import 'package:uuid/uuid.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();
  final TrackingService _trackingService = TrackingService();

  // Place order
  Future<OrderModel> placeOrder({
    required String userId,
    required Cart cart,
    required Address shippingAddress,
    Address? billingAddress,
    required PaymentMethod paymentMethod,
    String? paymentId,
    String? notes,
  }) async {
    try {
      // Generate order number
      final orderNumber = _generateOrderNumber();

      // Convert cart items to order items
      final orderItems = cart.items
          .map((cartItem) => OrderItem.fromCartItem(cartItem))
          .toList();

      // Create order
      final order = OrderModel(
        id: _uuid.v4(),
        userId: userId,
        orderNumber: orderNumber,
        items: orderItems,
        subtotal: cart.subtotal,
        tax: cart.tax,
        shipping: cart.shipping,
        total: cart.total,
        status: OrderStatus.pending,
        shippingAddress: shippingAddress,
        billingAddress: billingAddress,
        paymentMethod: paymentMethod,
        paymentId: paymentId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        notes: notes,
      );

      // Save order to Firestore
      await _firestore
          .collection(AppConstants.ordersCollection)
          .doc(order.id)
          .set(order.toJson());

      // Update product quantities
      await _updateProductQuantities(cart.items);

      // Clear cart after successful order
      await _clearUserCart(userId);

      return order;
    } catch (e) {
      throw Exception('Failed to place order: ${e.toString()}');
    }
  }

  // Get user orders
  Future<List<OrderModel>> getUserOrders({
    required String userId,
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConstants.ordersCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => OrderModel.fromJson(
              {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user orders: ${e.toString()}');
    }
  }

  // Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final docSnapshot = await _firestore
          .collection(AppConstants.ordersCollection)
          .doc(orderId)
          .get();

      if (docSnapshot.exists) {
        return OrderModel.fromJson(
            {...docSnapshot.data()!, 'id': docSnapshot.id});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch order: ${e.toString()}');
    }
  }

  // Update order status
  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    String? trackingNumber,
  }) async {
    try {
      final orderDoc = await _firestore
          .collection(AppConstants.ordersCollection)
          .doc(orderId)
          .get();

      if (!orderDoc.exists) {
        throw Exception('OrderModel not found');
      }

      final order =
          OrderModel.fromJson({...orderDoc.data()!, 'id': orderDoc.id});
      final now = DateTime.now();

      Map<String, dynamic> updateData = {
        'status': status.name,
        'updatedAt': now.toIso8601String(),
      };

      // Add status-specific timestamps
      switch (status) {
        case OrderStatus.shipped:
          updateData['shippedAt'] = now.toIso8601String();
          if (trackingNumber != null) {
            updateData['trackingNumber'] = trackingNumber;
          }
          break;
        case OrderStatus.delivered:
          updateData['deliveredAt'] = now.toIso8601String();
          break;
        default:
          break;
      }

      await _firestore
          .collection(AppConstants.ordersCollection)
          .doc(orderId)
          .update(updateData);

      return order.copyWith(
        status: status,
        trackingNumber: trackingNumber ?? order.trackingNumber,
        shippedAt: status == OrderStatus.shipped ? now : order.shippedAt,
        deliveredAt: status == OrderStatus.delivered ? now : order.deliveredAt,
        updatedAt: now,
      );
    } catch (e) {
      throw Exception('Failed to update order status: ${e.toString()}');
    }
  }

  // Cancel order
  Future<OrderModel> cancelOrder(String orderId) async {
    try {
      final order = await getOrderById(orderId);
      if (order == null) {
        throw Exception('OrderModel not found');
      }

      if (!order.canBeCancelled) {
        throw Exception('OrderModel cannot be cancelled');
      }

      // Update order status
      final cancelledOrder = await updateOrderStatus(
        orderId: orderId,
        status: OrderStatus.cancelled,
      );

      // Restore product quantities
      await _restoreProductQuantities(order.items);

      return cancelledOrder;
    } catch (e) {
      throw Exception('Failed to cancel order: ${e.toString()}');
    }
  }

  // Get order stream for real-time updates
  Stream<OrderModel> getOrderStream(String orderId) {
    return _firestore
        .collection(AppConstants.ordersCollection)
        .doc(orderId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return OrderModel.fromJson({...snapshot.data()!, 'id': snapshot.id});
      } else {
        throw Exception('OrderModel not found');
      }
    });
  }

  Stream<OrderModel> ordersStream(String orderId) {
    return _firestore
        .collection(AppConstants.ordersCollection)
        .doc(orderId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return OrderModel.fromJson({...snapshot.data()!, 'id': snapshot.id});
      } else {
        throw Exception('OrderModel not found');
      }
    });
  }

  // Get all orders stream for real-time updates
  Stream<List<OrderModel>> getOrderStreamAll() {
    return _firestore
        .collection(AppConstants.ordersCollection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  // Track order
  Future<OrderTrackingInfo> trackOrder(String orderNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.ordersCollection)
          .where('orderNumber', isEqualTo: orderNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('OrderModel not found');
      }

      final order = OrderModel.fromJson({
        ...querySnapshot.docs.first.data(),
        'id': querySnapshot.docs.first.id,
      });

      return OrderTrackingInfo(
        order: order,
        trackingEvents: _trackingService.generateTrackingEvents(order),
      );
    } catch (e) {
      throw Exception('Failed to track order: ${e.toString()}');
    }
  }

  // Calculate order total
  Future<OrderCalculation> calculateOrderTotal({
    required Cart cart,
    required Address shippingAddress,
    String? couponCode,
  }) async {
    try {
      double subtotal = cart.subtotal;
      double shipping =
          cart.subtotal >= 100 ? 0.0 : 10.0; // Free shipping over $100
      double tax = subtotal * 0.1; // 10% tax
      double discount = 0.0;

      // Apply coupon if provided
      if (couponCode != null && couponCode.isNotEmpty) {
        // This would integrate with your coupon system
        // For now, it's a placeholder
      }

      double total = subtotal + shipping + tax - discount;

      return OrderCalculation(
        subtotal: subtotal,
        shipping: shipping,
        tax: tax,
        discount: discount,
        total: total,
      );
    } catch (e) {
      throw Exception('Failed to calculate order total: ${e.toString()}');
    }
  }

  // Get orders by status
  Future<List<OrderModel>> getOrdersByStatus({
    required String userId,
    required OrderStatus status,
    int limit = 20,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.ordersCollection)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: status.name)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => OrderModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch orders by status: ${e.toString()}');
    }
  }

  // Admin-specific methods

  // Get all orders for admin (without user filtering)
  Future<List<OrderModel>> getAllOrders({
    int limit = 50,
    DocumentSnapshot? lastDocument,
    OrderStatus? status,
    String? searchQuery,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConstants.ordersCollection)
          .orderBy('createdAt', descending: true);

      // Filter by status if provided
      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      // Apply limit
      query = query.limit(limit);

      // Apply pagination
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final querySnapshot = await query.get();
      var orders = querySnapshot.docs
          .map((doc) => OrderModel.fromJson(
              {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();

      // Apply search filtering if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        orders = orders.where((order) {
          final query = searchQuery.toLowerCase();
          return order.orderNumber.toLowerCase().contains(query) ||
              order.id.toLowerCase().contains(query) ||
              '${order.shippingAddress.firstName} ${order.shippingAddress.lastName}'
                  .toLowerCase()
                  .contains(query);
        }).toList();
      }

      return orders;
    } catch (e) {
      throw Exception('Failed to fetch all orders: ${e.toString()}');
    }
  }

  // Get orders count by status for admin dashboard
  Future<Map<OrderStatus, int>> getOrdersCountByStatus() async {
    try {
      final Map<OrderStatus, int> counts = {};

      for (final status in OrderStatus.values) {
        final querySnapshot = await _firestore
            .collection(AppConstants.ordersCollection)
            .where('status', isEqualTo: status.name)
            .count()
            .get();
        counts[status] = querySnapshot.count ?? 0;
      }

      return counts;
    } catch (e) {
      throw Exception('Failed to get orders count by status: ${e.toString()}');
    }
  }

  // Admin update order status with more options
  Future<OrderModel> adminUpdateOrderStatus({
    required String orderId,
    required OrderStatus status,
    String? trackingNumber,
    String? notes,
  }) async {
    try {
      final orderDoc = await _firestore
          .collection(AppConstants.ordersCollection)
          .doc(orderId)
          .get();

      if (!orderDoc.exists) {
        throw Exception('Order not found');
      }

      final order =
          OrderModel.fromJson({...orderDoc.data()!, 'id': orderDoc.id});
      final now = DateTime.now();

      Map<String, dynamic> updateData = {
        'status': status.name,
        'updatedAt': now.toIso8601String(),
      };

      // Add admin notes if provided
      if (notes != null && notes.isNotEmpty) {
        updateData['notes'] = notes;
      }

      // Add status-specific timestamps and data
      switch (status) {
        case OrderStatus.confirmed:
          updateData['confirmedAt'] = now.toIso8601String();
          break;
        case OrderStatus.processing:
          updateData['processedAt'] = now.toIso8601String();
          break;
        case OrderStatus.shipped:
          updateData['shippedAt'] = now.toIso8601String();
          if (trackingNumber != null && trackingNumber.isNotEmpty) {
            updateData['trackingNumber'] = trackingNumber;
          }
          break;
        case OrderStatus.delivered:
          updateData['deliveredAt'] = now.toIso8601String();
          break;
        case OrderStatus.cancelled:
          updateData['cancelledAt'] = now.toIso8601String();
          if (notes != null) {
            updateData['cancellationReason'] = notes;
          }
          // Restore product quantities for cancelled orders
          await _restoreProductQuantities(order.items);
          break;
        default:
          break;
      }

      await _firestore
          .collection(AppConstants.ordersCollection)
          .doc(orderId)
          .update(updateData);

      return order.copyWith(
        status: status,
        trackingNumber: trackingNumber ?? order.trackingNumber,
        notes: notes ?? order.notes,
        confirmedAt: status == OrderStatus.confirmed ? now : order.confirmedAt,
        processedAt: status == OrderStatus.processing ? now : order.processedAt,
        shippedAt: status == OrderStatus.shipped ? now : order.shippedAt,
        deliveredAt: status == OrderStatus.delivered ? now : order.deliveredAt,
        cancelledAt: status == OrderStatus.cancelled ? now : order.cancelledAt,
        cancellationReason:
            status == OrderStatus.cancelled ? notes : order.cancellationReason,
        updatedAt: now,
      );
    } catch (e) {
      throw Exception('Failed to update order status: ${e.toString()}');
    }
  }

  // Get orders analytics for admin
  Future<Map<String, dynamic>> getOrdersAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection(AppConstants.ordersCollection);

      if (startDate != null) {
        query = query.where('createdAt', isGreaterThanOrEqualTo: startDate);
      }
      if (endDate != null) {
        query = query.where('createdAt', isLessThanOrEqualTo: endDate);
      }

      final querySnapshot = await query.get();
      final orders = querySnapshot.docs
          .map((doc) => OrderModel.fromJson(
              {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();

      double totalRevenue = 0;
      double totalShipping = 0;
      double totalTax = 0;
      Map<OrderStatus, int> statusCounts = {};
      Map<String, int> topProducts = {};

      for (final order in orders) {
        totalRevenue += order.total;
        totalShipping += order.shipping;
        totalTax += order.tax;

        statusCounts[order.status] = (statusCounts[order.status] ?? 0) + 1;

        for (final item in order.items) {
          topProducts[item.title] =
              (topProducts[item.title] ?? 0) + item.quantity;
        }
      }

      return {
        'totalOrders': orders.length,
        'totalRevenue': totalRevenue,
        'totalShipping': totalShipping,
        'totalTax': totalTax,
        'averageOrderValue':
            orders.isNotEmpty ? totalRevenue / orders.length : 0,
        'statusCounts': statusCounts,
        'topProducts': topProducts,
      };
    } catch (e) {
      throw Exception('Failed to get orders analytics: ${e.toString()}');
    }
  }

  // Private helper methods
  String _generateOrderNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString();
    return 'ORD${timestamp.substring(timestamp.length - 8)}';
  }

  Future<void> _updateProductQuantities(List<CartItem> items) async {
    try {
      final batch = _firestore.batch();

      for (final item in items) {
        final productRef = _firestore
            .collection(AppConstants.productsCollection)
            .doc(item.productId);

        // Get current product data
        final productDoc = await productRef.get();
        if (productDoc.exists) {
          final currentQuantity = productDoc.data()?['quantity'] ?? 0;
          final newQuantity = currentQuantity - item.quantity;

          batch.update(productRef, {
            'quantity': newQuantity.clamp(0, double.infinity).toInt(),
            'inStock': newQuantity > 0,
            'updatedAt': DateTime.now().toIso8601String(),
          });
        }
      }

      await batch.commit();
    } catch (e) {
      // Log error but don't throw to prevent order failure
      print('Failed to update product quantities: $e');
    }
  }

  Future<void> _restoreProductQuantities(List<OrderItem> items) async {
    try {
      final batch = _firestore.batch();

      for (final item in items) {
        final productRef = _firestore
            .collection(AppConstants.productsCollection)
            .doc(item.productId);

        // Get current product data
        final productDoc = await productRef.get();
        if (productDoc.exists) {
          final currentQuantity = productDoc.data()?['quantity'] ?? 0;
          final restoredQuantity = currentQuantity + item.quantity;

          batch.update(productRef, {
            'quantity': restoredQuantity,
            'inStock': true,
            'updatedAt': DateTime.now().toIso8601String(),
          });
        }
      }

      await batch.commit();
    } catch (e) {
      // Log error but don't throw
      print('Failed to restore product quantities: $e');
    }
  }

  Future<void> _clearUserCart(String userId) async {
    try {
      await _firestore
          .collection(AppConstants.cartsCollection)
          .doc(userId)
          .update({
        'items': [],
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Log error but don't throw
      print('Failed to clear user cart: $e');
    }
  }

  // Generate tracking events for an order
  List<TrackingEvent> generateTrackingEvents(OrderModel order) {
    final events = <TrackingEvent>[];

    // OrderModel placed
    events.add(TrackingEvent(
      status: 'OrderModel Placed',
      description: 'Your order has been placed successfully',
      timestamp: order.createdAt,
      isCompleted: true,
    ));

    // OrderModel confirmed
    if (order.status.index >= OrderStatus.confirmed.index) {
      events.add(TrackingEvent(
        status: 'OrderModel Confirmed',
        description: 'Your order has been confirmed and is being prepared',
        timestamp: order.updatedAt,
        isCompleted: true,
      ));
    }

    // OrderModel shipped
    if (order.status.index >= OrderStatus.shipped.index &&
        order.shippedAt != null) {
      events.add(TrackingEvent(
        status: 'OrderModel Shipped',
        description: 'Your order has been shipped',
        timestamp: order.shippedAt!,
        isCompleted: true,
        trackingNumber: order.trackingNumber,
      ));
    }

    // OrderModel delivered
    if (order.status.index >= OrderStatus.delivered.index &&
        order.deliveredAt != null) {
      events.add(TrackingEvent(
        status: 'OrderModel Delivered',
        description: 'Your order has been delivered successfully',
        timestamp: order.deliveredAt!,
        isCompleted: true,
      ));
    }

    return events;
  }
}

class OrderCalculation {
  final double subtotal;
  final double shipping;
  final double tax;
  final double discount;
  final double total;

  OrderCalculation({
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.discount,
    required this.total,
  });
}

class OrderTrackingInfo {
  final OrderModel order;
  final List<TrackingEvent> trackingEvents;

  OrderTrackingInfo({
    required this.order,
    required this.trackingEvents,
  });
}
