import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:souq/core/failure.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/order_usecases.dart';
import '../../data/providers/repository_providers.dart';
import '../../core/result.dart';

// Order state
class OrderState {
  final List<Order> orders;
  final Order? currentOrder;
  final bool isLoading;
  final String? error;

  const OrderState({
    this.orders = const [],
    this.currentOrder,
    this.isLoading = false,
    this.error,
  });

  OrderState copyWith({
    List<Order>? orders,
    Order? currentOrder,
    bool? isLoading,
    String? error,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      currentOrder: currentOrder ?? this.currentOrder,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Order provider
class OrderNotifier extends StateNotifier<OrderState> {
  final GetOrderByIdUseCase _getOrderByIdUseCase;
  final GetUserOrdersUseCase _getUserOrdersUseCase;
  final CreateOrderUseCase _createOrderUseCase;
  final UpdateOrderStatusUseCase _updateOrderStatusUseCase;
  final CancelOrderUseCase _cancelOrderUseCase;

  OrderNotifier({
    required GetOrderByIdUseCase getOrderByIdUseCase,
    required GetUserOrdersUseCase getUserOrdersUseCase,
    required CreateOrderUseCase createOrderUseCase,
    required UpdateOrderStatusUseCase updateOrderStatusUseCase,
    required CancelOrderUseCase cancelOrderUseCase,
  })  : _getOrderByIdUseCase = getOrderByIdUseCase,
        _getUserOrdersUseCase = getUserOrdersUseCase,
        _createOrderUseCase = createOrderUseCase,
        _updateOrderStatusUseCase = updateOrderStatusUseCase,
        _cancelOrderUseCase = cancelOrderUseCase,
        super(const OrderState());

  // Get user orders
  Future<void> getUserOrders(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getUserOrdersUseCase(GetUserOrdersParams(userId: userId));
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (orders) => state = state.copyWith(
        isLoading: false,
        orders: orders,
        error: null,
      ),
    );
  }

  // Get order by ID
  Future<void> getOrderById(String orderId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getOrderByIdUseCase(GetOrderByIdParams(orderId: orderId));
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (order) => state = state.copyWith(
        isLoading: false,
        currentOrder: order,
        error: null,
      ),
    );
  }

  // Create order
  Future<Result<Order, Failure>> createOrder({
    required String userId,
    required List<OrderItem> items,
    required double totalAmount,
    required String deliveryAddress,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _createOrderUseCase(CreateOrderParams(
      userId: userId,
      items: items,
      totalAmount: totalAmount,
      deliveryAddress: deliveryAddress,
      notes: notes,
    ));

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (order) {
        state = state.copyWith(
          isLoading: false,
          orders: [order, ...state.orders],
          currentOrder: order,
          error: null,
        );
      },
    );

    return result;
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _updateOrderStatusUseCase(UpdateOrderStatusParams(
      orderId: orderId,
      status: status,
    ));

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (order) {
        final updatedOrders = state.orders.map((o) => o.id == orderId ? order : o).toList();
        state = state.copyWith(
          isLoading: false,
          orders: updatedOrders,
          currentOrder: state.currentOrder?.id == orderId ? order : state.currentOrder,
          error: null,
        );
      },
    );
  }

  // Cancel order
  Future<void> cancelOrder(String orderId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _cancelOrderUseCase(CancelOrderParams(orderId: orderId));

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (order) {
        final updatedOrders = state.orders.map((o) => o.id == orderId ? order : o).toList();
        state = state.copyWith(
          isLoading: false,
          orders: updatedOrders,
          currentOrder: state.currentOrder?.id == orderId ? order : state.currentOrder,
          error: null,
        );
      },
    );
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Clear current order
  void clearCurrentOrder() {
    state = state.copyWith(currentOrder: null);
  }
}

// Provider definitions
final orderNotifierProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  final orderRepository = ref.watch(orderRepositoryProvider);
  
  return OrderNotifier(
    getOrderByIdUseCase: GetOrderByIdUseCase(orderRepository),
    getUserOrdersUseCase: GetUserOrdersUseCase(orderRepository),
    createOrderUseCase: CreateOrderUseCase(orderRepository),
    updateOrderStatusUseCase: UpdateOrderStatusUseCase(orderRepository),
    cancelOrderUseCase: CancelOrderUseCase(orderRepository),
  );
});

// Convenience providers
final ordersProvider = Provider<List<Order>>((ref) {
  return ref.watch(orderNotifierProvider).orders;
});

final currentOrderProvider = Provider<Order?>((ref) {
  return ref.watch(orderNotifierProvider).currentOrder;
});

final isOrderLoadingProvider = Provider<bool>((ref) {
  return ref.watch(orderNotifierProvider).isLoading;
});

final orderErrorProvider = Provider<String?>((ref) {
  return ref.watch(orderNotifierProvider).error;
});
