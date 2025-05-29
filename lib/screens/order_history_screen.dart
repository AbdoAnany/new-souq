import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:souq/constants/app_constants.dart';
import 'package:souq/models/user_order.dart';
import 'package:souq/providers/auth_provider.dart';
import 'package:souq/providers/order_provider.dart';
import 'package:souq/screens/order_details_screen.dart';
import 'package:souq/utils/formatter_util.dart';
import 'package:souq/widgets/custom_button.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    
    // Load user orders when the screen is created
    Future.microtask(() {
      final user = ref.read(authProvider).value;
      if (user != null) {
        ref.read(ordersProvider.notifier).loadUserOrders(user.id);
      }
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ordersAsyncValue = ref.watch(ordersProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Confirmed'),
            Tab(text: 'Shipped'),
            Tab(text: 'Delivered'),
          ],
          labelColor: theme.primaryColor,
          unselectedLabelColor: AppConstants.textSecondaryColor,
          indicatorColor: theme.primaryColor,
        ),
      ),
      body: ordersAsyncValue.when(
        data: (orders) {
          if (orders.isEmpty) {
            return _buildEmptyState(context);
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              // All orders
              _buildOrderList(context, orders),
              
              // Pending orders
              _buildOrderList(
                context, 
                orders.where((order) => order.status == OrderStatus.pending).toList(),
              ),
              
              // Confirmed orders
              _buildOrderList(
                context, 
                orders.where((order) => order.status == OrderStatus.confirmed).toList(),
              ),
              
              // Shipped orders
              _buildOrderList(
                context, 
                orders.where((order) => order.status == OrderStatus.shipped).toList(),
              ),
              
              // Delivered orders
              _buildOrderList(
                context, 
                orders.where((order) => order.status == OrderStatus.delivered).toList(),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading orders',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  final user = ref.read(authProvider).value;
                  if (user != null) {
                    ref.read(ordersProvider.notifier).loadUserOrders(user.id);
                  }
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: theme.dividerColor,
          ),
          const SizedBox(height: 16),
          Text(
            "No orders yet",
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            "You haven't placed any orders yet",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppConstants.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            child: CustomButton(
              text: "Start Shopping",
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrderList(BuildContext context, List<UserOrder> orders) {
    if (orders.isEmpty) {
      return _buildEmptyTabState(context);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(context, order);
      },
    );
  }
  
  Widget _buildEmptyTabState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: theme.dividerColor,
          ),
          const SizedBox(height: 16),
          Text(
            "No orders in this category",
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrderCard(BuildContext context, UserOrder order) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsScreen(orderId: order.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order number and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.orderNumber}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    FormatterUtil.formatDateShort(order.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              
              // Items preview
              Row(
                children: [
                  // Show up to 3 product images
                  Row(
                    children: order.items.take(3).map((item) {
                      final index = order.items.indexOf(item);
                      
                      return Container(
                        width: 60,
                        height: 60,
                        margin: EdgeInsets.only(left: index > 0 ? -15 : 0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),                          borderRadius: BorderRadius.circular(8),                          image: item.productImage != null ? DecorationImage(
                            image: NetworkImage(item.productImage!),
                            fit: BoxFit.cover,
                          ) : null,
                          color: item.productImage == null ? Colors.grey[200] : null,
                        ),
                      );
                    }).toList(),
                  ),
                  
                  // Show count of any additional items
                  if (order.items.length > 3) ...[
                    Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.only(left: -15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(8),
                        color: theme.primaryColor.withOpacity(0.1),
                      ),
                      child: Center(
                        child: Text(
                          '+${order.items.length - 3}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                  
                  const Spacer(),
                  
                  // Total and status
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        FormatterUtil.formatCurrency(order.total),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildStatusChip(context, order.status),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Actions
              Row(
                children: [
                  if (order.canBeCancelled) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showCancelDialog(context, order),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Cancel Order'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailsScreen(orderId: order.id),
                          ),
                        );
                      },
                      child: const Text('View Details'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
    Widget _buildStatusChip(BuildContext context, OrderStatus status) {
    Color chipColor;
    Color textColor = Colors.white;
    
    switch (status) {
      case OrderStatus.pending:
        chipColor = Colors.amber;
        break;
      case OrderStatus.confirmed:
        chipColor = Colors.blue;
        break;
      case OrderStatus.processing:
        chipColor = Colors.purple;
        break;
      case OrderStatus.shipped:
        chipColor = Colors.orange;
        break;
      case OrderStatus.delivered:
        chipColor = Colors.green;
        break;
      case OrderStatus.cancelled:
        chipColor = Colors.red;
        break;
      case OrderStatus.returned:
        chipColor = Colors.grey;
        break;
      default:
        chipColor = Colors.grey;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  void _showCancelDialog(BuildContext context, UserOrder order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Order"),
        content: Text(
          "Are you sure you want to cancel order #${order.orderNumber}?\n\nThis action cannot be undone."
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No, Keep Order"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(ordersProvider.notifier).cancelOrder(order.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Order cancelled successfully"),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Failed to cancel order: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Yes, Cancel Order"),
          ),
        ],
      ),
    );
  }
}
