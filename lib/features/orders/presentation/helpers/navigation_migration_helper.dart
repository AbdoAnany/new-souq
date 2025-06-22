import 'package:flutter/material.dart';

/// Helper class to facilitate migration from legacy navigation to new clean architecture
class OrderNavigationMigration {
  /// Navigate to order list using new clean architecture screen
  static Future<T?> navigateToOrderList<T extends Object?>(
    BuildContext context, {
    bool useCleanArchitecture = true,
  }) {
    if (useCleanArchitecture) {
      return Navigator.pushNamed<T>(context, '/orders');
    } else {
      // Legacy navigation for backward compatibility
      return Navigator.pushNamed<T>(context, '/legacy/orders');
    }
  }

  /// Navigate to order details using new clean architecture screen
  static Future<T?> navigateToOrderDetails<T extends Object?>(
    BuildContext context,
    String orderId, {
    bool useCleanArchitecture = true,
  }) {
    if (useCleanArchitecture) {
      return Navigator.pushNamed<T>(
        context,
        '/order-details',
        arguments: orderId,
      );
    } else {
      // Legacy navigation for backward compatibility
      return Navigator.pushNamed<T>(
        context,
        '/legacy/order-details',
        arguments: orderId,
      );
    }
  }

  /// Navigate to order tracking screen
  static Future<T?> navigateToOrderTracking<T extends Object?>(
    BuildContext context,
    String orderId,
  ) {
    return Navigator.pushNamed<T>(
      context,
      '/order-tracking',
      arguments: orderId,
    );
  }

  /// Replace current screen with order list
  static Future<T?> replaceWithOrderList<T extends Object?, TO extends Object?>(
    BuildContext context, {
    bool useCleanArchitecture = true,
    TO? result,
  }) {
    if (useCleanArchitecture) {
      return Navigator.pushReplacementNamed<T, TO>(
        context,
        '/orders',
        result: result,
      );
    } else {
      return Navigator.pushReplacementNamed<T, TO>(
        context,
        '/legacy/orders',
        result: result,
      );
    }
  }
}

/// Extension to make migration easier for existing code
extension OrderNavigationExtension on BuildContext {
  /// Quick access to navigate to order list
  Future<T?> goToOrderList<T extends Object?>({
    bool useCleanArchitecture = true,
  }) {
    return OrderNavigationMigration.navigateToOrderList<T>(
      this,
      useCleanArchitecture: useCleanArchitecture,
    );
  }

  /// Quick access to navigate to order details
  Future<T?> goToOrderDetails<T extends Object?>(
    String orderId, {
    bool useCleanArchitecture = true,
  }) {
    return OrderNavigationMigration.navigateToOrderDetails<T>(
      this,
      orderId,
      useCleanArchitecture: useCleanArchitecture,
    );
  }
}
