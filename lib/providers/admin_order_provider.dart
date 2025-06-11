import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:souq/models/order.dart';
import 'package:souq/services/order_service.dart';

class AdminOrdersNotifier extends StateNotifier<AsyncValue<List<OrderModel>>> {
  final OrderService _orderService;
  StreamSubscription<List<OrderModel>>? _ordersSubscription;

  AdminOrdersNotifier(this._orderService) : super(const AsyncValue.loading()) {
    _setupOrdersSubscription();
  }

  void _setupOrdersSubscription() {
    try {
      _ordersSubscription?.cancel();
      _ordersSubscription = _orderService.getOrderStreamAll().listen(
        (orders) {
          if (!mounted) return;
          state = AsyncValue.data(orders);
        },
        onError: (error, stackTrace) {
          print('Error fetching orders: $error');
          if (!mounted) return;
          state = AsyncValue.error(error, stackTrace);
        },
      );
    } catch (e) {
      print('Error fetching eeee: $e');

      if (!mounted) return;
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }

  // Fetch all orders manually
  Future<void> fetchAllOrders({
    int limit = 50,
    DocumentSnapshot? lastDocument,
    OrderStatus? status,
    String? searchQuery,
  }) async {
    if (!mounted) return;

    state = const AsyncValue.loading();
    try {
      final orders = await _orderService.getAllOrders(
        limit: limit,
        lastDocument: lastDocument,
        status: status,
        searchQuery: searchQuery,
      );
      if (!mounted) return;
      state = AsyncValue.data(orders);
    } catch (e) {
      if (!mounted) return;
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Update order status (admin function)
  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    String? trackingNumber,
    String? notes,
  }) async {
    try {
      await _orderService.adminUpdateOrderStatus(
        orderId: orderId,
        status: status,
        trackingNumber: trackingNumber,
        notes: notes,
      );

      // Update local state optimistically
      state.whenData((orders) {
        final updatedOrders = orders.map((order) {
          if (order.id == orderId) {
            return order.copyWith(
              status: status,
              trackingNumber: trackingNumber ?? order.trackingNumber,
              notes: notes ?? order.notes,
              updatedAt: DateTime.now(),
            );
          }
          return order;
        }).toList();

        state = AsyncValue.data(updatedOrders);
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get orders count by status for dashboard
  Future<Map<OrderStatus, int>> getOrdersCountByStatus() async {
    try {
      return await _orderService.getOrdersCountByStatus();
    } catch (e) {
      throw Exception('Failed to get orders count: ${e.toString()}');
    }
  }

  // Get orders analytics
  Future<Map<String, dynamic>> getOrdersAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _orderService.getOrdersAnalytics(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Failed to get orders analytics: ${e.toString()}');
    }
  }

  // Helper methods
  List<OrderModel> get allOrders => state.value ?? [];

  List<OrderModel> getOrdersByStatus(OrderStatus status) =>
      allOrders.where((order) => order.status == status).toList();

  int get totalOrdersCount => allOrders.length;

  double get totalRevenue =>
      allOrders.fold(0.0, (sum, order) => sum + order.total);

  OrderModel? getOrderById(String orderId) {
    try {
      return allOrders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  List<OrderModel> searchOrders(String query) {
    if (query.isEmpty) return allOrders;

    final lowercaseQuery = query.toLowerCase();
    return allOrders.where((order) {
      return order.orderNumber.toLowerCase().contains(lowercaseQuery) ||
          order.id.toLowerCase().contains(lowercaseQuery) ||
          '${order.shippingAddress.firstName} ${order.shippingAddress.lastName}'
              .toLowerCase()
              .contains(lowercaseQuery);
    }).toList();
  }
}

// Order Statistics Notifier for Admin Dashboard
class AdminOrderStatsNotifier
    extends StateNotifier<AsyncValue<Map<OrderStatus, int>>> {
  final OrderService _orderService;

  AdminOrderStatsNotifier(this._orderService)
      : super(const AsyncValue.loading()) {
    fetchOrderStats();
  }

  Future<void> fetchOrderStats() async {
    state = const AsyncValue.loading();
    try {
      final stats = await _orderService.getOrdersCountByStatus();
      state = AsyncValue.data(stats);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// Provider definitions
final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

final adminOrdersProvider =
    StateNotifierProvider<AdminOrdersNotifier, AsyncValue<List<OrderModel>>>(
        (ref) {
  final orderService = ref.watch(orderServiceProvider);
  return AdminOrdersNotifier(orderService);
});

final adminOrderStatsProvider = StateNotifierProvider<AdminOrderStatsNotifier,
    AsyncValue<Map<OrderStatus, int>>>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  return AdminOrderStatsNotifier(orderService);
});

// Analytics provider
final adminOrderAnalyticsProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, DateTime?>>(
        (ref, dateRange) async {
  final orderService = ref.watch(orderServiceProvider);
  return await orderService.getOrdersAnalytics(
    startDate: dateRange['startDate'],
    endDate: dateRange['endDate'],
  );
});
