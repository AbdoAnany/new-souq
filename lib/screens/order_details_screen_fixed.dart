import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:souq/core/constants/app_constants.dart';
import 'package:souq/models/cart.dart';
import 'package:souq/models/order.dart';
import 'package:souq/providers/order_provider.dart';
import 'package:souq/screens/product_details_screen.dart';
import 'package:souq/services/tracking_service.dart';
import 'package:souq/utils/formatter_util.dart';
import 'package:souq/core/widgets/custom_button.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../core/widgets/my_app_bar.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final String orderId;
  
  const OrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final orderStream = ref.watch(orderStreamProvider(orderId));
    
    return Scaffold(
      appBar: MyAppBar(
        title: const Text('Order Details'),
      ),
      body: orderStream.when(
        data: (order) {
          if (order == null) {
            return Center(
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
                    'Order not found',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }
          
          // Get tracking events manually
          final trackingService = TrackingService();
          final trackingEvents = trackingService.generateTrackingEvents(order);
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order summary card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
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
                            ),
                          ),
                          _buildStatusChip(context, order.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Placed on ${FormatterUtil.formatDateTime(order.createdAt)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                      if (order.shippedAt != null)
                        Text(
                          'Shipped on ${FormatterUtil.formatDateTime(order.shippedAt!)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppConstants.textSecondaryColor,
                          ),
                        ),
                      if (order.deliveredAt != null)
                        Text(
                          'Delivered on ${FormatterUtil.formatDateTime(order.deliveredAt!)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppConstants.textSecondaryColor,
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Tracking timeline
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Tracking',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
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
                              width: 20,
                              height: 20,
                              indicator: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: event.isCompleted ? theme.primaryColor : Colors.grey[300] ?? Colors.grey,
                                ),
                                child: event.isCompleted
                                    ? const Icon(Icons.check, color: Colors.white, size: 12)
                                    : null,
                              ),
                            ),
                            beforeLineStyle: LineStyle(
                              color: event.isCompleted ? theme.primaryColor : Colors.grey[300] ?? Colors.grey,
                            ),
                            endChild: Padding(
                              padding: const EdgeInsets.only(left: 16, bottom: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        event.status,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        FormatterUtil.formatDateTime(event.timestamp),
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: AppConstants.textSecondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    event.description,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppConstants.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      if (order.trackingNumber != null && order.status.index >= OrderStatus.shipped.index) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              'Tracking Number: ',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                order.trackingNumber!,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Order items
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          '${order.items.length} ${order.items.length == 1 ? 'Item' : 'Items'}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      
                      // Product list
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: order.items.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(item.image??''),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            title: Text(
                              item.title,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item.quantity} × ${FormatterUtil.formatCurrency(item.price)}',
                                  style: theme.textTheme.bodySmall,
                                ),
                                if (item.customizations != null && item.customizations!.isNotEmpty)
                                  Text(
                                    item.customizations!.entries
                                        .map((e) => "${e.key}: ${e.value}")
                                        .join(", "),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppConstants.textSecondaryColor,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Text(
                              FormatterUtil.formatCurrency(item.total),
                              style: theme.textTheme.titleSmall,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Price details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price Details',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPriceRow(context, 'Subtotal', FormatterUtil.formatCurrency(order.subtotal)),
                      _buildPriceRow(context, 'Shipping', order.shipping > 0 
                          ? FormatterUtil.formatCurrency(order.shipping) 
                          : 'Free', isGreen: order.shipping == 0),
                      _buildPriceRow(context, 'Tax', FormatterUtil.formatCurrency(order.tax)),
                      const Divider(height: 16),
                      _buildPriceRow(
                        context, 
                        'Total', 
                        FormatterUtil.formatCurrency(order.total),
                        isBold: true,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Shipping & Payment Info
                Row(
                  children: [
                    // Shipping address
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ship To',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${order.shippingAddress.firstName} ${order.shippingAddress.lastName}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              order.shippingAddress.addressLine1,
                              style: theme.textTheme.bodyMedium,
                            ),
                            if (order.shippingAddress.addressLine2 != null && order.shippingAddress.addressLine2!.isNotEmpty)
                              Text(
                                order.shippingAddress.addressLine2!,
                                style: theme.textTheme.bodyMedium,
                              ),
                            Text(
                              '${order.shippingAddress.city}, ${order.shippingAddress.state} ${order.shippingAddress.postalCode}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              order.shippingAddress.country ??'',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Payment method
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Method',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _getPaymentIcon(order.paymentMethod),
                                const SizedBox(width: 8),
                                Text(
                                  _getPaymentMethodDisplayName(order.paymentMethod),
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Action buttons
                if (order.canBeCancelled)
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Cancel Order',
                      isOutlined: true,
                      textColor: Colors.red,
                   //   borderColor: Colors.red,
                      onPressed: () => _showCancelDialog(context, ref, order),
                    ),
                  ),
                
                const SizedBox(height: 16),
                
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
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading order details',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
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
      default:
        return method.toString().split('.').last;
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
      default:
        chipColor = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusDisplayName(status),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
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
      default:
        return status.toString().split('.').last;
    }
  }
  
  Widget _buildPriceRow(BuildContext context, String label, String value, {bool isBold = false, bool isGreen = false}) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : null,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : null,
              color: isGreen ? Colors.green : null,
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
    
    return Icon(iconData, size: 20);
  }
  
  void _showCancelDialog(BuildContext context, WidgetRef ref, OrderModel order) {
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
