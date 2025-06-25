import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:souq/core/themes/style/text_styles.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../utils/responsive_util.dart';
import '../../../../utils/formatter_util.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/order_entity.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';
import '../widgets/order_status_badge.dart';
import '../widgets/order_item_card.dart';
import '../widgets/order_timeline.dart';
import '../widgets/order_status_management_widget.dart';
import '../widgets/order_notes_widget.dart';

class OrderDetailsScreenClean extends StatelessWidget {
  final String orderId;
  final String userId;
  const OrderDetailsScreenClean({
    Key? key,
    required this.orderId,
    required this.userId,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<OrderBloc>()..add(GetOrderByIdEvent(orderId)),
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            if (state is OrderLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is OrderLoaded) {
              return _buildOrderDetails(context, state.order);
            } else if (state is OrderError) {
              return _buildErrorWidget(context, state.message);
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            if (state is OrderLoaded && state.order.canBeCancelled) {
              return FloatingActionButton.extended(
                onPressed: () => _showCancelDialog(context, state.order),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel Order'),
                backgroundColor: Colors.red,
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Order Details'),
      actions: [
        BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            if (state is OrderLoaded) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) =>
                    _handleMenuAction(context, value, state.order),
                itemBuilder: (context) => [
                  if (state.order.trackingNumber != null)
                    const PopupMenuItem(
                      value: 'copy_tracking',
                      child: Row(
                        children: [
                          Icon(Icons.copy),
                          SizedBox(width: 8),
                          Text('Copy Tracking Number'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'copy_order_id',
                    child: Row(
                      children: [
                        Icon(Icons.copy),
                        SizedBox(width: 8),
                        Text('Copy Order ID'),
                      ],
                    ),
                  ),
                  if (state.order.status == OrderStatus.delivered)
                    const PopupMenuItem(
                      value: 'report_issue',
                      child: Row(
                        children: [
                          Icon(Icons.report_problem),
                          SizedBox(width: 8),
                          Text('Report Issue'),
                        ],
                      ),
                    ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildOrderDetails(BuildContext context, OrderEntity order) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrderBloc>().add(GetOrderByIdEvent(orderId));
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveUtil.spacing(
          mobile: 16,
          tablet: 20,
          desktop: 24,
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(context, order),
            SizedBox(
                height: ResponsiveUtil.spacing(
                    mobile: 16, tablet: 20, desktop: 24)),
            _buildOrderTimeline(order),
            SizedBox(
                height: ResponsiveUtil.spacing(
                    mobile: 16, tablet: 20, desktop: 24)),
            _buildOrderItems(context, order),
            SizedBox(
                height: ResponsiveUtil.spacing(
                    mobile: 16, tablet: 20, desktop: 24)),
            _buildShippingInfo(context, order),
            SizedBox(
                height: ResponsiveUtil.spacing(
                    mobile: 16, tablet: 20, desktop: 24)),
            _buildPaymentInfo(context, order),
            if (order.notes?.isNotEmpty == true) ...[
              SizedBox(
                  height: ResponsiveUtil.spacing(
                      mobile: 16, tablet: 20, desktop: 24)),
              _buildOrderNotes(context, order),
            ],
            SizedBox(
                height: ResponsiveUtil.spacing(
                    mobile: 16, tablet: 20, desktop: 24)),
            _buildAdminControls(context, order),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader(BuildContext context, OrderEntity order) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(
            ResponsiveUtil.spacing(mobile: 16, tablet: 20, desktop: 24)),
        child: Column(
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
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Placed on ${FormatterUtil.formatDate(order.orderDate)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color
                              ?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                OrderStatusBadge(status: order.status),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Amount', style: theme.textTheme.titleMedium),
                Text(
                  FormatterUtil.formatCurrency(order.total),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
            if (order.trackingNumber != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.local_shipping,
                      size: 16,
                      color:
                          theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
                  const SizedBox(width: 8),
                  Text('Tracking: ${order.trackingNumber}',
                      style: theme.textTheme.bodyMedium),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () =>
                        _copyToClipboard(context, order.trackingNumber!),
                    child:
                        Icon(Icons.copy, size: 16, color: theme.primaryColor),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTimeline(OrderEntity order) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(
            ResponsiveUtil.spacing(mobile: 16, tablet: 20, desktop: 24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Progress',
              style: AppTextTheme
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            OrderTimeline(order: order),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems(BuildContext context, OrderEntity order) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(
            ResponsiveUtil.spacing(mobile: 16, tablet: 20, desktop: 24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Items (${order.items.length})',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OrderItemCard(item: item, showActions: false),
                )),
            const Divider(),
            _buildOrderSummary(context, order),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, OrderEntity order) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Subtotal:', style: theme.textTheme.bodyMedium),
            Text(FormatterUtil.formatCurrency(order.subtotal),
                style: theme.textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Shipping:', style: theme.textTheme.bodyMedium),
            Text(FormatterUtil.formatCurrency(order.shippingCost),
                style: theme.textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tax:', style: theme.textTheme.bodyMedium),
            Text(FormatterUtil.formatCurrency(order.tax),
                style: theme.textTheme.bodyMedium),
          ],
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total:',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Text(
              FormatterUtil.formatCurrency(order.total),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShippingInfo(BuildContext context, OrderEntity order) {
    final theme = Theme.of(context);
    final address = order.shippingAddress;
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(
            ResponsiveUtil.spacing(mobile: 16, tablet: 20, desktop: 24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shipping Address',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(address.fullName),
            Text(address.address),
            if (address.apartment?.isNotEmpty == true) Text(address.apartment!),
            Text('${address.city}, ${address.state} ${address.postalCode}'),
            Text(address.country),
            if (address.phoneNumber?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text('Phone: ${address.phoneNumber}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo(BuildContext context, OrderEntity order) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(
            ResponsiveUtil.spacing(mobile: 16, tablet: 20, desktop: 24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Information',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _getPaymentMethodIcon(order.paymentMethod),
                  size: 20,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Text(_getPaymentMethodName(order.paymentMethod)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _getPaymentStatusIcon(order.paymentStatus),
                  size: 20,
                  color: _getPaymentStatusColor(order.paymentStatus),
                ),
                const SizedBox(width: 8),
                Text(
                  'Payment ${order.paymentStatus.name.toUpperCase()}',
                  style: TextStyle(
                    color: _getPaymentStatusColor(order.paymentStatus),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderNotes(BuildContext context, OrderEntity order) {
    return OrderNotesWidget(order: order);
  }

  Widget _buildAdminControls(BuildContext context, OrderEntity order) {
    return OrderStatusManagementWidget(
      order: order,
      onStatusUpdate: (newStatus) {
        context.read<OrderBloc>().add(UpdateOrderStatusEvent(
              orderId: order.id,
              status: newStatus,
            ));
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error loading order',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () =>
                context.read<OrderBloc>().add(GetOrderByIdEvent(orderId)),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(
      BuildContext context, String action, OrderEntity order) {
    switch (action) {
      case 'copy_tracking':
        if (order.trackingNumber != null) {
          _copyToClipboard(context, order.trackingNumber!);
        }
        break;
      case 'copy_order_id':
        _copyToClipboard(context, order.id);
        break;
      case 'report_issue':
        _showReportIssueDialog(context, order);
        break;
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard: $text'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, OrderEntity order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Text(
          'Are you sure you want to cancel order #${order.orderNumber}?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Order'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<OrderBloc>().add(CancelOrderEvent(order.id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );
  }

  void _showReportIssueDialog(BuildContext context, OrderEntity order) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Report an issue with order #${order.orderNumber}'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Describe the issue',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Issue reported successfully')),
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
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
