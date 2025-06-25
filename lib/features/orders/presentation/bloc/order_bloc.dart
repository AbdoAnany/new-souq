import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/usecases/order_management_usecases.dart';
import '../../domain/usecases/order_usecases.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final GetUserOrdersUseCase getUserOrdersUseCase;
  final GetOrderByIdUseCase getOrderByIdUseCase;
  final PlaceOrderUseCase placeOrderUseCase;
  final UpdateOrderStatusUseCase updateOrderStatusUseCase;
  final CancelOrderUseCase cancelOrderUseCase;
  final SearchOrdersUseCase searchOrdersUseCase;

  // Enhanced use cases
  final UpdateOrderWithAdminPermissionsUseCase
      updateOrderWithAdminPermissionsUseCase;
  final UpdateOrderWithValidationUseCase updateOrderWithValidationUseCase;
  final GetOrderStreamUseCase getOrderStreamUseCase;
  final ValidateOrderUpdateUseCase validateOrderUpdateUseCase;

  OrderBloc({
    required this.getUserOrdersUseCase,
    required this.getOrderByIdUseCase,
    required this.placeOrderUseCase,
    required this.updateOrderStatusUseCase,
    required this.cancelOrderUseCase,
    required this.searchOrdersUseCase,
    required this.updateOrderWithAdminPermissionsUseCase,
    required this.updateOrderWithValidationUseCase,
    required this.getOrderStreamUseCase,
    required this.validateOrderUpdateUseCase,
  }) : super(OrderInitial()) {
    on<GetUserOrdersEvent>(_onGetUserOrders);
    on<GetOrderByIdEvent>(_onGetOrderById);
    on<PlaceOrderEvent>(_onPlaceOrder);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);
    on<CancelOrderEvent>(_onCancelOrder);
    on<SearchOrdersEvent>(_onSearchOrders);
    on<RefreshOrdersEvent>(_onRefreshOrders);

    // Enhanced event handlers
    on<UpdateOrderWithAdminPermissionsEvent>(
        _onUpdateOrderWithAdminPermissions);
    on<UpdateOrderWithValidationEvent>(_onUpdateOrderWithValidation);
    on<GetOrderStreamEvent>(_onGetOrderStream);
    on<ValidateOrderUpdateEvent>(_onValidateOrderUpdate);
  }

  Future<void> _onGetUserOrders(
    GetUserOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    if (event.page == 1) {
      emit(OrderLoading());
    } else {
      // Loading more orders
      if (state is OrdersLoaded) {
        emit(OrderLoadingMore((state as OrdersLoaded).orders));
      }
    }

    final result = await getUserOrdersUseCase(GetUserOrdersParams(
      userId: event.userId,
      page: event.page,
      limit: event.limit,
      status: event.status,
    ));

    result.fold(
      (failure) => emit(OrderError(_mapFailureToMessage(failure))),
      (orders) {
        if (event.page == 1) {
          emit(OrdersLoaded(
            orders: orders,
            hasReachedMax: orders.length < event.limit,
            currentPage: event.page,
          ));
        } else {
          // Append to existing orders
          if (state is OrdersLoaded) {
            final currentState = state as OrdersLoaded;
            final allOrders = [...currentState.orders, ...orders];
            emit(OrdersLoaded(
              orders: allOrders,
              hasReachedMax: orders.length < event.limit,
              currentPage: event.page,
            ));
          }
        }
      },
    );
  }

  Future<void> _onGetOrderById(
    GetOrderByIdEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    final result = await getOrderByIdUseCase(event.orderId);

    result.fold(
      (failure) => emit(OrderError(_mapFailureToMessage(failure))),
      (order) => emit(OrderLoaded(order)),
    );
  }

  Future<void> _onPlaceOrder(
    PlaceOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    final result = await placeOrderUseCase(PlaceOrderParams(
      userId: event.userId,
      items: event.items,
      shippingAddress: event.shippingAddress,
      paymentMethod: event.paymentMethod,
      notes: event.notes,
    ));

    result.fold(
      (failure) => emit(OrderError(_mapFailureToMessage(failure))),
      (order) => emit(OrderPlaced(order)),
    );
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatusEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    final result = await updateOrderStatusUseCase(UpdateOrderStatusParams(
      orderId: event.orderId,
      status: event.status,
      trackingNumber: event.trackingNumber,
      notes: event.notes,
    ));

    result.fold(
      (failure) => emit(OrderError(_mapFailureToMessage(failure))),
      (order) => emit(OrderUpdated(order)),
    );
  }

  Future<void> _onCancelOrder(
    CancelOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    final result = await cancelOrderUseCase(event.orderId);

    result.fold(
      (failure) => emit(OrderError(_mapFailureToMessage(failure))),
      (order) => emit(OrderCancelled(order)),
    );
  }

  Future<void> _onSearchOrders(
    SearchOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    final result = await searchOrdersUseCase(SearchOrdersParams(
      userId: event.userId,
      query: event.query,
      status: event.status,
    ));

    result.fold(
      (failure) => emit(OrderError(_mapFailureToMessage(failure))),
      (orders) => emit(OrderSearchResults(
        orders: orders,
        query: event.query,
      )),
    );
  }

  Future<void> _onRefreshOrders(
    RefreshOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    // Refresh orders (reload first page)
    add(GetUserOrdersEvent(userId: event.userId, page: 1));
  }

  // Enhanced order management event handlers
  Future<void> _onUpdateOrderWithAdminPermissions(
    UpdateOrderWithAdminPermissionsEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderUpdateInProgress(
      orderId: event.orderId,
      operation: 'Updating with admin permissions',
    ));

    final result = await updateOrderWithAdminPermissionsUseCase(
      UpdateOrderWithAdminPermissionsParams(
        orderId: event.orderId,
        newStatus: event.newStatus,
        adminNotes: event.adminNotes,
        quantityUpdates: event.quantityUpdates,
        userRole: event.userRole,
        trackingNumber: event.trackingNumber,
      ),
    );

    result.fold(
      (failure) => emit(OrderError(_mapFailureToMessage(failure))),
      (order) => emit(OrderUpdateSuccess(
        order: order,
        message: 'Order updated successfully with admin permissions',
      )),
    );
  }

  Future<void> _onUpdateOrderWithValidation(
    UpdateOrderWithValidationEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderUpdateInProgress(
      orderId: event.orderId,
      operation: 'Validating and updating order',
    ));

    final result = await updateOrderWithValidationUseCase(
      UpdateOrderWithValidationParams(
        orderId: event.orderId,
        newStatus: event.newStatus,
        customerNotes: event.customerNotes,
        quantityUpdates: event.quantityUpdates,
      ),
    );

    result.fold(
      (failure) => emit(OrderError(_mapFailureToMessage(failure))),
      (order) => emit(OrderUpdateSuccess(
        order: order,
        message: 'Order updated successfully',
      )),
    );
  }

  Future<void> _onGetOrderStream(
    GetOrderStreamEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderStreamLoading());

    final result = await getOrderStreamUseCase(event.orderId);

    result.fold(
      (failure) => emit(OrderError(_mapFailureToMessage(failure))),
      (orderStream) {
        // Listen to the stream and emit updates
        orderStream.listen(
          (order) => emit(OrderStreamLoaded(order)),
          onError: (error) => emit(OrderError(error.toString())),
        );
      },
    );
  }

  Future<void> _onValidateOrderUpdate(
    ValidateOrderUpdateEvent event,
    Emitter<OrderState> emit,
  ) async {
    final result = await validateOrderUpdateUseCase(
      ValidateOrderUpdateParams(
        orderId: event.orderId,
        newStatus: event.newStatus,
        trackingNumber: event.trackingNumber,
        quantityUpdates: event.quantityUpdates,
      ),
    );

    result.fold(
      (failure) => emit(OrderValidationFailure(_mapFailureToMessage(failure))),
      (isValid) {
        if (isValid) {
          emit(const OrderValidationSuccess());
        } else {
          emit(const OrderValidationFailure('Order update validation failed'));
        }
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return (failure as ServerFailure).message;
      case CacheFailure:
        return (failure as CacheFailure).message;
      case NetworkFailure:
        return 'Please check your internet connection';
      default:
        return 'Unexpected error occurred';
    }
  }
}
