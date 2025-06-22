// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:souq/core/constants/app_constants.dart';
// import 'package:souq/models/cart.dart' show Cart, CartItem, PaymentMethod;
// import 'package:souq/models/order.dart';
// import 'package:souq/models/user.dart';
// import 'package:souq/services/tracking_service.dart';
// import 'package:uuid/uuid.dart';
//
// class OrderCalculation {
//   final double subtotal;
//   final double shipping;
//   final double tax;
//   final double discount;
//   final double total;
//
//   const OrderCalculation({
//     required this.subtotal,
//     required this.shipping,
//     required this.tax,
//     required this.discount,
//     required this.total,
//   });
// }
//
// class OrderService {
//   static final OrderService _instance = OrderService._internal();
//   factory OrderService() => _instance;
//   OrderService._internal();
//
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final Uuid _uuid = const Uuid();
//   final TrackingService _trackingService = TrackingService();
//
//   // Place order
//   Future<OrderModel> placeOrder({
//     required String userId,
//     required Cart cart,
//     required Address shippingAddress,
//     Address? billingAddress,
//     required PaymentMethod paymentMethod,
//     String? paymentId,
//     String? notes,
//   }) async {
//     try {
//       // Generate order number
//       final orderNumber = _generateOrderNumber();
//
//       // Convert cart items to order items
//       final orderItems = cart.items
//           .map((cartItem) => OrderItem.fromCartItem(cartItem))
//           .toList();
//
//       // Create order
//       final order = OrderModel(
//         id: _uuid.v4(),
//         userId: userId,
//         orderNumber: orderNumber,
//         items: orderItems,
//         subtotal: cart.subtotal,
//         tax: cart.tax,
//         shipping: cart.shipping,
//         total: cart.total,
//         status: OrderStatus.pending,
//         shippingAddress: shippingAddress,
//         billingAddress: billingAddress,
//         paymentMethod: paymentMethod,
//         paymentId: paymentId,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//         notes: notes,
//       );
//
//       // Save order to Firestore
//       await _firestore
//           .collection(AppConstants.ordersCollection)
//           .doc(order.id)
//           .set(order.toJson());
//
//       // Update product quantities
//       await _updateProductQuantities(cart.items);
//
//       // Clear cart after successful order
//       await _clearUserCart(userId);
//
//       return order;
//     } catch (e) {
//       throw Exception('Failed to place order: ${e.toString()}');
//     }
//   }
//
//   // Get user orders
//   Future<List<OrderModel>> getUserOrders({
//     required String userId,
//     int limit = 20,
//     DocumentSnapshot? lastDocument,
//   }) async {
//     try {
//       // Temporary fix: Remove orderBy to avoid composite index requirement
//       // For production, create the required Firebase index instead
//       Query query = _firestore
//           .collection(AppConstants.ordersCollection)
//           .where('userId', isEqualTo: userId)
//           .limit(limit);
//
//       if (lastDocument != null) {
//         query = query.startAfterDocument(lastDocument);
//       }
//
//       final querySnapshot = await query.get();
//
//       List<OrderModel> orders = querySnapshot.docs
//           .map((doc) => OrderModel.fromJson(
//               {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
//           .toList();
//
//       // Sort in memory by createdAt descending (newest first)
//       orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
//
//       return orders;
//     } catch (e) {
//       throw Exception('Failed to fetch user orders: ${e.toString()}');
//     }
//   }
//
//   // Get order by ID
//   Future<OrderModel?> getOrderById(String orderId) async {
//     try {
//       final docSnapshot = await _firestore
//           .collection(AppConstants.ordersCollection)
//           .doc(orderId)
//           .get();
//
//       if (docSnapshot.exists) {
//         return OrderModel.fromJson(
//             {...docSnapshot.data()!, 'id': docSnapshot.id});
//       }
//       return null;
//     } catch (e) {
//       throw Exception('Failed to fetch order: ${e.toString()}');
//     }
//   }
//
//   // Update order status
//   Future<OrderModel> updateOrderStatus({
//     required String orderId,
//     required OrderStatus status,
//     String? trackingNumber,
//   }) async {
//     try {
//       final orderDoc = await _firestore
//           .collection(AppConstants.ordersCollection)
//           .doc(orderId)
//           .get();
//
//       if (!orderDoc.exists) {
//         throw Exception('OrderModel not found');
//       }
//
//       final order =
//           OrderModel.fromJson({...orderDoc.data()!, 'id': orderDoc.id});
//       final now = DateTime.now();
//
//       Map<String, dynamic> updateData = {
//         'status': status.name,
//         'updatedAt': now.toIso8601String(),
//       };
//
//       // Add status-specific timestamps
//       switch (status) {
//         case OrderStatus.shipped:
//           updateData['shippedAt'] = now.toIso8601String();
//           if (trackingNumber != null) {
//             updateData['trackingNumber'] = trackingNumber;
//           }
//           break;
//         case OrderStatus.delivered:
//           updateData['deliveredAt'] = now.toIso8601String();
//           break;
//         default:
//           break;
//       }
//
//       await _firestore
//           .collection(AppConstants.ordersCollection)
//           .doc(orderId)
//           .update(updateData);
//
//       return order.copyWith(
//         status: status,
//         trackingNumber: trackingNumber ?? order.trackingNumber,
//         shippedAt: status == OrderStatus.shipped ? now : order.shippedAt,
//         deliveredAt: status == OrderStatus.delivered ? now : order.deliveredAt,
//         updatedAt: now,
//       );
//     } catch (e) {
//       throw Exception('Failed to update order status: ${e.toString()}');
//     }
//   }
//
//   // Cancel order
//   Future<OrderModel> cancelOrder(String orderId) async {
//     try {
//       final order = await getOrderById(orderId);
//       if (order == null) {
//         throw Exception('OrderModel not found');
//       }
//
//       if (!order.canBeCancelled) {
//         throw Exception('OrderModel cannot be cancelled');
//       }
//
//       // Update order status
//       final cancelledOrder = await updateOrderStatus(
//         orderId: orderId,
//         status: OrderStatus.cancelled,
//       );
//
//       // Restore product quantities
//       await _restoreProductQuantities(order.items);
//
//       return cancelledOrder;
//     } catch (e) {
//       throw Exception('Failed to cancel order: ${e.toString()}');
//     }
//   }
//
//   // Get order stream for real-time updates
//   Stream<OrderModel> getOrderStream(String orderId) {
//     return _firestore
//         .collection(AppConstants.ordersCollection)
//         .doc(orderId)
//         .snapshots()
//         .map((snapshot) {
//       if (snapshot.exists) {
//         return OrderModel.fromJson({...snapshot.data()!, 'id': snapshot.id});
//       } else {
//         throw Exception('OrderModel not found');
//       }
//     });
//   }
//
//   Stream<OrderModel> ordersStream(String orderId) {
//     return _firestore
//         .collection(AppConstants.ordersCollection)
//         .doc(orderId)
//         .snapshots()
//         .map((snapshot) {
//       if (snapshot.exists) {
//         return OrderModel.fromJson({...snapshot.data()!, 'id': snapshot.id});
//       } else {
//         throw Exception('OrderModel not found');
//       }
//     });
//   }
//
//   // Get all orders stream for real-time updates
//   Stream<List<OrderModel>> getOrderStreamAll() {
//     return _firestore
//         .collection(AppConstants.ordersCollection)
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs
//           .map((doc) => OrderModel.fromJson({...doc.data(), 'id': doc.id}))
//           .toList();
//     });
//   }
//
//   // Track order
//   Future<OrderTrackingInfo> trackOrder(String orderNumber) async {
//     try {
//       final querySnapshot = await _firestore
//           .collection(AppConstants.ordersCollection)
//           .where('orderNumber', isEqualTo: orderNumber)
//           .limit(1)
//           .get();
//
//       if (querySnapshot.docs.isEmpty) {
//         throw Exception('OrderModel not found');
//       }
//
//       final order = OrderModel.fromJson({
//         ...querySnapshot.docs.first.data(),
//         'id': querySnapshot.docs.first.id,
//       });
//
//       return OrderTrackingInfo(
//         order: order,
//         trackingEvents: _trackingService.generateTrackingEvents(order),
//       );
//     } catch (e) {
//       throw Exception('Failed to track order: ${e.toString()}');
//     }
//   }
//
//   // Calculate order total
//   Future<OrderCalculation> calculateOrderTotal({
//     required Cart cart,
//     required Address shippingAddress,
//     String? couponCode,
//   }) async {
//     try {
//       double subtotal = cart.subtotal;
//       double shipping =
//           cart.subtotal >= 100 ? 0.0 : 10.0; // Free shipping over $100
//       double tax = subtotal * 0.1; // 10% tax
//       double discount = 0.0;
//
//       // Apply coupon if provided
//       if (couponCode != null && couponCode.isNotEmpty) {
//         // This would integrate with your coupon system
//         // For now, it's a placeholder
//       }
//
//       double total = subtotal + shipping + tax - discount;
//
//       return OrderCalculation(
//         subtotal: subtotal,
//         shipping: shipping,
//         tax: tax,
//         discount: discount,
//         total: total,
//       );
//     } catch (e) {
//       throw Exception('Failed to calculate order total: ${e.toString()}');
//     }
//   }
//
//   // Get orders by status
//   Future<List<OrderModel>> getOrdersByStatus({
//     required String userId,
//     required OrderStatus status,
//     int limit = 20,
//   }) async {
//     try {
//       final querySnapshot = await _firestore
//           .collection(AppConstants.ordersCollection)
//           .where('userId', isEqualTo: userId)
//           .where('status', isEqualTo: status.name)
//           .orderBy('createdAt', descending: true)
//           .limit(limit)
//           .get();
//
//       return querySnapshot.docs
//           .map((doc) => OrderModel.fromJson({...doc.data(), 'id': doc.id}))
//           .toList();
//     } catch (e) {
//       throw Exception('Failed to fetch orders by status: ${e.toString()}');
//     }
//   }
//
//   // Admin-specific methods
//
//   // Get all orders for admin (without user filtering)
//   Future<List<OrderModel>> getAllOrders({
//     int limit = 50,
//     DocumentSnapshot? lastDocument,
//     OrderStatus? status,
//     String? searchQuery,
//   }) async {
//     try {
//       Query query = _firestore
//           .collection(AppConstants.ordersCollection)
//           .orderBy('createdAt', descending: true);
//
//       // Filter by status if provided
//       if (status != null) {
//         query = query.where('status', isEqualTo: status.name);
//       }
//
//       // Apply limit
//       query = query.limit(limit);
//
//       // Apply pagination
//       if (lastDocument != null) {
//         query = query.startAfterDocument(lastDocument);
//       }
//
//       final querySnapshot = await query.get();
//       var orders = querySnapshot.docs
//           .map((doc) => OrderModel.fromJson(
//               {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
//           .toList();
//
//       // Apply search filtering if provided
//       if (searchQuery != null && searchQuery.isNotEmpty) {
//         orders = orders.where((order) {
//           final query = searchQuery.toLowerCase();
//           return order.orderNumber.toLowerCase().contains(query) ||
//               order.id.toLowerCase().contains(query) ||
//               '${order.shippingAddress.firstName} ${order.shippingAddress.lastName}'
//                   .toLowerCase()
//                   .contains(query);
//         }).toList();
//       }
//
//       return orders;
//     } catch (e) {
//       throw Exception('Failed to fetch all orders: ${e.toString()}');
//     }
//   }
//
//   // Get orders count by status for admin dashboard
//   Future<Map<OrderStatus, int>> getOrdersCountByStatus() async {
//     try {
//       final Map<OrderStatus, int> counts = {};
//
//       for (final status in OrderStatus.values) {
//         final querySnapshot = await _firestore
//             .collection(AppConstants.ordersCollection)
//             .where('status', isEqualTo: status.name)
//             .count()
//             .get();
//         counts[status] = querySnapshot.count ?? 0;
//       }
//
//       return counts;
//     } catch (e) {
//       throw Exception('Failed to get orders count by status: ${e.toString()}');
//     }
//   }
//
//   // Admin update order status with more options
//   Future<OrderModel> adminUpdateOrderStatus({
//     required String orderId,
//     required OrderStatus status,
//     String? trackingNumber,
//     String? notes,
//   }) async {
//     try {
//       final orderDoc = await _firestore
//           .collection(AppConstants.ordersCollection)
//           .doc(orderId)
//           .get();
//
//       if (!orderDoc.exists) {
//         throw Exception('Order not found');
//       }
//
//       final order =
//           OrderModel.fromJson({...orderDoc.data()!, 'id': orderDoc.id});
//       final now = DateTime.now();
//
//       Map<String, dynamic> updateData = {
//         'status': status.name,
//         'updatedAt': now.toIso8601String(),
//       };
//
//       // Add admin notes if provided
//       if (notes != null && notes.isNotEmpty) {
//         updateData['notes'] = notes;
//       }
//
//       // Add status-specific timestamps and data
//       switch (status) {
//         case OrderStatus.confirmed:
//           updateData['confirmedAt'] = now.toIso8601String();
//           break;
//         case OrderStatus.processing:
//           updateData['processedAt'] = now.toIso8601String();
//           break;
//         case OrderStatus.shipped:
//           updateData['shippedAt'] = now.toIso8601String();
//           if (trackingNumber != null && trackingNumber.isNotEmpty) {
//             updateData['trackingNumber'] = trackingNumber;
//           }
//           break;
//         case OrderStatus.delivered:
//           updateData['deliveredAt'] = now.toIso8601String();
//           break;
//         case OrderStatus.cancelled:
//           updateData['cancelledAt'] = now.toIso8601String();
//           if (notes != null) {
//             updateData['cancellationReason'] = notes;
//           }
//           // Restore product quantities for cancelled orders
//           await _restoreProductQuantities(order.items);
//           break;
//         default:
//           break;
//       }
//
//       await _firestore
//           .collection(AppConstants.ordersCollection)
//           .doc(orderId)
//           .update(updateData);
//
//       return order.copyWith(
//         status: status,
//         trackingNumber: trackingNumber ?? order.trackingNumber,
//         notes: notes ?? order.notes,
//         confirmedAt: status == OrderStatus.confirmed ? now : order.confirmedAt,
//         processedAt: status == OrderStatus.processing ? now : order.processedAt,
//         shippedAt: status == OrderStatus.shipped ? now : order.shippedAt,
//         deliveredAt: status == OrderStatus.delivered ? now : order.deliveredAt,
//         cancelledAt: status == OrderStatus.cancelled ? now : order.cancelledAt,
//         cancellationReason:
//             status == OrderStatus.cancelled ? notes : order.cancellationReason,
//         updatedAt: now,
//       );
//     } catch (e) {
//       throw Exception('Failed to update order status: ${e.toString()}');
//     }
//   }
//
//   // Get orders analytics for admin
//   Future<Map<String, dynamic>> getOrdersAnalytics({
//     DateTime? startDate,
//     DateTime? endDate,
//   }) async {
//     try {
//       Query query = _firestore.collection(AppConstants.ordersCollection);
//
//       if (startDate != null) {
//         query = query.where('createdAt', isGreaterThanOrEqualTo: startDate);
//       }
//       if (endDate != null) {
//         query = query.where('createdAt', isLessThanOrEqualTo: endDate);
//       }
//
//       final querySnapshot = await query.get();
//       final orders = querySnapshot.docs
//           .map((doc) => OrderModel.fromJson(
//               {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
//           .toList();
//
//       double totalRevenue = 0;
//       double totalShipping = 0;
//       double totalTax = 0;
//       Map<OrderStatus, int> statusCounts = {};
//       Map<String, int> topProducts = {};
//
//       for (final order in orders) {
//         totalRevenue += order.total;
//         totalShipping += order.shipping;
//         totalTax += order.tax;
//
//         statusCounts[order.status] = (statusCounts[order.status] ?? 0) + 1;
//
//         for (final item in order.items) {
//           topProducts[item.title] =
//               (topProducts[item.title] ?? 0) + item.quantity;
//         }
//       }
//
//       return {
//         'totalOrders': orders.length,
//         'totalRevenue': totalRevenue,
//         'totalShipping': totalShipping,
//         'totalTax': totalTax,
//         'averageOrderValue':
//             orders.isNotEmpty ? totalRevenue / orders.length : 0,
//         'statusCounts': statusCounts,
//         'topProducts': topProducts,
//       };
//     } catch (e) {
//       throw Exception('Failed to get orders analytics: ${e.toString()}');
//     }
//   }
//
//   // Get user orders stream for real-time updates
//   Stream<List<OrderModel>> getUserOrdersStream(String userId) {
//     print('Setting up orders stream for user: $userId'); // Debug log
//     return _firestore
//         .collection(AppConstants.ordersCollection)
//         .where('userId', isEqualTo: userId)
//         // Temporary fix: Remove orderBy to avoid composite index requirement
//         .snapshots()
//         .map((snapshot) {
//       print(
//           'Received ${snapshot.docs.length} orders from Firestore'); // Debug log
//       List<OrderModel> orders = snapshot.docs.map((doc) {
//         try {
//           final data = doc.data();
//           print('Processing order doc: ${doc.id}'); // Debug log
//           return OrderModel.fromJson({...data, 'id': doc.id});
//         } catch (e) {
//           print('Error parsing order ${doc.id}: $e'); // Debug log
//           rethrow;
//         }
//       }).toList();
//
//       // Sort in memory by createdAt descending (newest first)
//       orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
//
//       return orders;
//     }).handleError((error) {
//       print('Firestore stream error: $error'); // Debug log
//     });
//   }
//
//   // Add this method temporarily for testing
//   Future<void> createTestOrdersForUser(String userId) async {
//     try {
//       print('Creating test orders for user: $userId');
//
//       // Create a test order
//       final testOrder = OrderModel(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         userId: userId,
//         orderNumber: 'ORD${DateTime.now().millisecondsSinceEpoch}',
//         items: [
//           OrderItem(
//             productId: 'test-product-1',
//             title: 'Test Product 1',
//             price: 29.99,
//             quantity: 2,
//             total: 59.98,
//             image: 'https://via.placeholder.com/150',
//           ),
//           OrderItem(
//             productId: 'test-product-2',
//             title: 'Test Product 2',
//             price: 19.99,
//             quantity: 1,
//             total: 19.99,
//             image: 'https://via.placeholder.com/150',
//           ),
//         ],
//         subtotal: 79.97,
//         tax: 7.20,
//         shipping: 0.0,
//         discount: 0.0,
//         total: 87.17,
//         status: OrderStatus.pending,
//         shippingAddress: Address(
//           id: 'test-address',
//           firstName: 'Test',
//           lastName: 'User',
//           title: 'Test Address',
//           street: '123 Test St',
//           addressLine1: '123 Test St',
//           city: 'Test City',
//           state: 'Test State',
//           postalCode: '12345',
//           country: 'Test Country',
//         ),
//         paymentMethod: PaymentMethod.cashOnDelivery,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//         notes: 'Test order',
//       );
//
//       await _firestore
//           .collection(AppConstants.ordersCollection)
//           .doc(testOrder.id)
//           .set(testOrder.toJson());
//
//       print('Test order created successfully');
//     } catch (e) {
//       print('Error creating test order: $e');
//     }
//   }
//
//   // Private helper methods
//   String _generateOrderNumber() {
//     final now = DateTime.now();
//     final timestamp = now.millisecondsSinceEpoch.toString();
//     return 'ORD${timestamp.substring(timestamp.length - 8)}';
//   }
//
//   Future<void> _updateProductQuantities(List<CartItem> items) async {
//     try {
//       final batch = _firestore.batch();
//
//       for (final item in items) {
//         final productRef = _firestore
//             .collection(AppConstants.productsCollection)
//             .doc(item.productId);
//
//         // Get current product data
//         final productDoc = await productRef.get();
//         if (productDoc.exists) {
//           final currentQuantity = productDoc.data()?['quantity'] ?? 0;
//           final newQuantity = currentQuantity - item.quantity;
//
//           batch.update(productRef, {
//             'quantity': newQuantity.clamp(0, double.infinity).toInt(),
//             'inStock': newQuantity > 0,
//             'updatedAt': DateTime.now().toIso8601String(),
//           });
//         }
//       }
//
//       await batch.commit();
//     } catch (e) {
//       // Log error but don't throw to prevent order failure
//       print('Failed to update product quantities: $e');
//     }
//   }
//
//   Future<void> _restoreProductQuantities(List<OrderItem> items) async {
//     try {
//       final batch = _firestore.batch();
//
//       for (final item in items) {
//         final productRef = _firestore
//             .collection(AppConstants.productsCollection)
//             .doc(item.productId);
//
//         // Get current product data
//         final productDoc = await productRef.get();
//         if (productDoc.exists) {
//           final currentQuantity = productDoc.data()?['quantity'] ?? 0;
//           final restoredQuantity = currentQuantity + item.quantity;
//
//           batch.update(productRef, {
//             'quantity': restoredQuantity,
//             'inStock': true,
//             'updatedAt': DateTime.now().toIso8601String(),
//           });
//         }
//       }
//
//       await batch.commit();
//     } catch (e) {
//       // Log error but don't throw
//       print('Failed to restore product quantities: $e');
//     }
//   }
//
//   Future<void> _clearUserCart(String userId) async {
//     try {
//       await _firestore
//           .collection(AppConstants.cartsCollection)
//           .doc(userId)
//           .update({
//         'items': [],
//         'updatedAt': DateTime.now().toIso8601String(),
//       });
//     } catch (e) {
//       // Log error but don't throw
//       print('Failed to clear user cart: $e');
//     }
//   }
//
//   // Generate tracking events for an order
//   List<TrackingEvent> generateTrackingEvents(OrderModel order) {
//     final events = <TrackingEvent>[];
//
//     // OrderModel placed
//     events.add(TrackingEvent(
//       status: 'OrderModel Placed',
//       description: 'Your order has been placed successfully',
//       timestamp: order.createdAt,
//       isCompleted: true,
//     ));
//
//     // OrderModel confirmed
//     if (order.status.index >= OrderStatus.confirmed.index) {
//       events.add(TrackingEvent(
//         status: 'OrderModel Confirmed',
//         description: 'Your order has been confirmed and is being prepared',
//         timestamp: order.updatedAt,
//         isCompleted: true,
//       ));
//     }
//
//     // OrderModel shipped
//     if (order.status.index >= OrderStatus.shipped.index &&
//         order.shippedAt != null) {
//       events.add(TrackingEvent(
//         status: 'OrderModel Shipped',
//         description: 'Your order has been shipped',
//         timestamp: order.shippedAt!,
//         isCompleted: true,
//         trackingNumber: order.trackingNumber,
//       ));
//     }
//
//     // OrderModel delivered
//     if (order.status.index >= OrderStatus.delivered.index &&
//         order.deliveredAt != null) {
//       events.add(TrackingEvent(
//         status: 'OrderModel Delivered',
//         description: 'Your order has been delivered successfully',
//         timestamp: order.deliveredAt!,
//         isCompleted: true,
//       ));
//     }
//
//     return events;
//   }
//
//   // Enhanced order update with validation
//   Future<OrderModel> updateOrderWithValidation({
//     required String orderId,
//     required OrderStatus newStatus,
//     String? trackingNumber,
//     String? customerNotes,
//     String? adminNotes,
//     Map<String, int>? quantityUpdates, // productId -> new quantity
//   }) async {
//     try {
//       // Get current order
//       final order = await getOrderById(orderId);
//       if (order == null) {
//         throw Exception('Order not found');
//       }
//
//       // Validate order status transition
//       if (!_isValidStatusTransition(order.status, newStatus)) {
//         throw Exception(
//             'Invalid status transition from ${order.status.name} to ${newStatus.name}');
//       }
//
//       // Validate time constraints
//       _validateTimeConstraints(order, newStatus);
//
//       // Validate and update quantities if provided
//       List<OrderItem> updatedItems = order.items;
//       if (quantityUpdates != null && quantityUpdates.isNotEmpty) {
//         updatedItems =
//             await _validateAndUpdateQuantities(order.items, quantityUpdates);
//       }
//
//       // Calculate new totals if quantities changed
//       double newSubtotal = order.subtotal;
//       double newTotal = order.total;
//
//       if (quantityUpdates != null && quantityUpdates.isNotEmpty) {
//         final calculation = _calculateOrderTotals(updatedItems);
//         newSubtotal = calculation.subtotal;
//         newTotal = calculation.total;
//       }
//
//       final now = DateTime.now();
//       Map<String, dynamic> updateData = {
//         'status': newStatus.name,
//         'updatedAt': now.toIso8601String(),
//       };
//
//       // Add customer notes if provided
//       if (customerNotes != null && customerNotes.isNotEmpty) {
//         final existingNotes = order.notes ?? '';
//         final timestamp = now.toIso8601String();
//         updateData['notes'] = existingNotes.isEmpty
//             ? 'Customer ($timestamp): $customerNotes'
//             : '$existingNotes\n\nCustomer ($timestamp): $customerNotes';
//       }
//
//       // Add admin notes if provided
//       if (adminNotes != null && adminNotes.isNotEmpty) {
//         final existingNotes = order.notes ?? '';
//         final timestamp = now.toIso8601String();
//         updateData['notes'] = existingNotes.isEmpty
//             ? 'Admin ($timestamp): $adminNotes'
//             : '$existingNotes\n\nAdmin ($timestamp): $adminNotes';
//       }
//
//       // Update quantities if changed
//       if (quantityUpdates != null && quantityUpdates.isNotEmpty) {
//         updateData['items'] =
//             updatedItems.map((item) => item.toJson()).toList();
//         updateData['subtotal'] = newSubtotal;
//         updateData['total'] = newTotal;
//       }
//
//       // Add tracking number if provided
//       if (trackingNumber != null && trackingNumber.isNotEmpty) {
//         updateData['trackingNumber'] = trackingNumber;
//       }
//
//       // Add status-specific timestamps
//       switch (newStatus) {
//         case OrderStatus.confirmed:
//           updateData['confirmedAt'] = now.toIso8601String();
//           break;
//         case OrderStatus.processing:
//           updateData['processedAt'] = now.toIso8601String();
//           break;
//         case OrderStatus.shipped:
//           updateData['shippedAt'] = now.toIso8601String();
//           if (trackingNumber == null || trackingNumber.isEmpty) {
//             throw Exception(
//                 'Tracking number is required when marking order as shipped');
//           }
//           break;
//         case OrderStatus.delivered:
//           updateData['deliveredAt'] = now.toIso8601String();
//           break;
//         case OrderStatus.cancelled:
//           updateData['cancelledAt'] = now.toIso8601String();
//           // Restore product quantities for cancelled orders
//           await _restoreProductQuantities(updatedItems);
//           break;
//         case OrderStatus.returned:
//           updateData['returnedAt'] = now.toIso8601String();
//           // Restore product quantities for returned orders
//           await _restoreProductQuantities(updatedItems);
//           break;
//         default:
//           break;
//       }
//
//       // Update the order in Firestore
//       await _firestore
//           .collection(AppConstants.ordersCollection)
//           .doc(orderId)
//           .update(updateData);
//
//       // Return updated order
//       return order.copyWith(
//         status: newStatus,
//         items: updatedItems,
//         subtotal: newSubtotal,
//         total: newTotal,
//         trackingNumber: trackingNumber ?? order.trackingNumber,
//         notes: updateData['notes'] as String? ?? order.notes,
//         confirmedAt:
//             newStatus == OrderStatus.confirmed ? now : order.confirmedAt,
//         processedAt:
//             newStatus == OrderStatus.processing ? now : order.processedAt,
//         shippedAt: newStatus == OrderStatus.shipped ? now : order.shippedAt,
//         deliveredAt:
//             newStatus == OrderStatus.delivered ? now : order.deliveredAt,
//         cancelledAt:
//             newStatus == OrderStatus.cancelled ? now : order.cancelledAt,
//         updatedAt: now,
//       );
//     } catch (e) {
//       throw Exception('Failed to update order: ${e.toString()}');
//     }
//   } // Validate status transition
//
//   bool _isValidStatusTransition(
//       OrderStatus currentStatus, OrderStatus newStatus) {
//     // Allow staying in the same status (for updating other fields like quantities, notes)
//     if (currentStatus == newStatus) {
//       return true;
//     }
//
//     // Define valid transitions
//     const validTransitions = {
//       OrderStatus.pending: [OrderStatus.confirmed, OrderStatus.cancelled],
//       OrderStatus.confirmed: [OrderStatus.processing, OrderStatus.cancelled],
//       OrderStatus.processing: [OrderStatus.shipped, OrderStatus.cancelled],
//       OrderStatus.shipped: [OrderStatus.delivered, OrderStatus.returned],
//       OrderStatus.delivered: [OrderStatus.returned],
//       OrderStatus.cancelled: [], // Terminal state
//       OrderStatus.returned: [], // Terminal state
//     };
//     return validTransitions[currentStatus]?.contains(newStatus) ?? false;
//   }
//
//   // Validate time constraints
//   void _validateTimeConstraints(OrderModel order, OrderStatus newStatus) {
//     final now = DateTime.now();
//     final orderAge = now.difference(order.createdAt);
//
//     switch (newStatus) {
//       case OrderStatus.cancelled:
//         // Can't cancel after 24 hours if confirmed, or after shipping
//         if (order.status.index >= OrderStatus.shipped.index) {
//           throw Exception('Cannot cancel order after it has been shipped');
//         }
//         if (order.status == OrderStatus.confirmed && orderAge.inHours > 24) {
//           throw Exception('Cannot cancel confirmed order after 24 hours');
//         }
//         break;
//       case OrderStatus.shipped:
//         // Must be confirmed for at least 1 hour before shipping
//         if (order.confirmedAt != null) {
//           final confirmationAge = now.difference(order.confirmedAt!);
//           if (confirmationAge.inHours < 1) {
//             throw Exception(
//                 'Order must be confirmed for at least 1 hour before shipping');
//           }
//         }
//         break;
//       case OrderStatus.delivered:
//         // Must be shipped for at least 1 day before delivery
//         if (order.shippedAt != null) {
//           final shippingAge = now.difference(order.shippedAt!);
//           if (shippingAge.inDays < 1) {
//             throw Exception(
//                 'Order must be shipped for at least 1 day before marking as delivered');
//           }
//         }
//         break;
//       default:
//         break;
//     }
//   }
//
//   // Validate and update quantities
//   Future<List<OrderItem>> _validateAndUpdateQuantities(
//     List<OrderItem> currentItems,
//     Map<String, int> quantityUpdates,
//   ) async {
//     final updatedItems = <OrderItem>[];
//
//     for (final item in currentItems) {
//       final newQuantity = quantityUpdates[item.productId];
//
//       if (newQuantity != null) {
//         // Validate new quantity
//         if (newQuantity < 0) {
//           throw Exception(
//               'Quantity cannot be negative for product ${item.title}');
//         }
//
//         if (newQuantity == 0) {
//           // Skip item if quantity is 0 (remove from order)
//           continue;
//         }
//
//         // Check product availability (you might want to implement this based on your inventory system)
//         await _validateProductAvailability(item.productId, newQuantity);
//
//         // Update item with new quantity and recalculate total
//         final updatedItem = OrderItem(
//           productId: item.productId,
//           title: item.title,
//           image: item.image,
//           price: item.price,
//           quantity: newQuantity,
//           total: item.price * newQuantity,
//           customizations: item.customizations,
//         );
//
//         updatedItems.add(updatedItem);
//       } else {
//         // Keep original item if no quantity update specified
//         updatedItems.add(item);
//       }
//     }
//
//     if (updatedItems.isEmpty) {
//       throw Exception('Order must contain at least one item');
//     }
//
//     return updatedItems;
//   }
//
//   // Validate product availability
//   Future<void> _validateProductAvailability(
//       String productId, int requestedQuantity) async {
//     try {
//       // Get product document
//       final productDoc = await _firestore
//           .collection(AppConstants.productsCollection)
//           .doc(productId)
//           .get();
//
//       if (!productDoc.exists) {
//         throw Exception('Product not found');
//       }
//
//       final productData = productDoc.data()!;
//       final availableQuantity = productData['quantity'] as int? ?? 0;
//
//       if (requestedQuantity > availableQuantity) {
//         throw Exception(
//             'Requested quantity ($requestedQuantity) exceeds available stock ($availableQuantity)');
//       }
//     } catch (e) {
//       throw Exception(
//           'Failed to validate product availability: ${e.toString()}');
//     }
//   }
//
//   // Calculate order totals
//   OrderCalculation _calculateOrderTotals(List<OrderItem> items) {
//     final subtotal = items.fold<double>(0.0, (sum, item) => sum + item.total);
//     final shipping = subtotal > 100 ? 0.0 : 10.0; // Free shipping over $100
//     final tax = subtotal * 0.08; // 8% tax
//     final total = subtotal + shipping + tax;
//
//     return OrderCalculation(
//       subtotal: subtotal,
//       shipping: shipping,
//       tax: tax,
//       discount: 0.0, // Could be enhanced to handle discounts
//       total: total,
//     );
//   }
//
//   // Admin/Employee specific order update with extended permissions
//   Future<OrderModel> updateOrderWithAdminPermissions({
//     required String orderId,
//     required OrderStatus newStatus,
//     String? trackingNumber,
//     String? adminNotes,
//     Map<String, int>? quantityUpdates,
//     String? userRole, // Add user role for validation
//   }) async {
//     try {
//       // Get current order
//       final order = await getOrderById(orderId);
//       if (order == null) {
//         throw Exception('Order not found');
//       }
//
//       // Admin/Employee can perform more flexible transitions
//       if (!_isValidAdminStatusTransition(order.status, newStatus, userRole)) {
//         throw Exception(
//             'Invalid status transition from ${order.status.name} to ${newStatus.name}');
//       }
//
//       // Admin/Employee have relaxed time constraints
//       _validateAdminTimeConstraints(order, newStatus, userRole);
//
//       // Validate and update quantities if provided
//       List<OrderItem> updatedItems = order.items;
//       if (quantityUpdates != null && quantityUpdates.isNotEmpty) {
//         updatedItems =
//             await _validateAndUpdateQuantities(order.items, quantityUpdates);
//       }
//
//       // Calculate new totals if quantities changed
//       double newSubtotal = order.subtotal;
//       double newTotal = order.total;
//
//       if (updatedItems != order.items) {
//         final calculation = _calculateOrderTotals(updatedItems);
//         newSubtotal = calculation.subtotal;
//         newTotal = calculation.total;
//       }
//
//       final now = DateTime.now();
//       Map<String, dynamic> updateData = {
//         'status': newStatus.name,
//         'updatedAt': now.toIso8601String(),
//       };
//
//       // Add tracking number if provided
//       if (trackingNumber != null && trackingNumber.isNotEmpty) {
//         updateData['trackingNumber'] = trackingNumber;
//       }
//
//       // Add admin notes with timestamp and role
//       if (adminNotes != null && adminNotes.isNotEmpty) {
//         final existingNotes = order.notes ?? '';
//         final timestamp = now.toIso8601String();
//         final rolePrefix = userRole == 'admin' ? 'Admin' : 'Employee';
//         final newNote = '[$rolePrefix - $timestamp]: $adminNotes';
//         updateData['notes'] =
//             existingNotes.isEmpty ? newNote : '$existingNotes\n$newNote';
//       }
//
//       // Update quantities if changed
//       if (updatedItems != order.items) {
//         updateData['items'] =
//             updatedItems.map((item) => item.toJson()).toList();
//         updateData['subtotal'] = newSubtotal;
//         updateData['total'] = newTotal;
//       }
//
//       // Add status-specific timestamps
//       switch (newStatus) {
//         case OrderStatus.confirmed:
//           updateData['confirmedAt'] = now.toIso8601String();
//           break;
//         case OrderStatus.processing:
//           updateData['processedAt'] = now.toIso8601String();
//           break;
//         case OrderStatus.shipped:
//           updateData['shippedAt'] = now.toIso8601String();
//           if (trackingNumber != null && trackingNumber.isNotEmpty) {
//             updateData['trackingNumber'] = trackingNumber;
//           }
//           break;
//         case OrderStatus.delivered:
//           updateData['deliveredAt'] = now.toIso8601String();
//           break;
//         case OrderStatus.cancelled:
//           updateData['cancelledAt'] = now.toIso8601String();
//           // Restore product quantities for cancelled orders
//           await _restoreProductQuantities(updatedItems);
//           break;
//         case OrderStatus.returned:
//           updateData['returnedAt'] = now.toIso8601String();
//           // Restore product quantities for returned orders
//           await _restoreProductQuantities(updatedItems);
//           break;
//         default:
//           break;
//       }
//
//       // Update the order in Firestore
//       await _firestore
//           .collection(AppConstants.ordersCollection)
//           .doc(orderId)
//           .update(updateData);
//
//       // Return updated order
//       return order.copyWith(
//         status: newStatus,
//         items: updatedItems,
//         subtotal: newSubtotal,
//         total: newTotal,
//         trackingNumber: trackingNumber ?? order.trackingNumber,
//         notes: updateData['notes'] as String? ?? order.notes,
//         confirmedAt:
//             newStatus == OrderStatus.confirmed ? now : order.confirmedAt,
//         processedAt:
//             newStatus == OrderStatus.processing ? now : order.processedAt,
//         shippedAt: newStatus == OrderStatus.shipped ? now : order.shippedAt,
//         deliveredAt:
//             newStatus == OrderStatus.delivered ? now : order.deliveredAt,
//         cancelledAt:
//             newStatus == OrderStatus.cancelled ? now : order.cancelledAt,
//         updatedAt: now,
//       );
//     } catch (e) {
//       throw Exception('Failed to update order: ${e.toString()}');
//     }
//   }
//
//   // Admin/Employee status transition validation (more permissive)
//   bool _isValidAdminStatusTransition(
//       OrderStatus currentStatus, OrderStatus newStatus, String? userRole) {
//     // Allow staying in the same status
//     if (currentStatus == newStatus) {
//       return true;
//     }
//
//     // Admin has full permissions
//     if (userRole == 'admin') {
//       // Admin can transition from any status to any other status except from terminal states
//       if (currentStatus == OrderStatus.cancelled ||
//           currentStatus == OrderStatus.returned) {
//         return false; // Cannot change from terminal states
//       }
//       return true;
//     }
//
//     // Employee has more permissions than customers but less than admin
//     if (userRole == 'employee' || userRole == 'staff') {
//       const employeeTransitions = {
//         OrderStatus.pending: [
//           OrderStatus.confirmed,
//           OrderStatus.cancelled,
//           OrderStatus.processing
//         ],
//         OrderStatus.confirmed: [
//           OrderStatus.processing,
//           OrderStatus.cancelled,
//           OrderStatus.shipped
//         ],
//         OrderStatus.processing: [OrderStatus.shipped, OrderStatus.cancelled],
//         OrderStatus.shipped: [OrderStatus.delivered, OrderStatus.returned],
//         OrderStatus.delivered: [OrderStatus.returned],
//         OrderStatus.cancelled: [], // Terminal state
//         OrderStatus.returned: [], // Terminal state
//       };
//       return employeeTransitions[currentStatus]?.contains(newStatus) ?? false;
//     }
//
//     // Default to customer validation
//     return _isValidStatusTransition(currentStatus, newStatus);
//   }
//
//   // Admin/Employee time constraint validation (more lenient)
//   void _validateAdminTimeConstraints(
//       OrderModel order, OrderStatus newStatus, String? userRole) {
//     // Admin can override most time constraints
//     if (userRole == 'admin') {
//       return; // Admin has no time constraints
//     }
//
//     // Employee has some time constraints but more lenient than customers
//     final now = DateTime.now();
//     final orderAge = now.difference(order.createdAt);
//
//     if (userRole == 'employee' || userRole == 'staff') {
//       // Employee can cancel confirmed orders within 48 hours (vs 24 for customers)
//       if (newStatus == OrderStatus.cancelled &&
//           order.status == OrderStatus.confirmed &&
//           orderAge.inHours > 48) {
//         throw Exception(
//             'Employees cannot cancel confirmed orders after 48 hours');
//       }
//     }
//   }
// }
