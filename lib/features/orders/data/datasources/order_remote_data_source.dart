import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/order_entity.dart';
import '../models/order_model.dart';
import '../models/tracking_model.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getUserOrders({
    required String userId,
    int page = 1,
    int limit = 20,
    String? status,
  });

  Future<OrderModel> getOrderById(String orderId);

  Future<OrderModel> placeOrder(OrderModel order);

  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required String status,
    String? trackingNumber,
    String? notes,
  });

  Future<OrderModel> cancelOrder(String orderId);

  Future<OrderTrackingModel> trackOrder(String orderNumber);

  Stream<OrderModel> getOrderStream(String orderId);

  Future<List<OrderModel>> searchOrders({
    required String userId,
    required String query,
    OrderStatus? status,
  });
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final FirebaseFirestore firestore;

  OrderRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<OrderModel>> getUserOrders({
    required String userId,
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      // Simplified query to avoid index requirement temporarily
      Query query = firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .limit(limit);

      final snapshot = await query.get();

      // Get the orders and sort them in memory by orderDate (descending)
      final orders = snapshot.docs
          .map((doc) => OrderModel.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();

      // Sort by orderDate in memory (newest first)
      orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

      // Filter by status in memory if provided (to avoid compound index)
      if (status != null) {
        return orders.where((order) => order.status.name == status).toList();
      }

      return orders;
    } catch (e) {
      throw ServerException('Failed to fetch user orders: $e');
    }
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final doc = await firestore.collection('orders').doc(orderId).get();

      if (!doc.exists) {
        throw ServerException('Order not found');
      }

      return OrderModel.fromJson({
        ...doc.data()!,
        'id': doc.id,
      });
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to fetch order: $e');
    }
  }

  @override
  Future<OrderModel> placeOrder(OrderModel order) async {
    try {
      final docRef = firestore.collection('orders').doc();
      final orderWithId = order.copyWith(id: docRef.id);

      await docRef.set(orderWithId.toJson());

      return orderWithId;
    } catch (e) {
      throw ServerException('Failed to place order: $e');
    }
  }

  @override
  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required String status,
    String? trackingNumber,
    String? notes,
  }) async {
    try {
      final doc = await firestore.collection('orders').doc(orderId).get();

      if (!doc.exists) {
        throw ServerException('Order not found');
      }

      final updateData = <String, dynamic>{
        'status': status,
      };

      // Add tracking number if provided
      if (trackingNumber != null) {
        updateData['trackingNumber'] = trackingNumber;
      }

      // Add notes if provided
      if (notes != null) {
        updateData['notes'] = notes;
      }

      // Add status-specific timestamps
      final now = DateTime.now();
      switch (status) {
        case 'shipped':
          updateData['shippedDate'] = now.toIso8601String();
          break;
        case 'delivered':
          updateData['deliveredDate'] = now.toIso8601String();
          break;
      }

      await firestore.collection('orders').doc(orderId).update(updateData);

      // Return updated order
      final updatedDoc =
          await firestore.collection('orders').doc(orderId).get();
      return OrderModel.fromJson({
        ...updatedDoc.data()!,
        'id': updatedDoc.id,
      });
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to update order status: $e');
    }
  }

  @override
  Future<OrderModel> cancelOrder(String orderId) async {
    try {
      final doc = await firestore.collection('orders').doc(orderId).get();

      if (!doc.exists) {
        throw ServerException('Order not found');
      }

      final order = OrderModel.fromJson({
        ...doc.data()!,
        'id': doc.id,
      });

      if (!order.canBeCancelled) {
        throw ServerException('Order cannot be cancelled');
      }

      await firestore.collection('orders').doc(orderId).update({
        'status': 'cancelled',
      });

      return order.copyWith(status: OrderStatus.cancelled);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to cancel order: $e');
    }
  }

  @override
  Future<OrderTrackingModel> trackOrder(String orderNumber) async {
    try {
      final snapshot = await firestore
          .collection('orders')
          .where('orderNumber', isEqualTo: orderNumber)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw ServerException('Order not found');
      }

      final order = OrderModel.fromJson({
        ...snapshot.docs.first.data(),
        'id': snapshot.docs.first.id,
      });

      // Generate tracking events based on order status
      final events = _generateTrackingEvents(order);

      return OrderTrackingModel(
        orderId: order.id,
        orderNumber: order.orderNumber,
        events: events,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to track order: $e');
    }
  }

  @override
  Stream<OrderModel> getOrderStream(String orderId) {
    return firestore
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        throw ServerException('Order not found');
      }
      return OrderModel.fromJson({
        ...snapshot.data()!,
        'id': snapshot.id,
      });
    });
  }

  @override
  Future<List<OrderModel>> searchOrders({
    required String userId,
    required String query,
    OrderStatus? status,
  }) async {
    try {
      // First get user orders
      final userOrders = await getUserOrders(
        userId: userId,
        limit: 100,
        status: status?.name, // Convert OrderStatus to string
      );

      // Filter locally by order number or other searchable fields
      final filteredOrders = userOrders.where((order) {
        final searchQuery = query.toLowerCase();
        final matchesQuery =
            order.orderNumber.toLowerCase().contains(searchQuery) ||
                order.id.toLowerCase().contains(searchQuery);
        final matchesStatus = status == null || order.status == status;
        return matchesQuery && matchesStatus;
      }).toList();

      return filteredOrders;
    } catch (e) {
      throw ServerException('Failed to search orders: $e');
    }
  }

  List<TrackingEventModel> _generateTrackingEvents(OrderModel order) {
    final events = <TrackingEventModel>[];

    // Order placed
    events.add(TrackingEventModel(
      status: 'Order Placed',
      description: 'Your order has been placed successfully',
      timestamp: order.orderDate,
      isCompleted: true,
    ));

    // Order confirmed
    if (order.status.index >= OrderStatus.confirmed.index) {
      events.add(TrackingEventModel(
        status: 'Order Confirmed',
        description: 'Your order has been confirmed and is being prepared',
        timestamp:
            order.orderDate, // You might want to add a confirmedDate field
        isCompleted: true,
      ));
    }

    // Order processing
    if (order.status.index >= OrderStatus.processing.index) {
      events.add(TrackingEventModel(
        status: 'Processing',
        description: 'Your order is being processed',
        timestamp:
            order.orderDate, // You might want to add a processingDate field
        isCompleted: true,
      ));
    }

    // Order shipped
    if (order.status.index >= OrderStatus.shipped.index &&
        order.shippedDate != null) {
      events.add(TrackingEventModel(
        status: 'Order Shipped',
        description: 'Your order has been shipped',
        timestamp: order.shippedDate!,
        isCompleted: true,
        trackingNumber: order.trackingNumber,
      ));
    }

    // Order delivered
    if (order.status.index >= OrderStatus.delivered.index &&
        order.deliveredDate != null) {
      events.add(TrackingEventModel(
        status: 'Order Delivered',
        description: 'Your order has been delivered successfully',
        timestamp: order.deliveredDate!,
        isCompleted: true,
      ));
    }

    return events;
  }
}
