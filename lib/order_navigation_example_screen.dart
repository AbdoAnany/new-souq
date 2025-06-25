import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/orders/presentation/helpers/navigation_migration_helper.dart';

/// Example screen showing how to use the new order navigation
class OrderNavigationExampleScreen extends ConsumerWidget {
  const OrderNavigationExampleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Navigation Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Order Migration Example',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'This example shows how to navigate to the new clean architecture order screens.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),

            // Navigate to orders using clean architecture
            ElevatedButton.icon(
              onPressed: () {
                // Using the new clean architecture navigation
                context.goToOrderList(useCleanArchitecture: true);
              },
              icon: const Icon(Icons.shopping_bag),
              label: const Text('View Orders (Clean Architecture)'),
            ),
            const SizedBox(height: 12),

            // Navigate to orders using legacy
            ElevatedButton.icon(
              onPressed: () {
                // Using legacy navigation for comparison
                context.goToOrderList(useCleanArchitecture: false);
              },
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('View Orders (Legacy)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            ),
            const SizedBox(height: 12),

            // Navigate to order details using clean architecture
            ElevatedButton.icon(
              onPressed: () {
                // Example order ID - in real app, this would come from order list
                const exampleOrderId = 'order_12345';
                context.goToOrderDetails(
                  exampleOrderId,
                  useCleanArchitecture: true,
                );
              },
              icon: const Icon(Icons.receipt_long),
              label: const Text('View Order Details (Clean Architecture)'),
            ),
            const SizedBox(height: 12),

            // Navigate to order details using legacy
            ElevatedButton.icon(
              onPressed: () {
                const exampleOrderId = 'order_12345';
                context.goToOrderDetails(
                  exampleOrderId,
                  useCleanArchitecture: false,
                );
              },
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text('View Order Details (Legacy)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            ),
            const SizedBox(height: 30),

            // Alternative navigation using static methods
            const Text(
              'Alternative Navigation Methods:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {
                OrderNavigationMigration.navigateToOrderList(context);
              },
              child: const Text('Static Method - Order List'),
            ),
            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: () {
                OrderNavigationMigration.replaceWithOrderList(context);
              },
              child: const Text('Replace Current Screen with Orders'),
            ),
            const SizedBox(height: 30),

            // Information card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Migration Notes:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Clean Architecture screens use BLoC pattern\n'
                    '• Legacy screens use Riverpod providers\n'
                    '• Both can coexist during migration\n'
                    '• Use clean architecture for new features',
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
