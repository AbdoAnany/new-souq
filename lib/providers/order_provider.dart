import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:souq/models/cart.dart' show PaymentMethod, Cart;
import 'package:souq/models/order.dart';
import 'package:souq/models/user.dart';
import 'package:souq/providers/auth_provider.dart';
import 'package:souq/services/order_service.dart';
import 'package:souq/services/tracking_service.dart' as tracking_service;

class OrderNotifier extends StateNotifier<AsyncValue<List<OrderModel>>> {
  final OrderService _orderService;
  StreamSubscription<List<OrderModel>>? _ordersSubscription;
  
  OrderNotifier(this._orderService) : super(const AsyncValue.loading()) {
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
          if (!mounted) return;
          state = AsyncValue.error(error, stackTrace);
        },
      );
    } catch (e) {
      if (!mounted) return;
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }
  
  Future<void> loadUserOrders(String userId) async {
    if (!mounted) return;
    
    state = const AsyncValue.loading();
    try {
      final orders = await _orderService.getUserOrders(userId: userId);
      if (!mounted) return;
      state = AsyncValue.data(orders);
    } catch (e) {
      if (!mounted) return;
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  Future<void> loadMoreOrders(String userId, DocumentSnapshot lastDocument) async {
    try {
      final moreOrders = await _orderService.getUserOrders(
        userId: userId,
        lastDocument: lastDocument,
      );
      
      final currentOrders = state.value ?? [];
      state = AsyncValue.data([...currentOrders, ...moreOrders]);
    } catch (e) {
      // We don't set the error state here to avoid losing current data
      // Just let the error propagate
      rethrow;
    }
  }
  
  Future<OrderModel> placeOrder({
    required String userId,
    required Cart cart,
    required Address shippingAddress,
    Address? billingAddress,
    required PaymentMethod paymentMethod,
    String? paymentId,
    String? notes,
  }) async {
    if (!mounted) return Future.error('OrderNotifier was disposed');
    if (cart.items.isEmpty) {
      return Future.error('Cart is empty');
    }
    
    try {
      final order = await _orderService.placeOrder(
        userId: userId,
        cart: cart,
        shippingAddress: shippingAddress,
        billingAddress: billingAddress,
        paymentMethod: paymentMethod,
        paymentId: paymentId,
        notes: notes,
      );
      
      // Update local state
      if (!mounted) return order;
      state.whenData((orders) {
        state = AsyncValue.data([order, ...orders]);
      });
      
      return order;
    } catch (e) {
      if (!mounted) return Future.error(e);
      state = AsyncValue.error(e, StackTrace.current);
      throw e;  // Re-throw to let UI handle specific error cases
    }
  }
  
  Future<OrderModel> cancelOrder(String orderId) async {
    try {
      final cancelledOrder = await _orderService.cancelOrder(orderId);
      
      state.whenData((orders) {
        final updatedOrders = orders.map((order) {
          return order.id == orderId ? cancelledOrder : order;
        }).toList();
        
        state = AsyncValue.data(updatedOrders);
      });
      
      return cancelledOrder;
    } catch (e) {
      rethrow;
    }
  }

  // Enhanced helper methods
  bool hasOrders() => (state.value ?? []).isNotEmpty;
  
  int get orderCount => state.value?.length ?? 0;
    OrderModel? getOrderById(String orderId) {
    try {
      return state.value?.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }
    
  List<OrderModel> getOrdersByStatus(OrderStatus status) =>
    state.value?.where((order) => order.status == status).toList() ?? [];
    
  bool isOrderCancellable(String orderId) {
    final order = getOrderById(orderId);
    return order != null && 
           (order.status == OrderStatus.pending || 
            order.status == OrderStatus.confirmed);
  }

  Future<List<OrderModel>> searchOrders(String query) async {
    if (!mounted) return [];
    final orders = state.value ?? [];
    
    return orders.where((order) =>
      order.id.toLowerCase().contains(query.toLowerCase()) ||
      order.orderNumber.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}

class OrderDetailNotifier extends StateNotifier<AsyncValue<OrderModel?>> {
  final OrderService _orderService;
  final String _orderId;
  StreamSubscription<OrderModel>? _orderSubscription;

  OrderDetailNotifier(this._orderService, this._orderId) : super(const AsyncValue.loading()) {
    _setupOrderSubscription();
  }

  void _setupOrderSubscription() {
    _orderSubscription?.cancel();
    _orderSubscription = _orderService.getOrderStream(_orderId).listen(
      (order) => state = AsyncValue.data(order),
      onError: (error, stack) => state = AsyncValue.error(error, stack),
    );
  }

  Future<void> refreshOrder() async {
    if (!mounted) return;
    
    state = const AsyncValue.loading();
    try {
      final order = await _orderService.getOrderById(_orderId);
      if (!mounted) return;
      state = AsyncValue.data(order);
    } catch (e, stack) {
      if (!mounted) return;
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> cancelOrder() async {
    if (!mounted) return;
    
    try {
      await _orderService.cancelOrder(_orderId);
      if (!mounted) return;
      final updatedOrder = await _orderService.getOrderById(_orderId);
      state = AsyncValue.data(updatedOrder);
    } catch (e, stack) {
      if (!mounted) return;
      state = AsyncValue.error(e, stack);
    }
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    super.dispose();
  }
}

class OrderTrackingState {
  final List<tracking_service.TrackingEvent> events;
  final bool isLoading;
  final String? error;
  final String? orderNumber;
  
  const OrderTrackingState({
    this.events = const [],
    this.isLoading = false,
    this.error,
    this.orderNumber,
  });
  
  OrderTrackingState copyWith({
    List<tracking_service.TrackingEvent>? events,
    bool? isLoading,
    String? error,
    String? orderNumber,
  }) {
    return OrderTrackingState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      error: error,  // If null is passed, we want to clear the error
      orderNumber: orderNumber ?? this.orderNumber,
    );
  }
}

class OrderTrackingNotifier extends StateNotifier<OrderTrackingState> {  final tracking_service.TrackingService _trackingService;
  final OrderService _orderService;
  StreamSubscription<OrderModel>? _orderSubscription;

  OrderTrackingNotifier(this._trackingService, this._orderService)
      : super(const OrderTrackingState());
      
  Future<void> trackOrder(String orderNumber) async {
    if (!mounted) return;
    
    // Reset state for new order tracking
    state = OrderTrackingState(
      isLoading: true,
      orderNumber: orderNumber,
    );
    
    try {
      final order = await _orderService.getOrderById(orderNumber);
      if (!mounted) return;
      
      // Set up subscription to order updates
      _setupOrderSubscription(order);
      
      // Generate initial tracking events
      final events = _trackingService.generateTrackingEvents(order);
      state = state.copyWith(
        events: events,
        isLoading: false,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to track order: ${e.toString()}',
      );
    }
  }
  
  void _setupOrderSubscription(OrderModel? order) {
    if(order==null) return;
    _orderSubscription?.cancel();
    _orderSubscription = _orderService.getOrderStream(order.id).listen(
      (updatedOrder) {
        if (!mounted) return;
        final events = _trackingService.generateTrackingEvents(updatedOrder);
        state = state.copyWith(events: events);
      },
      onError: (error) {
        if (!mounted) return;
        state = state.copyWith(
          error: 'Error updating tracking: ${error.toString()}',
        );
      },
    );
  }
  
  void clearError() {
    if (!mounted) return;
    state = state.copyWith(error: null);
  }
  
  @override
  void dispose() {
    _orderSubscription?.cancel();
    super.dispose();
  }
  
  // Helper methods
  bool get isTrackingOrder => state.orderNumber != null;
  
  bool get hasError => state.error != null;
  
  bool get isDelivered => state.events.any(
    (event) => event.status == 'Delivered' && event.isCompleted
  );
}

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

final ordersProvider = StateNotifierProvider<OrderNotifier, AsyncValue<List<OrderModel>>>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  return OrderNotifier(orderService);
});

final orderDetailProvider = StateNotifierProvider.family<OrderDetailNotifier, AsyncValue<OrderModel?>, String>((ref, orderId) {
  final orderService = ref.watch(orderServiceProvider);
  return OrderDetailNotifier(orderService, orderId);
});

final orderStreamProvider = StreamProvider.family<OrderModel, String>((ref, orderId) {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.getOrderStream(orderId);
});

final orderTrackingProvider = StateNotifierProvider<OrderTrackingNotifier, OrderTrackingState>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  final trackingService = tracking_service.TrackingService();
  return OrderTrackingNotifier(trackingService, orderService);
});

final ordersByStatusProvider = FutureProvider.family<List<OrderModel>, OrderStatus>((ref, status) async {
  final orderService = ref.watch(orderServiceProvider);
  final authState = ref.watch(authProvider);
  
  if (authState.value == null) {
    throw Exception('User not authenticated');
  }
  
  return await orderService.getOrdersByStatus(
    userId: authState.value!.id,
    status: status
  );
});
