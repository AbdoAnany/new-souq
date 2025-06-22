import 'package:flutter/material.dart';

// Core
import 'app_routes.dart';
import 'order_route_wrappers.dart';

// Legacy screens
import '../../screens/order_history_screen.dart';
import '../../screens/order_details_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Order routes - New clean architecture
      case AppRoutes.orders:
        return MaterialPageRoute(
          builder: (_) => const OrderListWrapper(),
        );

      case AppRoutes.orderDetails:
        final orderId = settings.arguments as String?;
        if (orderId == null) {
          return _errorRoute('Order ID is required');
        }
        return MaterialPageRoute(
          builder: (_) => OrderDetailsWrapper(orderId: orderId),
        );

      // Legacy order routes (for backward compatibility during migration)
      case '/legacy/orders':
        return MaterialPageRoute(
          builder: (_) => const OrderHistoryScreen(),
        );

      case '/legacy/order-details':
        final orderId = settings.arguments as String?;
        if (orderId == null) {
          return _errorRoute('Order ID is required');
        }
        return MaterialPageRoute(
          builder: (_) => OrderDetailsScreen(orderId: orderId),
        );

      default:
        return _errorRoute('Route not found: ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
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
                'Route Error',
                style: Theme.of(_).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(_).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(_).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
