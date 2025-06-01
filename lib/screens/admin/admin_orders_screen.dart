import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:souq/constants/app_constants.dart';
import 'package:souq/models/order.dart';
import 'package:souq/providers/admin_order_provider.dart';
import 'package:souq/screens/admin/widgets/order_details_dialog.dart';
import 'package:souq/screens/admin/widgets/order_status_update_dialog.dart';
import 'package:souq/utils/formatter_util.dart';
import 'package:souq/utils/responsive_util.dart';

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);

    // Load orders when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminOrdersProvider.notifier).fetchAllOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ordersAsync = ref.watch(adminOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search orders...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: ResponsiveUtil.fontSize(
                      mobile: 14,
                      tablet: 15,
                      desktop: 16,
                    ),
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveUtil.fontSize(
                    mobile: 14,
                    tablet: 15,
                    desktop: 16,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              )
            : Text(
                'Manage Orders',
                style: TextStyle(
                  fontSize: ResponsiveUtil.fontSize(
                    mobile: 18,
                    tablet: 20,
                    desktop: 22,
                  ),
                ),
              ),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              size: ResponsiveUtil.iconSize(
                mobile: 24,
                tablet: 26,
                desktop: 28,
              ),
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
                _isSearching = !_isSearching;
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              size: ResponsiveUtil.iconSize(
                mobile: 24,
                tablet: 26,
                desktop: 28,
              ),
            ),
            onPressed: () {
              ref.read(adminOrdersProvider.notifier).fetchAllOrders();
            },
          ),
          PopupMenuButton<String>(
            iconSize: ResponsiveUtil.iconSize(
              mobile: 24,
              tablet: 26,
              desktop: 28,
            ),
            onSelected: (value) {
              switch (value) {
                case 'analytics':
                  _showAnalytics();
                  break;
                case 'export':
                  _exportOrders();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'analytics',
                child: Row(
                  children: [
                    Icon(
                      Icons.analytics,
                      size: ResponsiveUtil.iconSize(
                        mobile: 20,
                        tablet: 22,
                        desktop: 24,
                      ),
                    ),
                    SizedBox(
                        width: ResponsiveUtil.spacing(
                      mobile: 8,
                      tablet: 10,
                      desktop: 12,
                    )),
                    Text(
                      'Analytics',
                      style: TextStyle(
                        fontSize: ResponsiveUtil.fontSize(
                          mobile: 14,
                          tablet: 15,
                          desktop: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(
                      Icons.download,
                      size: ResponsiveUtil.iconSize(
                        mobile: 20,
                        tablet: 22,
                        desktop: 24,
                      ),
                    ),
                    SizedBox(
                        width: ResponsiveUtil.spacing(
                      mobile: 8,
                      tablet: 10,
                      desktop: 12,
                    )),
                    Text(
                      'Export',
                      style: TextStyle(
                        fontSize: ResponsiveUtil.fontSize(
                          mobile: 14,
                          tablet: 15,
                          desktop: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelStyle: TextStyle(
            fontSize: ResponsiveUtil.fontSize(
              mobile: 14,
              tablet: 15,
              desktop: 16,
            ),
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: ResponsiveUtil.fontSize(
              mobile: 14,
              tablet: 15,
              desktop: 16,
            ),
          ),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Confirmed'),
            Tab(text: 'Processing'),
            Tab(text: 'Shipped'),
            Tab(text: 'Delivered'),
            Tab(text: 'Cancelled'),
            Tab(text: 'Returned'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
      body: ordersAsync.when(
        data: (orders) {
          final filteredOrders = _getFilteredOrders(orders);

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOrdersList(filteredOrders), // All
              _buildOrdersList(
                  _filterByStatus(filteredOrders, OrderStatus.pending)),
              _buildOrdersList(
                  _filterByStatus(filteredOrders, OrderStatus.confirmed)),
              _buildOrdersList(
                  _filterByStatus(filteredOrders, OrderStatus.processing)),
              _buildOrdersList(
                  _filterByStatus(filteredOrders, OrderStatus.shipped)),
              _buildOrdersList(
                  _filterByStatus(filteredOrders, OrderStatus.delivered)),
              _buildOrdersList(
                  _filterByStatus(filteredOrders, OrderStatus.cancelled)),
              _buildOrdersList(
                  _filterByStatus(filteredOrders, OrderStatus.returned)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorWidget(error.toString()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showOrdersStats,
        backgroundColor: theme.primaryColor,
        icon: Icon(
          Icons.bar_chart,
          color: Colors.white,
          size: ResponsiveUtil.iconSize(
            mobile: 20,
            tablet: 22,
            desktop: 24,
          ),
        ),
        label: Text(
          'Statistics',
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveUtil.fontSize(
              mobile: 14,
              tablet: 15,
              desktop: 16,
            ),
          ),
        ),
      ),
    );
  }

  List<OrderModel> _getFilteredOrders(List<OrderModel> orders) {
    if (_searchQuery.isEmpty) return orders;

    return orders.where((order) {
      return order.orderNumber.toLowerCase().contains(_searchQuery) ||
          order.id.toLowerCase().contains(_searchQuery) ||
          '${order.shippingAddress.firstName} ${order.shippingAddress.lastName}'
              .toLowerCase()
              .contains(_searchQuery);
    }).toList();
  }

  List<OrderModel> _filterByStatus(
      List<OrderModel> orders, OrderStatus status) {
    return orders.where((order) => order.status == status).toList();
  }

  Widget _buildOrdersList(List<OrderModel> orders) {
    if (orders.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(adminOrdersProvider.notifier).fetchAllOrders();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(ResponsiveUtil.spacing(
          mobile: 16,
          tablet: 20,
          desktop: 24,
        )),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.only(
        bottom: ResponsiveUtil.spacing(
          mobile: 12,
          tablet: 14,
          desktop: 16,
        ),
      ),
      child: InkWell(
        onTap: () => _showOrderDetails(order),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: Padding(
          padding: EdgeInsets.all(ResponsiveUtil.spacing(
            mobile: 16,
            tablet: 18,
            desktop: 20,
          )),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.orderNumber}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveUtil.fontSize(
                              mobile: 16,
                              tablet: 17,
                              desktop: 18,
                            ),
                          ),
                        ),
                        SizedBox(
                            height: ResponsiveUtil.spacing(
                          mobile: 4,
                          tablet: 5,
                          desktop: 6,
                        )),
                        Text(
                          '${order.shippingAddress.firstName} ${order.shippingAddress.lastName}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppConstants.textSecondaryColor,
                            fontSize: ResponsiveUtil.fontSize(
                              mobile: 14,
                              tablet: 15,
                              desktop: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),

              SizedBox(
                  height: ResponsiveUtil.spacing(
                mobile: 12,
                tablet: 14,
                desktop: 16,
              )),

              // Order details
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Items', '${order.items.length} items'),
                        SizedBox(
                            height: ResponsiveUtil.spacing(
                          mobile: 4,
                          tablet: 5,
                          desktop: 6,
                        )),
                        _buildInfoRow(
                            'Total', FormatterUtil.formatCurrency(order.total)),
                        SizedBox(
                            height: ResponsiveUtil.spacing(
                          mobile: 4,
                          tablet: 5,
                          desktop: 6,
                        )),
                        _buildInfoRow('Date',
                            FormatterUtil.formatDateShort(order.createdAt)),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () => _showOrderDetails(order),
                        icon: Icon(
                          Icons.visibility,
                          size: ResponsiveUtil.iconSize(
                            mobile: 20,
                            tablet: 22,
                            desktop: 24,
                          ),
                        ),
                        color: AppConstants.primaryColor,
                        tooltip: 'View Details',
                      ),
                      IconButton(
                        onPressed: () => _showStatusUpdateDialog(order),
                        icon: Icon(
                          Icons.edit,
                          size: ResponsiveUtil.iconSize(
                            mobile: 20,
                            tablet: 22,
                            desktop: 24,
                          ),
                        ),
                        color: AppConstants.accentColor,
                        tooltip: 'Update Status',
                      ),
                    ],
                  ),
                ],
              ),

              // Quick action buttons for pending/confirmed orders
              if (order.status == OrderStatus.pending ||
                  order.status == OrderStatus.confirmed) ...[
                SizedBox(
                    height: ResponsiveUtil.spacing(
                  mobile: 12,
                  tablet: 14,
                  desktop: 16,
                )),
                Row(
                  children: [
                    if (order.status == OrderStatus.pending) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _quickUpdateStatus(order, OrderStatus.confirmed),
                          icon: Icon(
                            Icons.check,
                            size: ResponsiveUtil.iconSize(
                              mobile: 16,
                              tablet: 17,
                              desktop: 18,
                            ),
                          ),
                          label: Text(
                            'Confirm',
                            style: TextStyle(
                              fontSize: ResponsiveUtil.fontSize(
                                mobile: 12,
                                tablet: 13,
                                desktop: 14,
                              ),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green,
                            side: const BorderSide(color: Colors.green),
                          ),
                        ),
                      ),
                      SizedBox(
                          width: ResponsiveUtil.spacing(
                        mobile: 8,
                        tablet: 10,
                        desktop: 12,
                      )),
                    ],
                    if (order.status == OrderStatus.confirmed) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _quickUpdateStatus(order, OrderStatus.processing),
                          icon: Icon(
                            Icons.settings,
                            size: ResponsiveUtil.iconSize(
                              mobile: 16,
                              tablet: 17,
                              desktop: 18,
                            ),
                          ),
                          label: Text(
                            'Process',
                            style: TextStyle(
                              fontSize: ResponsiveUtil.fontSize(
                                mobile: 12,
                                tablet: 13,
                                desktop: 14,
                              ),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            side: const BorderSide(color: Colors.orange),
                          ),
                        ),
                      ),
                      SizedBox(
                          width: ResponsiveUtil.spacing(
                        mobile: 8,
                        tablet: 10,
                        desktop: 12,
                      )),
                    ],
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showStatusUpdateDialog(order),
                        icon: Icon(
                          Icons.edit,
                          size: ResponsiveUtil.iconSize(
                            mobile: 16,
                            tablet: 17,
                            desktop: 18,
                          ),
                        ),
                        label: Text(
                          'Update',
                          style: TextStyle(
                            fontSize: ResponsiveUtil.fontSize(
                              mobile: 12,
                              tablet: 13,
                              desktop: 14,
                            ),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppConstants.primaryColor,
                          side: BorderSide(color: AppConstants.primaryColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppConstants.textSecondaryColor,
            fontSize: ResponsiveUtil.fontSize(
              mobile: 12,
              tablet: 13,
              desktop: 14,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: ResponsiveUtil.fontSize(
              mobile: 12,
              tablet: 13,
              desktop: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color chipColor;
    Color textColor = Colors.white;

    switch (status) {
      case OrderStatus.pending:
        chipColor = Colors.orange;
        break;
      case OrderStatus.confirmed:
        chipColor = Colors.blue;
        break;
      case OrderStatus.processing:
        chipColor = Colors.purple;
        break;
      case OrderStatus.shipped:
        chipColor = Colors.indigo;
        break;
      case OrderStatus.delivered:
        chipColor = Colors.green;
        break;
      case OrderStatus.cancelled:
        chipColor = Colors.red;
        break;
      case OrderStatus.returned:
        chipColor = Colors.brown;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtil.spacing(
          mobile: 12,
          tablet: 14,
          desktop: 16,
        ),
        vertical: ResponsiveUtil.spacing(
          mobile: 6,
          tablet: 7,
          desktop: 8,
        ),
      ),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: ResponsiveUtil.fontSize(
            mobile: 10,
            tablet: 11,
            desktop: 12,
          ),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: ResponsiveUtil.iconSize(
              mobile: 64,
              tablet: 72,
              desktop: 80,
            ),
            color: Colors.grey,
          ),
          SizedBox(
              height: ResponsiveUtil.spacing(
            mobile: 16,
            tablet: 18,
            desktop: 20,
          )),
          Text(
            'No orders found',
            style: TextStyle(
              fontSize: ResponsiveUtil.fontSize(
                mobile: 18,
                tablet: 20,
                desktop: 22,
              ),
              color: Colors.grey,
            ),
          ),
          SizedBox(
              height: ResponsiveUtil.spacing(
            mobile: 8,
            tablet: 10,
            desktop: 12,
          )),
          Text(
            'Orders will appear here when customers place them',
            style: TextStyle(
              fontSize: ResponsiveUtil.fontSize(
                mobile: 14,
                tablet: 15,
                desktop: 16,
              ),
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: AppConstants.errorColor,
            size: ResponsiveUtil.iconSize(
              mobile: 48,
              tablet: 54,
              desktop: 60,
            ),
          ),
          SizedBox(
              height: ResponsiveUtil.spacing(
            mobile: 16,
            tablet: 18,
            desktop: 20,
          )),
          Text(
            'Error loading orders',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: ResponsiveUtil.fontSize(
                    mobile: 16,
                    tablet: 18,
                    desktop: 20,
                  ),
                ),
          ),
          SizedBox(
              height: ResponsiveUtil.spacing(
            mobile: 8,
            tablet: 10,
            desktop: 12,
          )),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppConstants.textSecondaryColor,
                  fontSize: ResponsiveUtil.fontSize(
                    mobile: 14,
                    tablet: 15,
                    desktop: 16,
                  ),
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(
              height: ResponsiveUtil.spacing(
            mobile: 16,
            tablet: 18,
            desktop: 20,
          )),
          ElevatedButton(
            onPressed: () =>
                ref.read(adminOrdersProvider.notifier).fetchAllOrders(),
            child: Text(
              'Retry',
              style: TextStyle(
                fontSize: ResponsiveUtil.fontSize(
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => OrderDetailsDialog(order: order),
    );
  }

  void _showStatusUpdateDialog(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => OrderStatusUpdateDialog(
        order: order,
        onUpdate: (status, trackingNumber, notes) async {
          try {
            await ref.read(adminOrdersProvider.notifier).updateOrderStatus(
                  orderId: order.id,
                  status: status,
                  trackingNumber: trackingNumber,
                  notes: notes,
                );

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Order status updated to ${status.name}'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to update order: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _quickUpdateStatus(
      OrderModel order, OrderStatus newStatus) async {
    try {
      await ref.read(adminOrdersProvider.notifier).updateOrderStatus(
            orderId: order.id,
            status: newStatus,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order ${order.orderNumber} ${newStatus.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showOrdersStats() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Statistics'),
        content: Consumer(
          builder: (context, ref, child) {
            final statsAsync = ref.watch(adminOrderStatsProvider);

            return statsAsync.when(
              data: (stats) => SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: stats.entries.map((entry) {
                    return ListTile(
                      leading: _buildStatusChip(entry.key),
                      title: Text('${entry.key.name} Orders'),
                      trailing: Text(
                        '${entry.value}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAnalytics() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Analytics feature coming soon!'),
      ),
    );
  }

  void _exportOrders() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export feature coming soon!'),
      ),
    );
  }
}
