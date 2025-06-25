import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection_container.dart';
import '../../features/orders/presentation/bloc/order_bloc.dart';
import '../../features/orders/presentation/bloc/order_event.dart';
import '../../features/orders/presentation/screens/order_list_screen.dart';
import '../../features/orders/presentation/screens/order_details_screen.dart';

class OrderIntegrationExample extends StatelessWidget {
  const OrderIntegrationExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orders Clean Architecture Demo',
      home: const OrderHomeScreen(),
      routes: {
        '/orders': (context) => const OrderListWrapper(),
        '/order-details': (context) {
          final orderId = ModalRoute.of(context)!.settings.arguments as String;
          return OrderDetailsWrapper(orderId: orderId);
        },
      },
    );
  }
}

class OrderHomeScreen extends StatelessWidget {
  const OrderHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-commerce App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/orders');
              },
              child: const Text('View My Orders'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showPlaceOrderDemo(context),
              child: const Text('Place Test Order'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlaceOrderDemo(BuildContext context) {
    // This would typically be called from cart/checkout screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Place Order Demo'),
        content: const Text(
          'In a real app, this would be triggered from the checkout screen '
          'after payment processing.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Wrapper to provide BLoC to OrderListScreen
class OrderListWrapper extends StatelessWidget {
  const OrderListWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // In a real app, you'd get the userId from authentication
    const userId = 'demo-user-id';

    return BlocProvider(
      create: (context) => sl<OrderBloc>(),
      child: const OrderListScreen(userId: userId),
    );
  }
}

// Wrapper to provide BLoC to OrderDetailsScreen
class OrderDetailsWrapper extends StatelessWidget {
  final String orderId;

  const OrderDetailsWrapper({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<OrderBloc>()..add(GetOrderByIdEvent(orderId)),
      child: OrderDetailsScreen(
        orderId: orderId,
        userId: 'demo-user-id',
      ),
    );
  }
}
