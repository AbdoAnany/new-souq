import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';
import '../../domain/entities/order_entity.dart';

/// This class helps transition from Riverpod providers to BLoC
/// It provides utility methods to make the migration smoother
class OrderProviderToBlocHelper {
  /// Creates a BLoC provider wrapper that can be used in place of Riverpod providers
  static Widget withOrderBloc({
    required Widget child,
    String? userId,
  }) {
    return BlocProvider(
      create: (context) {
        final bloc = di.sl<OrderBloc>();
        if (userId != null) {
          bloc.add(GetUserOrdersEvent(userId: userId));
        }
        return bloc;
      },
      child: child,
    );
  }

  /// Helper method to handle order state similar to AsyncValue.when()
  static Widget whenOrderState(
    BuildContext context, {
    required Widget Function(List<OrderEntity> orders) data,
    required Widget Function() loading,
    required Widget Function(String error) error,
  }) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrdersLoaded) {
          return data(state.orders);
        } else if (state is OrderLoading) {
          return loading();
        } else if (state is OrderError) {
          return error(state.message);
        } else if (state is OrderSearchResults) {
          return data(state.orders);
        }
        return loading();
      },
    );
  }

  /// Helper for single order state
  static Widget whenSingleOrderState(
    BuildContext context, {
    required Widget Function(OrderEntity order) data,
    required Widget Function() loading,
    required Widget Function(String error) error,
  }) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrderLoaded) {
          return data(state.order);
        } else if (state is OrderLoading) {
          return loading();
        } else if (state is OrderError) {
          return error(state.message);
        }
        return loading();
      },
    );
  }

  /// Extension methods for easier transition
  static OrderBlocActions actions(BuildContext context) {
    return OrderBlocActions(context);
  }
}

/// Provides familiar method names that mirror the old provider interface
class OrderBlocActions {
  final BuildContext context;

  OrderBlocActions(this.context);

  /// Equivalent to old loadUserOrders method
  void loadUserOrders(String userId, {OrderStatus? status}) {
    context.read<OrderBloc>().add(GetUserOrdersEvent(
          userId: userId,
          status: status,
        ));
  }

  /// Equivalent to old placeOrder method
  void placeOrder({
    required String userId,
    required List<OrderItemEntity> items,
    required ShippingAddressEntity shippingAddress,
    required PaymentMethod paymentMethod,
    String? notes,
  }) {
    context.read<OrderBloc>().add(PlaceOrderEvent(
          userId: userId,
          items: items,
          shippingAddress: shippingAddress,
          paymentMethod: paymentMethod,
          notes: notes,
        ));
  }

  /// Equivalent to old cancelOrder method
  void cancelOrder(String orderId) {
    context.read<OrderBloc>().add(CancelOrderEvent(orderId));
  }

  /// Equivalent to old searchOrders method
  void searchOrders(String userId, String query) {
    context.read<OrderBloc>().add(SearchOrdersEvent(
          userId: userId,
          query: query,
        ));
  }

  /// Equivalent to old refreshOrders method
  void refreshOrders(String userId) {
    context.read<OrderBloc>().add(RefreshOrdersEvent(userId));
  }
}

/// Migration helper widget that provides both provider and bloc access
/// Use this during transition period
class MigrationOrderScreen extends StatelessWidget {
  final String userId;
  final Widget Function(BuildContext context) builder;

  const MigrationOrderScreen({
    Key? key,
    required this.userId,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OrderProviderToBlocHelper.withOrderBloc(
      userId: userId,
      child: Builder(builder: builder),
    );
  }
}

/// Example usage showing the transition
class TransitionExample extends StatelessWidget {
  const TransitionExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MigrationOrderScreen(
      userId: 'user-123',
      builder: (context) {
        return Scaffold(
          appBar: AppBar(title: const Text('Orders')),
          body: OrderProviderToBlocHelper.whenOrderState(
            context,
            data: (orders) => ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return ListTile(
                  title: Text('Order #${order.orderNumber}'),
                  subtitle: Text('Status: ${order.status.name}'),
                  trailing: Text('\$${order.total.toStringAsFixed(2)}'),
                  onTap: () {
                    // Navigate to order details
                    Navigator.pushNamed(
                      context,
                      '/order-details',
                      arguments: order.id,
                    );
                  },
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (message) => Center(child: Text('Error: $message')),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Use familiar method names
              OrderProviderToBlocHelper.actions(context)
                  .refreshOrders('user-123');
            },
            child: const Icon(Icons.refresh),
          ),
        );
      },
    );
  }
}

/// Mixin to help existing ConsumerWidget classes transition to BLoC
mixin OrderBlocMixin<T extends StatefulWidget> on State<T> {
  void loadOrders(String userId) {
    context.read<OrderBloc>().add(GetUserOrdersEvent(userId: userId));
  }

  void searchOrders(String userId, String query) {
    context.read<OrderBloc>().add(SearchOrdersEvent(
          userId: userId,
          query: query,
        ));
  }

  Widget buildOrdersList() {
    return OrderProviderToBlocHelper.whenOrderState(
      context,
      data: (orders) => ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) => _buildOrderTile(orders[index]),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (message) => Center(child: Text('Error: $message')),
    );
  }

  Widget _buildOrderTile(OrderEntity order) {
    return ListTile(
      title: Text('Order #${order.orderNumber}'),
      subtitle:
          Text('${order.status.name} • \$${order.total.toStringAsFixed(2)}'),
      onTap: () => Navigator.pushNamed(
        context,
        '/order-details',
        arguments: order.id,
      ),
    );
  }
}
