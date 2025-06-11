import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:souq/constants/app_constants.dart';
import 'package:souq/models/order.dart';
import 'package:souq/providers/auth_provider.dart';
import 'package:souq/providers/order_provider.dart';
import 'package:souq/screens/order_details_screen.dart';
import 'package:souq/utils/formatter_util.dart';
import 'package:souq/utils/responsive_util.dart';
import 'package:souq/widgets/custom_button.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
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
        title: Text(
          'My Orders',
          style: TextStyle(
            fontSize:
                ResponsiveUtil.fontSize(mobile: 18, tablet: 20, desktop: 22),
          ),
        ),
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
                orders
                    .where((order) => order.status == OrderStatus.pending)
                    .toList(),
              ),

              // Confirmed orders
              _buildOrderList(
                context,
                orders
                    .where((order) => order.status == OrderStatus.confirmed)
                    .toList(),
              ),

              // Shipped orders
              _buildOrderList(
                context,
                orders
                    .where((order) => order.status == OrderStatus.shipped)
                    .toList(),
              ),

              // Delivered orders
              _buildOrderList(
                context,
                orders
                    .where((order) => order.status == OrderStatus.delivered)
                    .toList(),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: ResponsiveUtil.iconSize(
                    mobile: 48, tablet: 56, desktop: 64),
                color: Colors.red,
              ),
              SizedBox(
                  height: ResponsiveUtil.spacing(
                      mobile: 16, tablet: 18, desktop: 20)),
              Text(
                'Error loading orders',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: ResponsiveUtil.fontSize(
                      mobile: 16, tablet: 18, desktop: 20),
                ),
              ),
              SizedBox(
                  height: ResponsiveUtil.spacing(
                      mobile: 8, tablet: 10, desktop: 12)),
              TextButton(
                onPressed: () {
                  final user = ref.read(authProvider).value;
                  if (user != null) {
                    ref.read(ordersProvider.notifier).loadUserOrders(user.id);
                  }
                },
                child: Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: ResponsiveUtil.fontSize(
                        mobile: 14, tablet: 15, desktop: 16),
                  ),
                ),
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
            size: ResponsiveUtil.iconSize(mobile: 80, tablet: 96, desktop: 112),
            color: theme.dividerColor,
          ),
          SizedBox(
              height:
                  ResponsiveUtil.spacing(mobile: 16, tablet: 20, desktop: 24)),
          Text(
            "No orders yet",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize:
                  ResponsiveUtil.fontSize(mobile: 20, tablet: 24, desktop: 28),
            ),
          ),
          SizedBox(
              height:
                  ResponsiveUtil.spacing(mobile: 8, tablet: 10, desktop: 12)),
          Text(
            "You haven't placed any orders yet",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppConstants.textSecondaryColor,
              fontSize:
                  ResponsiveUtil.fontSize(mobile: 14, tablet: 15, desktop: 16),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(
              height:
                  ResponsiveUtil.spacing(mobile: 32, tablet: 40, desktop: 48)),
          SizedBox(
            width:
                ResponsiveUtil.spacing(mobile: 200, tablet: 240, desktop: 280),
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

  Widget _buildOrderList(BuildContext context, List<OrderModel> orders) {
    if (orders.isEmpty) {
      return _buildEmptyTabState(context);
    }

    return ListView.builder(
      padding: EdgeInsets.all(
        ResponsiveUtil.spacing(
            mobile: AppConstants.paddingMedium, tablet: 18, desktop: 20),
      ),
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
            size: ResponsiveUtil.iconSize(mobile: 64, tablet: 72, desktop: 80),
            color: theme.dividerColor,
          ),
          SizedBox(
              height:
                  ResponsiveUtil.spacing(mobile: 16, tablet: 18, desktop: 20)),
          Text(
            "No orders in this category",
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize:
                  ResponsiveUtil.fontSize(mobile: 16, tablet: 18, desktop: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.only(
        bottom: ResponsiveUtil.spacing(mobile: 16, tablet: 18, desktop: 20),
      ),
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
          padding: EdgeInsets.all(
            ResponsiveUtil.spacing(mobile: 16, tablet: 18, desktop: 20),
          ),
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
                      fontSize: ResponsiveUtil.fontSize(
                          mobile: 16, tablet: 17, desktop: 18),
                    ),
                  ),
                  Text(
                    FormatterUtil.formatDateShort(order.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppConstants.textSecondaryColor,
                      fontSize: ResponsiveUtil.fontSize(
                          mobile: 12, tablet: 13, desktop: 14),
                    ),
                  ),
                ],
              ),
              Divider(
                  height: ResponsiveUtil.spacing(
                      mobile: 24, tablet: 28, desktop: 32)),

              // Items preview
              Row(
                children: [
                  // Show up to 3 product images
                  Row(
                    children: order.items.take(3).map((item) {
                      final index = order.items.indexOf(item);
                      final imageSize = ResponsiveUtil.spacing(
                          mobile: 60, tablet: 66, desktop: 72);

                      return Container(
                        width: imageSize,
                        height: imageSize,
                        margin: EdgeInsets.only(
                          left: index > 0
                              ? ResponsiveUtil.spacing(
                                  mobile: -15, tablet: -16, desktop: -18)
                              : 0,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtil.spacing(
                                mobile: 8, tablet: 9, desktop: 10),
                          ),
                          image: item.image != null
                              ? DecorationImage(
                                  image: NetworkImage(item.image!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color: item.image == null ? Colors.grey[200] : null,
                        ),
                      );
                    }).toList(),
                  ),

                  // Show count of any additional items
                  if (order.items.length > 3) ...[
                    Container(
                      width: ResponsiveUtil.spacing(
                          mobile: 60, tablet: 66, desktop: 72),
                      height: ResponsiveUtil.spacing(
                          mobile: 60, tablet: 66, desktop: 72),
                      margin: EdgeInsets.only(
                        left: ResponsiveUtil.spacing(
                            mobile: -15, tablet: -16, desktop: -18),
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtil.spacing(
                              mobile: 8, tablet: 9, desktop: 10),
                        ),
                        color: theme.primaryColor.withOpacity(0.1),
                      ),
                      child: Center(
                        child: Text(
                          '+${order.items.length - 3}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveUtil.fontSize(
                                mobile: 14, tablet: 15, desktop: 16),
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
                          fontSize: ResponsiveUtil.fontSize(
                              mobile: 16, tablet: 17, desktop: 18),
                        ),
                      ),
                      SizedBox(
                          height: ResponsiveUtil.spacing(
                              mobile: 4, tablet: 5, desktop: 6)),
                      _buildStatusChip(context, order.status),
                    ],
                  ),
                ],
              ),

              SizedBox(
                  height: ResponsiveUtil.spacing(
                      mobile: 16, tablet: 18, desktop: 20)),

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
                        child: Text(
                          'Cancel Order',
                          style: TextStyle(
                            fontSize: ResponsiveUtil.fontSize(
                                mobile: 14, tablet: 15, desktop: 16),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                        width: ResponsiveUtil.spacing(
                            mobile: 12, tablet: 14, desktop: 16)),
                  ],
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OrderDetailsScreen(orderId: order.id),
                          ),
                        );
                      },
                      child: Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: ResponsiveUtil.fontSize(
                              mobile: 14, tablet: 15, desktop: 16),
                        ),
                      ),
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
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtil.spacing(mobile: 8, tablet: 10, desktop: 12),
        vertical: ResponsiveUtil.spacing(mobile: 4, tablet: 5, desktop: 6),
      ),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(
          ResponsiveUtil.spacing(mobile: 12, tablet: 14, desktop: 16),
        ),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize:
              ResponsiveUtil.fontSize(mobile: 10, tablet: 11, desktop: 12),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Cancel Order",
          style: TextStyle(
            fontSize:
                ResponsiveUtil.fontSize(mobile: 18, tablet: 20, desktop: 22),
          ),
        ),
        content: Text(
          "Are you sure you want to cancel order #${order.orderNumber}?\n\nThis action cannot be undone.",
          style: TextStyle(
            fontSize:
                ResponsiveUtil.fontSize(mobile: 14, tablet: 15, desktop: 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "No, Keep Order",
              style: TextStyle(
                fontSize: ResponsiveUtil.fontSize(
                    mobile: 14, tablet: 15, desktop: 16),
              ),
            ),
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
            child: Text(
              "Yes, Cancel Order",
              style: TextStyle(
                fontSize: ResponsiveUtil.fontSize(
                    mobile: 14, tablet: 15, desktop: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
