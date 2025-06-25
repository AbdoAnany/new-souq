import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../utils/formatter_util.dart';
import '../../domain/entities/order_entity.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';
import '../widgets/order_item_card.dart';
import '../widgets/order_status_badge.dart';
import '../widgets/order_status_management_widget.dart';
import '../widgets/order_timeline.dart';

class OrderDetailsScreenClean extends StatefulWidget {
  final String orderId;
  final String userId;
  
  const OrderDetailsScreenClean({
    Key? key,
    required this.orderId,
    required this.userId,
  }) : super(key: key);

  @override
  State<OrderDetailsScreenClean> createState() => _OrderDetailsScreenCleanState();
}

class _OrderDetailsScreenCleanState extends State<OrderDetailsScreenClean>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<OrderBloc>()..add(GetOrderByIdEvent(widget.orderId)),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            if (state is OrderLoading) {
              return _buildLoadingState();
            } else if (state is OrderLoaded) {
              return _buildOrderDetails(context, state.order);
            } else if (state is OrderError) {
              return _buildErrorState(context, state.message);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading order details...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 72,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Oops! Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () {
                  context.read<OrderBloc>().add(GetOrderByIdEvent(widget.orderId));
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context, OrderEntity order) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildModernAppBar(context, order),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(context, order),
            _buildItemsTab(context, order),
            _buildManageTab(context, order),
          ],
        ),
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context, OrderEntity order) {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      elevation: 0,
      shadowColor: Colors.black26,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.8),
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${order.orderNumber}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              FormatterUtil.formatDate(order.orderDate),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      OrderStatusBadge(status: order.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    FormatterUtil.formatCurrency(order.total),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottom: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        indicatorColor: Theme.of(context).colorScheme.primary,
        indicatorWeight: 3,
        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.normal,
        ),
        tabs: const [
          Tab(icon: Icon(Icons.info_outline, size: 20), text: 'Overview'),
          Tab(icon: Icon(Icons.shopping_cart_outlined, size: 20), text: 'Items'),
          Tab(icon: Icon(Icons.settings_outlined, size: 20), text: 'Manage'),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handleMenuAction(context, value, order),
          itemBuilder: (context) => [
            if (order.trackingNumber != null)
              const PopupMenuItem(
                value: 'copy_tracking',
                child: ListTile(
                  leading: Icon(Icons.local_shipping),
                  title: Text('Copy Tracking'),
                  dense: true,
                ),
              ),
            const PopupMenuItem(
              value: 'copy_order_id',
              child: ListTile(
                leading: Icon(Icons.copy),
                title: Text('Copy Order ID'),
                dense: true,
              ),
            ),
            if (order.canBeCancelled)
              const PopupMenuItem(
                value: 'cancel_order',
                child: ListTile(
                  leading: Icon(Icons.cancel, color: Colors.red),
                  title: Text('Cancel Order', style: TextStyle(color: Colors.red)),
                  dense: true,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewTab(BuildContext context, OrderEntity order) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrderBloc>().add(GetOrderByIdEvent(widget.orderId));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildTimelineCard(order),
            const SizedBox(height: 12),
            _buildShippingCard(order),
            const SizedBox(height: 12),
            _buildPaymentCard(order),
            if (order.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              _buildNotesCard(order),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsTab(BuildContext context, OrderEntity order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          _buildItemsCard(context, order),
          const SizedBox(height: 12),
          _buildOrderSummaryCard(order),
          if (order.status == OrderStatus.pending || order.status == OrderStatus.confirmed) ...[
            const SizedBox(height: 12),
            _buildEditItemsCard(context, order),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildManageTab(BuildContext context, OrderEntity order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          _buildStatusManagementCard(context, order),
          const SizedBox(height: 12),
          _buildAddNotesCard(context, order),
          if (order.canBeCancelled) ...[
            const SizedBox(height: 12),
            _buildCancelOrderCard(context, order),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(OrderEntity order) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.timeline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Order Progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OrderTimeline(order: order),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingCard(OrderEntity order) {
    final address = order.shippingAddress;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.local_shipping,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Shipping Address',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              address.fullName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(address.address, style: Theme.of(context).textTheme.bodySmall),
            if (address.apartment?.isNotEmpty == true) ...[
              const SizedBox(height: 2),
              Text(address.apartment!, style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 4),
            Text(
              '${address.city}, ${address.state} ${address.postalCode}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(address.country, style: Theme.of(context).textTheme.bodySmall),
            if (address.phoneNumber?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(address.phoneNumber!, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(OrderEntity order) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.payment,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Payment Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _getPaymentMethodIcon(order.paymentMethod),
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(width: 8),
                Text(
                  _getPaymentMethodName(order.paymentMethod),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _getPaymentStatusColor(order.paymentStatus).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getPaymentStatusColor(order.paymentStatus).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getPaymentStatusIcon(order.paymentStatus),
                    size: 14,
                    color: _getPaymentStatusColor(order.paymentStatus),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Payment ${order.paymentStatus.name.toUpperCase()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getPaymentStatusColor(order.paymentStatus),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(OrderEntity order) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Order Notes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                order.notes ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard(BuildContext context, OrderEntity order) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_bag, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Items (${order.items.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OrderItemCard(item: item, showActions: false),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(OrderEntity order) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Order Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Subtotal', order.subtotal),
            _buildSummaryRow('Shipping', order.shippingCost),
            _buildSummaryRow('Tax', order.tax),
            const Divider(height: 24),
            _buildSummaryRow(
              'Total',
              order.total,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            FormatterUtil.formatCurrency(amount),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditItemsCard(BuildContext context, OrderEntity order) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Edit Order Items',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'You can modify items in this order before it enters processing.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _showEditItemsDialog(context, order),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Items'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusManagementCard(BuildContext context, OrderEntity order) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.manage_accounts, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Order Management',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OrderStatusManagementWidget(
              order: order,
              onStatusUpdate: (newStatus) {
                context.read<OrderBloc>().add(UpdateOrderStatusEvent(
                      orderId: order.id,
                      status: newStatus,
                    ));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNotesCard(BuildContext context, OrderEntity order) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note_add, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Add Notes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add notes about this order...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _addNoteToOrder(context, order),
                icon: const Icon(Icons.add_comment),
                label: const Text('Add Note'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelOrderCard(BuildContext context, OrderEntity order) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cancel, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Cancel Order',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Cancel this order if it has not been processed yet. This action cannot be undone.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showCancelDialog(context, order),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel Order'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Action Methods
  void _handleMenuAction(BuildContext context, String action, OrderEntity order) {
    switch (action) {
      case 'copy_tracking':
        if (order.trackingNumber != null) {
          _copyToClipboard(context, order.trackingNumber!);
        }
        break;
      case 'copy_order_id':
        _copyToClipboard(context, order.id);
        break;
      case 'cancel_order':
        _showCancelDialog(context, order);
        break;
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('Copied: $text'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, OrderEntity order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            const SizedBox(width: 8),
            const Text('Cancel Order'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to cancel order #${order.orderNumber}?'),
            const SizedBox(height: 8),
            Text(
              'This action cannot be undone and any payments will be refunded.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Order'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<OrderBloc>().add(CancelOrderEvent(order.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Order cancellation requested'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );
  }

  void _showEditItemsDialog(BuildContext context, OrderEntity order) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Edit Order Items',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Advanced item editing functionality will be implemented here. You can modify quantities, remove items, or add new items to the order.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Navigate to edit items screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Edit items functionality coming soon'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Text('Edit Items'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addNoteToOrder(BuildContext context, OrderEntity order) {
    if (_notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a note'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // TODO: Implement add note functionality in BLoC
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Note added successfully'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
    _notesController.clear();
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return Icons.credit_card;
      case PaymentMethod.debitCard:
        return Icons.payment;
      case PaymentMethod.paypal:
        return Icons.account_balance_wallet;
      case PaymentMethod.cashOnDelivery:
        return Icons.local_shipping;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
      case PaymentMethod.stripe:
        return Icons.credit_card;
      case PaymentMethod.unknown:
        return Icons.help_outline;
    }
  }

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.cashOnDelivery:
        return 'Cash on Delivery';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.stripe:
        return 'Stripe';
      case PaymentMethod.unknown:
        return 'Unknown';
    }
  }

  IconData _getPaymentStatusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Icons.schedule;
      case PaymentStatus.completed:
        return Icons.check_circle;
      case PaymentStatus.failed:
        return Icons.error;
      case PaymentStatus.refunded:
        return Icons.refresh;
    }
  }

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.refunded:
        return Colors.blue;
    }
  }
}
