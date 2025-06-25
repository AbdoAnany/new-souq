import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../utils/formatter_util.dart';
import '../../../../utils/responsive_util.dart';
import '../../domain/entities/order_entity.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';
import '../widgets/order_item_card.dart';
import '../widgets/order_status_badge.dart';
import '../widgets/order_timeline.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;
  final String userId;

  const OrderDetailsScreen({
    Key? key,
    required this.orderId,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<OrderBloc>()..add(GetOrderByIdEvent(orderId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order Details'),
          actions: [
            BlocBuilder<OrderBloc, OrderState>(
              builder: (context, state) {
                if (state is OrderLoaded && state.order.canBeCancelled) {
                  return IconButton(
                    icon: const Icon(Icons.cancel_outlined),
                    onPressed: () => _showCancelDialog(context, state.order),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
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
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context, OrderEntity order) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtil.spacing(
        mobile: 16,
        tablet: 20,
        desktop: 24,
      )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order summary card
          _buildOrderSummaryCard(context, order),
          SizedBox(height: 16.h),

          // Order timeline
          _buildTimelineCard(context, order),
          SizedBox(height: 16.h),

          // Order items
          _buildOrderItemsCard(context, order),
          SizedBox(height: 16.h),

          // Shipping address
          _buildShippingAddressCard(context, order),
          SizedBox(height: 16.h),

          // Payment summary
          _buildPaymentSummaryCard(context, order),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(BuildContext context, OrderEntity order) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtil.spacing(
          mobile: 16,
          tablet: 18,
          desktop: 20,
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Order #${order.orderNumber}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                OrderStatusBadge(status: order.status),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'Placed on ${FormatterUtil.formatDateTime(order.orderDate)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '${order.totalItems} items • ${FormatterUtil.formatCurrency(order.total)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            if (order.trackingNumber != null) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.local_shipping, size: 16.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Tracking: ${order.trackingNumber}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context, OrderEntity order) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtil.spacing(
          mobile: 16,
          tablet: 18,
          desktop: 20,
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Timeline',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 16.h),
            OrderTimeline(order: order),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsCard(BuildContext context, OrderEntity order) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtil.spacing(
          mobile: 16,
          tablet: 18,
          desktop: 20,
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Items',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 16.h),
            ...order.items.map((item) => OrderItemCard(item: item)),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingAddressCard(BuildContext context, OrderEntity order) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtil.spacing(
          mobile: 16,
          tablet: 18,
          desktop: 20,
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shipping Address',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              order.shippingAddress.fullName,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              order.shippingAddress.address,
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              '${order.shippingAddress.city}, ${order.shippingAddress.state}',
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              '${order.shippingAddress.country} ${order.shippingAddress.postalCode}',
              style: theme.textTheme.bodyMedium,
            ),
            if (order.shippingAddress.phoneNumber != null) ...[
              SizedBox(height: 4.h),
              Text(
                order.shippingAddress.phoneNumber!,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummaryCard(BuildContext context, OrderEntity order) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtil.spacing(
          mobile: 16,
          tablet: 18,
          desktop: 20,
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Summary',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            _buildPriceRow('Subtotal', order.subtotal),
            _buildPriceRow('Shipping', order.shipping),
            _buildPriceRow('Tax', order.tax),
            const Divider(),
            _buildPriceRow(
              'Total',
              order.total,
              isTotal: true,
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(
                  _getPaymentMethodIcon(order.paymentMethod),
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  _getPaymentMethodText(order.paymentMethod),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16.sp : 14.sp,
            ),
          ),
          Text(
            FormatterUtil.formatCurrency(amount),
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16.sp : 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: ResponsiveUtil.iconSize(
              mobile: 64,
              tablet: 72,
              desktop: 80,
            ),
            color: Colors.red,
          ),
          SizedBox(height: 16.h),
          Text(
            'Error',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              context.read<OrderBloc>().add(GetOrderByIdEvent(orderId));
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, OrderEntity order) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Text(
          'Are you sure you want to cancel order #${order.orderNumber}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<OrderBloc>().add(CancelOrderEvent(order.id));
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return Icons.credit_card;
      case PaymentMethod.paypal:
        return Icons.account_balance_wallet;
      case PaymentMethod.stripe:
        return Icons.payment;
      case PaymentMethod.cashOnDelivery:
        return Icons.money;
      case PaymentMethod.unknown:
        return Icons.payment;
      case PaymentMethod.debitCard:
        // TODO: Handle this case.
        throw UnimplementedError();
      case PaymentMethod.bankTransfer:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  String _getPaymentMethodText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.stripe:
        return 'Stripe';
      case PaymentMethod.cashOnDelivery:
        return 'Cash on Delivery';
      case PaymentMethod.unknown:
        return 'Unknown';
      case PaymentMethod.debitCard:
        // TODO: Handle this case.
        throw UnimplementedError();
      case PaymentMethod.bankTransfer:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}
