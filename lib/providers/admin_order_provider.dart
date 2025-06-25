// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/order.dart';
// import '../services/order_service.dart';

// class AdminOrdersNotifier extends StateNotifier<AsyncValue<List<OrderModel>>> {
//   final OrderService _orderService;

//   AdminOrdersNotifier(this._orderService) : super(const AsyncValue.loading()) {
//     fetchAllOrders();
//   }

//   Future<void> fetchAllOrders() async {
//     try {
//       state = const AsyncValue.loading();
//       final orders = await _orderService.getAllOrders();
//       final orders = await _orderService.getAllOrders();
//         state = AsyncValue.data(orders);
//       }
//     } catch (e, stackTrace) {
//       if (mounted) {
//         state = AsyncValue.error(e, stackTrace);
//       }
//     }
//   }

//   Future<void> updateOrderStatus({
//     required String orderId,
//     required OrderStatus newStatus,
//     String? trackingNumber,
//   }) async {
//     try {
//       await _orderService.updateOrderStatus(
//         orderId: orderId,
//         status: newStatus,
//         trackingNumber: trackingNumber,
//       );
      
//       // Refresh the orders list
//       await fetchAllOrders();
//     } catch (e) {
//       print('Error updating order status: $e');
//       rethrow;
//     }
//   }

//   Future<void> cancelOrder(String orderId) async {
//     try {
//       await _orderService.cancelOrder(orderId);
//       await fetchAllOrders();
//     } catch (e) {
//       print('Error cancelling order: $e');
//       rethrow;
//     }
//   }
// }

// final adminOrdersProvider = StateNotifierProvider<AdminOrdersNotifier, AsyncValue<List<OrderModel>>>((ref) {
//   return AdminOrdersNotifier(OrderService());
// });
