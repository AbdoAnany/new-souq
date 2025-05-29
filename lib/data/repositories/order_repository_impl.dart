import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
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
  Future<Result<Order, Failure>> getOrderById(String orderId) async {
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
  Future<Result<List<Order>, Failure>> getUserOrders(String userId, {int? limit}) async {
    try {
      Query query = _firestore
          .collection(AppConstants.ordersCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      final orders = querySnapshot.docs
          .map((doc) => _mapDocumentToOrder(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      return Result.success(orders);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to get user orders: ${e.toString()}'));
    }
  }
  @override
  Future<Result<Order, Failure>> createOrder({
    required String userId,
    required List<OrderItem> items,
    required double totalAmount,
    required String deliveryAddress,
    String? notes,
  }) async {
    try {
      final orderRef = _firestore
          .collection(AppConstants.ordersCollection)
          .doc();

      // Parse delivery address
      final shippingAddress = _parseDeliveryAddress(deliveryAddress);

      // Calculate order amounts
      final subtotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
      final tax = subtotal * 0.1; // 10% tax
      final shipping = 5.99; // Fixed shipping cost
      final total = subtotal + tax + shipping;

      final order = Order(
        id: orderRef.id,
        userId: userId,
        orderNumber: _generateOrderNumber(),
        items: items,
        subtotal: subtotal,
        tax: tax,
        shipping: shipping,
        total: total,
        status: OrderStatus.pending,
        shippingAddress: shippingAddress,
        paymentMethod: PaymentMethod.cashOnDelivery,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        notes: notes,
      );

      await orderRef.set(_mapOrderToDocument(order));

      return Result.success(order);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to create order: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Order, Failure>> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final orderRef = _firestore
          .collection(AppConstants.ordersCollection)
          .doc(orderId);

      final updateData = <String, dynamic>{
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add timestamp fields based on status
      switch (status) {
        case OrderStatus.confirmed:
          updateData['confirmedAt'] = FieldValue.serverTimestamp();
          break;
        case OrderStatus.processing:
          updateData['processedAt'] = FieldValue.serverTimestamp();
          break;
        case OrderStatus.shipped:
          updateData['shippedAt'] = FieldValue.serverTimestamp();
          break;
        case OrderStatus.delivered:
          updateData['deliveredAt'] = FieldValue.serverTimestamp();
          break;
        case OrderStatus.cancelled:
          updateData['cancelledAt'] = FieldValue.serverTimestamp();
          break;
        default:
          break;
      }

      await orderRef.update(updateData);

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
  Future<Result<Order, Failure>> cancelOrder(String orderId) async {
    try {
      final orderRef = _firestore
          .collection(AppConstants.ordersCollection)
          .doc(orderId);

      await orderRef.update({
        'status': OrderStatus.cancelled.name,
        'cancelledAt': FieldValue.serverTimestamp(),
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
      return Result.failure(NetworkFailure('Failed to cancel order: ${e.toString()}'));
    }
  }
  @override
  Stream<Result<List<Order>, Failure>> watchUserOrders(String userId) {
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

  // Helper methods
  Order _mapDocumentToOrder(Map<String, dynamic> data, String id) {
    final itemsData = data['items'] as List<dynamic>? ?? [];
    final items = itemsData.map((itemData) => _mapDocumentToOrderItem(itemData as Map<String, dynamic>)).toList();

    return Order(
      id: id,
      userId: data['userId'] as String,
      orderNumber: data['orderNumber'] as String,
      items: items,
      subtotal: (data['subtotal'] as num).toDouble(),
      tax: (data['tax'] as num).toDouble(),
      shipping: (data['shipping'] as num).toDouble(),
      discount: (data['discount'] as num?)?.toDouble() ?? 0.0,
      total: (data['total'] as num).toDouble(),
      status: OrderStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => OrderStatus.pending,
      ),
      shippingAddress: _mapDocumentToAddress(data['shippingAddress'] as Map<String, dynamic>),
      billingAddress: data['billingAddress'] != null
          ? _mapDocumentToAddress(data['billingAddress'] as Map<String, dynamic>)
          : null,
      paymentMethod: PaymentMethod.values.firstWhere(
        (method) => method.name == data['paymentMethod'],
        orElse: () => PaymentMethod.cashOnDelivery,
      ),
      paymentId: data['paymentId'] as String?,
      createdAt: data['createdAt'] is Timestamp 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.parse(data['createdAt'] as String),
      updatedAt: data['updatedAt'] is Timestamp 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : DateTime.parse(data['updatedAt'] as String),
      notes: data['notes'] as String?,
      confirmedAt: data['confirmedAt'] is Timestamp 
          ? (data['confirmedAt'] as Timestamp).toDate() 
          : null,
      processedAt: data['processedAt'] is Timestamp 
          ? (data['processedAt'] as Timestamp).toDate() 
          : null,
      shippedAt: data['shippedAt'] is Timestamp 
          ? (data['shippedAt'] as Timestamp).toDate() 
          : null,
      deliveredAt: data['deliveredAt'] is Timestamp 
          ? (data['deliveredAt'] as Timestamp).toDate() 
          : null,
      cancelledAt: data['cancelledAt'] is Timestamp 
          ? (data['cancelledAt'] as Timestamp).toDate() 
          : null,
      cancellationReason: data['cancellationReason'] as String?,
      trackingNumber: data['trackingNumber'] as String?,
      trackingUrl: data['trackingUrl'] as String?,
    );
  }

  OrderItem _mapDocumentToOrderItem(Map<String, dynamic> data) {
    return OrderItem(
      id: data['id'] as String,
      productId: data['productId'] as String,
      productName: data['productName'] as String,
      productImage: data['productImage'] as String,
      quantity: data['quantity'] as int,
      price: (data['price'] as num).toDouble(),
      totalPrice: (data['totalPrice'] as num).toDouble(),
      selectedVariants: data['selectedVariants'] != null 
          ? Map<String, dynamic>.from(data['selectedVariants'])
          : null,
    );
  }

  Address _mapDocumentToAddress(Map<String, dynamic> data) {
    return Address(
      street: data['street'] as String,
      city: data['city'] as String,
      state: data['state'] as String,
      zipCode: data['zipCode'] as String,
      country: data['country'] as String,
      name: data['name'] as String?,
      phone: data['phone'] as String?,
    );
  }

  Map<String, dynamic> _mapOrderToDocument(Order order) {
    return {
      'userId': order.userId,
      'orderNumber': order.orderNumber,
      'items': order.items.map(_mapOrderItemToDocument).toList(),
      'subtotal': order.subtotal,
      'tax': order.tax,
      'shipping': order.shipping,
      'discount': order.discount,
      'total': order.total,
      'status': order.status.name,
      'shippingAddress': _mapAddressToDocument(order.shippingAddress),
      'billingAddress': order.billingAddress != null 
          ? _mapAddressToDocument(order.billingAddress!)
          : null,
      'paymentMethod': order.paymentMethod.name,
      'paymentId': order.paymentId,
      'notes': order.notes,
      'confirmedAt': order.confirmedAt != null 
          ? Timestamp.fromDate(order.confirmedAt!)
          : null,
      'processedAt': order.processedAt != null 
          ? Timestamp.fromDate(order.processedAt!)
          : null,
      'shippedAt': order.shippedAt != null 
          ? Timestamp.fromDate(order.shippedAt!)
          : null,
      'deliveredAt': order.deliveredAt != null 
          ? Timestamp.fromDate(order.deliveredAt!)
          : null,
      'cancelledAt': order.cancelledAt != null 
          ? Timestamp.fromDate(order.cancelledAt!)
          : null,
      'cancellationReason': order.cancellationReason,
      'trackingNumber': order.trackingNumber,
      'trackingUrl': order.trackingUrl,
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
      'price': item.price,
      'totalPrice': item.totalPrice,
      'selectedVariants': item.selectedVariants,
    };
  }

  Map<String, dynamic> _mapAddressToDocument(Address address) {
    return {
      'street': address.street,
      'city': address.city,
      'state': address.state,
      'zipCode': address.zipCode,
      'country': address.country,
      'name': address.name,
      'phone': address.phone,
    };
  }

  Address _parseDeliveryAddress(String deliveryAddress) {
    // Simple address parsing - in production, you'd want more sophisticated parsing
    final parts = deliveryAddress.split(',').map((e) => e.trim()).toList();
    
    return Address(
      street: parts.isNotEmpty ? parts[0] : deliveryAddress,
      city: parts.length > 1 ? parts[1] : 'Unknown',
      state: parts.length > 2 ? parts[2] : 'Unknown',
      zipCode: parts.length > 3 ? parts[3] : '00000',
      country: parts.length > 4 ? parts[4] : 'Unknown',
    );
  }

  String _generateOrderNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    return 'ORD-${timestamp.toString().substring(timestamp.toString().length - 8)}';
  }
}
