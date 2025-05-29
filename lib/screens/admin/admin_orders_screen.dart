import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:souq/models/user_order.dart';
import 'package:souq/providers/admin_provider.dart';
import 'package:souq/utils/formatter_util.dart';

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();
  OrderStatus? _selectedStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ordersState = ref.watch(adminOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders Management'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(adminOrdersProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search orders...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<OrderStatus?>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Filter by Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Statuses'),
                    ),
                    ...OrderStatus.values.map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(_getStatusDisplayName(status)),
                    )),
                  ],
                  onChanged: (value) => setState(() => _selectedStatus = value),
                ),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: ordersState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                    ElevatedButton(
                      onPressed: () => ref.refresh(adminOrdersProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (orders) {
                final filteredOrders = orders.where((order) {
                  final matchesSearch = order.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                                       order.userId.toLowerCase().contains(_searchQuery.toLowerCase());
                  final matchesStatus = _selectedStatus == null || order.status == _selectedStatus;
                  return matchesSearch && matchesStatus;
                }).toList();

                if (filteredOrders.isEmpty) {
                  return const Center(
                    child: Text('No orders found'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _OrderCard(
                      order: order,
                      onStatusUpdate: (status) => _updateOrderStatus(order, status),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),    );
  }

  String _getStatusDisplayName(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.returned:
        return 'Returned';
    }
  }

  Future<void> _updateOrderStatus(UserOrder order, OrderStatus newStatus) async {
    try {
      await ref.read(adminOrdersProvider.notifier).updateOrderStatus(order.id, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order status updated to ${_getStatusDisplayName(newStatus)}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

class _OrderCard extends StatelessWidget {
  final UserOrder order;
  final Function(OrderStatus) onStatusUpdate;

  const _OrderCard({
    required this.order,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id.substring(0, 8)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(context, order.status),
              ],
            ),
            const SizedBox(height: 12),

            // Order Details
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer: ${order.userId}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Date: ${FormatterUtil.formatDate(order.createdAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Items: ${order.items.length}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      FormatterUtil.formatCurrency(order.total),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Payment: ${order.paymentMethod}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Order Items Preview
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Items:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...order.items.take(3).map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• ${item.productName} (x${item.quantity})',
                      style: theme.textTheme.bodySmall,
                    ),
                  )),
                  if (order.items.length > 3)
                    Text(
                      '... and ${order.items.length - 3} more items',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Status Update Actions
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<OrderStatus>(
                    value: order.status,
                    decoration: InputDecoration(
                      labelText: 'Update Status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: OrderStatus.values.map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(_getStatusDisplayName(status)),
                    )).toList(),
                    onChanged: (newStatus) {
                      if (newStatus != null && newStatus != order.status) {
                        _showUpdateConfirmation(context, newStatus);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to detailed order view
                    // This could be implemented as a separate detailed admin order screen
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('View'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
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
        chipColor = Colors.orange;
        break;
      case OrderStatus.shipped:
        chipColor = Colors.purple;
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _getStatusDisplayName(status),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),    );
  }

  String _getStatusDisplayName(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.returned:
        return 'Returned';
    }
  }

  void _showUpdateConfirmation(BuildContext context, OrderStatus newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: Text('Are you sure you want to update this order status to ${_getStatusDisplayName(newStatus)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onStatusUpdate(newStatus);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
