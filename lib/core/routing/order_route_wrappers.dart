import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/orders/domain/entities/order_entity.dart';
import '../../features/orders/presentation/bloc/order_bloc.dart';
import '../../features/orders/presentation/bloc/tracking_bloc.dart';
import '../../features/orders/presentation/screens/order_details_screen.dart';
import '../../features/orders/presentation/screens/order_details_screen_clean.dart';
import '../../features/orders/presentation/screens/order_list_screen.dart';
import '../../features/orders/presentation/screens/order_update_screen.dart';
import '../../providers/auth_provider.dart';
import '../di/injection_container.dart' as di;

/// Wrapper widget that provides authentication context for order screens
class AuthenticatedOrderWrapper extends ConsumerWidget {
  final Widget Function(String userId) builder;
  final String? orderId;

  const AuthenticatedOrderWrapper({
    Key? key,
    required this.builder,
    this.orderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return _buildUnauthorizedScreen(context);
        }
        return builder(user.id);
      },
      loading: () => _buildLoadingScreen(),
      error: (error, stack) => _buildErrorScreen(context, error.toString()),
    );
  }

  Widget _buildUnauthorizedScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication Required'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Please sign in to view your orders',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String error) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Authentication Error',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pre-configured wrapper for order list screen
class OrderListWrapper extends StatelessWidget {
  const OrderListWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OrderBloc>.value(
          value: di.sl<OrderBloc>(),
        ),
      ],
      child: AuthenticatedOrderWrapper(
        builder: (userId) => OrderListScreen(userId: userId),
      ),
    );
  }
}

/// Pre-configured wrapper for order details screen
class OrderDetailsWrapper extends StatelessWidget {
  final String orderId;

  const OrderDetailsWrapper({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OrderBloc>.value(
          value: di.sl<OrderBloc>(),
        ),
        BlocProvider<TrackingBloc>.value(
          value: di.sl<TrackingBloc>(),
        ),
      ],
      child: AuthenticatedOrderWrapper(
        builder: (userId) => OrderDetailsScreen(
          orderId: orderId,
          userId: userId,
        ),
      ),
    );
  }
}

/// Pre-configured wrapper for order update screen
class OrderUpdateWrapper extends StatelessWidget {
  final OrderEntity order;

  const OrderUpdateWrapper({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OrderBloc>.value(
          value: di.sl<OrderBloc>(),
        ),
      ],
      child: AuthenticatedOrderWrapper(
        builder: (userId) => OrderUpdateScreen(order: order),
      ),
    );
  }
}

/// Pre-configured wrapper for clean architecture order details screen
class OrderDetailsCleanWrapper extends StatelessWidget {
  final String orderId;

  const OrderDetailsCleanWrapper({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OrderBloc>.value(
          value: di.sl<OrderBloc>(),
        ),
        BlocProvider<TrackingBloc>.value(
          value: di.sl<TrackingBloc>(),
        ),
      ],
      child: AuthenticatedOrderWrapper(
        builder: (userId) => OrderDetailsScreenClean(
          orderId: orderId,
          userId: userId,
        ),
      ),
    );
  }
}
