import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:souq/constants/app_constants.dart';
import 'package:souq/models/cart.dart'; // Import for PaymentMethod
import 'package:souq/models/order.dart';
import 'package:souq/providers/order_provider.dart';
import 'package:souq/screens/product_details_screen.dart';
import 'package:souq/services/tracking_service.dart';
import 'package:souq/utils/formatter_util.dart';
import 'package:souq/utils/responsive_util.dart';
import 'package:souq/widgets/custom_button.dart';
import 'package:timeline_tile/timeline_tile.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailsScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final orderStreamAsync = ref.watch(orderStreamProvider(orderId));

    // Get the order stream
    final orderStream = orderStreamAsync;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: orderStream.when(
        data: (order) {
          // Get tracking events manually
          final trackingService = TrackingService();
          final trackingEvents = trackingService.generateTrackingEvents(order);

          return SingleChildScrollView(
            padding: EdgeInsets.all(
                ResponsiveUtil.spacing(mobile: 16, tablet: 20, desktop: 24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order summary card
                Container(
                  padding: EdgeInsets.all(ResponsiveUtil.spacing(
                      mobile: 16, tablet: 18, desktop: 20)),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadiusMedium),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order #${order.orderNumber}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveUtil.fontSize(
                                  mobile: 18, tablet: 20, desktop: 22),
                            ),
                          ),
                          _buildStatusChip(context, order.status),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Placed on ${FormatterUtil.formatDateTime(order.createdAt)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppConstants.textSecondaryColor,
                          fontSize: ResponsiveUtil.fontSize(
                              mobile: 14, tablet: 15, desktop: 16),
                        ),
                      ),
                      if (order.shippedAt != null)
                        Text(
                          'Shipped on ${FormatterUtil.formatDateTime(order.shippedAt!)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppConstants.textSecondaryColor,
                            fontSize: ResponsiveUtil.fontSize(
                                mobile: 14, tablet: 15, desktop: 16),
                          ),
                        ),
                      if (order.deliveredAt != null)
                        Text(
                          'Delivered on ${FormatterUtil.formatDateTime(order.deliveredAt!)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppConstants.textSecondaryColor,
                            fontSize: ResponsiveUtil.fontSize(
                                mobile: 14, tablet: 15, desktop: 16),
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Tracking timeline
                Container(
                  padding: EdgeInsets.all(ResponsiveUtil.spacing(
                      mobile: 16, tablet: 18, desktop: 20)),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadiusMedium),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Tracking',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveUtil.fontSize(
                              mobile: 18, tablet: 20, desktop: 22),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Column(
                        children: trackingEvents.asMap().entries.map((entry) {
                          final index = entry.key;
                          final event = entry.value;
                          final isFirst = index == 0;
                          final isLast = index == trackingEvents.length - 1;

                          return TimelineTile(
                            alignment: TimelineAlign.start,
                            isFirst: isFirst,
                            isLast: isLast,
                            indicatorStyle: IndicatorStyle(
                              width: ResponsiveUtil.spacing(
                                  mobile: 20, tablet: 24, desktop: 28),
                              height: ResponsiveUtil.spacing(
                                  mobile: 20, tablet: 24, desktop: 28),
                              indicator: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: event.isCompleted
                                      ? theme.primaryColor
                                      : Colors.grey[300] ?? Colors.grey,
                                ),
                                child: event.isCompleted
                                    ? Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: ResponsiveUtil.iconSize(
                                            mobile: 12,
                                            tablet: 14,
                                            desktop: 16),
                                      )
                                    : null,
                              ),
                            ),
                            beforeLineStyle: LineStyle(
                              color: event.isCompleted
                                  ? theme.primaryColor
                                  : Colors.grey[300] ?? Colors.grey,
                            ),
                            endChild: Padding(
                              padding:
                                  EdgeInsets.only(left: 16.w, bottom: 24.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        event.status,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: ResponsiveUtil.fontSize(
                                              mobile: 14,
                                              tablet: 15,
                                              desktop: 16),
                                        ),
                                      ),
                                      Text(
                                        FormatterUtil.formatDateTime(
                                            event.timestamp),
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color:
                                              AppConstants.textSecondaryColor,
                                          fontSize: ResponsiveUtil.fontSize(
                                              mobile: 12,
                                              tablet: 13,
                                              desktop: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    event.description,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppConstants.textSecondaryColor,
                                      fontSize: ResponsiveUtil.fontSize(
                                          mobile: 12, tablet: 13, desktop: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      if (order.trackingNumber != null &&
                          order.status.index >= OrderStatus.shipped.index) ...[
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Text(
                              'Tracking Number: ',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: ResponsiveUtil.fontSize(
                                    mobile: 14, tablet: 15, desktop: 16),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                order.trackingNumber!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: ResponsiveUtil.fontSize(
                                      mobile: 14, tablet: 15, desktop: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Order items
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadiusMedium),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(ResponsiveUtil.spacing(
                            mobile: 16, tablet: 18, desktop: 20)),
                        child: Text(
                          '${order.items.length} ${order.items.length == 1 ? 'Item' : 'Items'}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveUtil.fontSize(
                                mobile: 18, tablet: 20, desktop: 22),
                          ),
                        ),
                      ),
                      Divider(height: 1.h),

                      // Product list
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: order.items.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = order.items[index];
                          return ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailsScreen(
                                    productId: item.productId,
                                  ),
                                ),
                              );
                            },
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: ResponsiveUtil.spacing(
                                  mobile: 16, tablet: 18, desktop: 20),
                              vertical: 8.h,
                            ),
                            leading: Container(
                              width: ResponsiveUtil.spacing(
                                  mobile: 60, tablet: 70, desktop: 80),
                              height: ResponsiveUtil.spacing(
                                  mobile: 60, tablet: 70, desktop: 80),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.r),
                                image: item.image != null
                                    ? DecorationImage(
                                        image: NetworkImage(item.image!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                                color: item.image == null
                                    ? Colors.grey[200]
                                    : null,
                              ),
                              child: item.image == null
                                  ? Icon(
                                      Icons.image,
                                      color: Colors.grey,
                                      size: ResponsiveUtil.iconSize(
                                          mobile: 24, tablet: 28, desktop: 32),
                                    )
                                  : null,
                            ),
                            title: Text(
                              item.title,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: ResponsiveUtil.fontSize(
                                    mobile: 14, tablet: 16, desktop: 18),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item.quantity} × ${FormatterUtil.formatCurrency(item.price)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: ResponsiveUtil.fontSize(
                                        mobile: 12, tablet: 13, desktop: 14),
                                  ),
                                ),
                                if (item.customizations != null &&
                                    item.customizations!.isNotEmpty)
                                  Text(
                                    item.customizations!.entries
                                        .map((e) => "${e.key}: ${e.value}")
                                        .join(", "),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppConstants.textSecondaryColor,
                                      fontSize: ResponsiveUtil.fontSize(
                                          mobile: 12, tablet: 13, desktop: 14),
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Text(
                              FormatterUtil.formatCurrency(item.total),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontSize: ResponsiveUtil.fontSize(
                                    mobile: 14, tablet: 15, desktop: 16),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Price details
                Container(
                  padding: EdgeInsets.all(ResponsiveUtil.spacing(
                      mobile: 16, tablet: 18, desktop: 20)),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadiusMedium),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price Details',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveUtil.fontSize(
                              mobile: 18, tablet: 20, desktop: 22),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _buildPriceRow(context, 'Subtotal',
                          FormatterUtil.formatCurrency(order.subtotal)),
                      _buildPriceRow(
                          context,
                          'Shipping',
                          order.shipping > 0
                              ? FormatterUtil.formatCurrency(order.shipping)
                              : 'Free',
                          isGreen: order.shipping == 0),
                      _buildPriceRow(context, 'Tax',
                          FormatterUtil.formatCurrency(order.tax)),
                      Divider(height: 16.h),
                      _buildPriceRow(
                        context,
                        'Total',
                        FormatterUtil.formatCurrency(order.total),
                        isBold: true,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Shipping & Payment Info
                Row(
                  children: [
                    // Shipping address
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(ResponsiveUtil.spacing(
                            mobile: 16, tablet: 18, desktop: 20)),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusMedium),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ship To',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: ResponsiveUtil.fontSize(
                                    mobile: 16, tablet: 18, desktop: 20),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              order.shippingAddress.title,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: ResponsiveUtil.fontSize(
                                    mobile: 14, tablet: 15, desktop: 16),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              order.shippingAddress.street,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: ResponsiveUtil.fontSize(
                                    mobile: 14, tablet: 15, desktop: 16),
                              ),
                            ),
                            Text(
                              '${order.shippingAddress.city}, ${order.shippingAddress.state} ${order.shippingAddress.postalCode}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: ResponsiveUtil.fontSize(
                                    mobile: 14, tablet: 15, desktop: 16),
                              ),
                            ),
                            Text(
                              order.shippingAddress.country,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: ResponsiveUtil.fontSize(
                                    mobile: 14, tablet: 15, desktop: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(width: 16.w),

                    // Payment method
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(ResponsiveUtil.spacing(
                            mobile: 16, tablet: 18, desktop: 20)),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusMedium),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Method',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: ResponsiveUtil.fontSize(
                                    mobile: 16, tablet: 18, desktop: 20),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                _getPaymentIcon(order.paymentMethod),
                                SizedBox(width: 8.w),
                                Text(
                                  _getPaymentMethodDisplayName(
                                      order.paymentMethod),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: ResponsiveUtil.fontSize(
                                        mobile: 14, tablet: 15, desktop: 16),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                // Action buttons
                if (order.canBeCancelled)
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Cancel Order',
                      isOutlined: true,
                      textColor: Colors.red,
                      onPressed: () => _showCancelDialog(context, ref, order),
                    ),
                  ),

                SizedBox(height: 16.h),

                if (order.status == OrderStatus.delivered)
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Buy Again',
                      onPressed: () {
                        // Implement buy again functionality
                        // This would re-add all items to the cart
                      },
                    ),
                  ),
              ],
            ),
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
              SizedBox(height: 16.h),
              Text(
                'Error loading order details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: ResponsiveUtil.fontSize(
                      mobile: 16, tablet: 18, desktop: 20),
                ),
              ),
              SizedBox(height: 8.h),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPaymentMethodDisplayName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cashOnDelivery:
        return 'Cash on Delivery';
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.stripe:
        return 'Stripe';
      case PaymentMethod.unknown:
        return 'Unknown';
    }
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
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        _getStatusDisplayName(status),
        style: TextStyle(
          color: textColor,
          fontSize:
              ResponsiveUtil.fontSize(mobile: 12, tablet: 13, desktop: 14),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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

  Widget _buildPriceRow(BuildContext context, String label, String value,
      {bool isBold = false, bool isGreen = false}) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : null,
              fontSize:
                  ResponsiveUtil.fontSize(mobile: 14, tablet: 15, desktop: 16),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : null,
              color: isGreen ? Colors.green : null,
              fontSize:
                  ResponsiveUtil.fontSize(mobile: 14, tablet: 15, desktop: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getPaymentIcon(PaymentMethod paymentMethod) {
    IconData iconData;

    switch (paymentMethod) {
      case PaymentMethod.cashOnDelivery:
        iconData = Icons.payments_outlined;
        break;
      case PaymentMethod.creditCard:
        iconData = Icons.credit_card;
        break;
      case PaymentMethod.paypal:
        iconData = Icons.account_balance_wallet_outlined;
        break;
      case PaymentMethod.stripe:
        iconData = Icons.credit_card;
        break;
      default:
        iconData = Icons.payment;
    }

    return Icon(
      iconData,
      size: ResponsiveUtil.iconSize(mobile: 20, tablet: 22, desktop: 24),
    );
  }

  void _showCancelDialog(
      BuildContext context, WidgetRef ref, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Order"),
        content: Text(
            "Are you sure you want to cancel order #${order.orderNumber}?\n\nThis action cannot be undone."),
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
