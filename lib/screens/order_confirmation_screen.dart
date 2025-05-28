import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:souq/constants/app_constants.dart';
import 'package:souq/models/cart.dart';
import 'package:souq/models/order.dart';
import 'package:souq/providers/order_provider.dart';
import 'package:souq/screens/order_history_screen.dart';
import 'package:souq/utils/formatter_util.dart';
import 'package:souq/widgets/custom_button.dart';
import 'package:lottie/lottie.dart';

class OrderConfirmationScreen extends ConsumerWidget {
  final String orderId;
  
  const OrderConfirmationScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final orderStream = ref.watch(orderStreamProvider(orderId));
    
    return WillPopScope(
      onWillPop: () async {
        _navigateToHome(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order Confirmation'),
          automaticallyImplyLeading: false,
        ),
        body: orderStream.when(
          data: (order) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Success animation
                  Lottie.asset(
                    'assets/animations/order_success.json',
                    width: 200,
                    height: 200,
                    repeat: false,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Thank you message
                  Text(
                    'Thank you for your order!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  Text(
                    'Your order has been placed successfully.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Order details
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
                        _buildInfoRow(
                          context, 
                          'Order Number:', 
                          order.orderNumber,
                          isBold: true,
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(context, 'Order Date:', FormatterUtil.formatDateTime(order.createdAt)),
                        _buildInfoRow(context, 'Payment Method:', order.paymentMethod.displayName),
                        _buildInfoRow(context, 'Status:', order.status.name, 
                          valueColor: _getStatusColor(order.status, theme),
                        ),
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
                            'Order Summary',
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
                              subtitle: Text(
                                '${item.quantity} × ${FormatterUtil.formatCurrency(item.price)}',
                                style: theme.textTheme.bodySmall,
                              ),
                              trailing: Text(
                                FormatterUtil.formatCurrency(item.total),
                                style: theme.textTheme.titleSmall,
                              ),
                            );
                          },
                        ),
                        
                        const Divider(height: 1),
                        
                        // Price details
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
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
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Shipping address
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
                          'Shipping Address',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${order.shippingAddress.firstName} ${order.shippingAddress.lastName}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.shippingAddress.addressLine1,
                          style: theme.textTheme.bodyMedium,
                        ),
                        if (order.shippingAddress.addressLine2 != null)
                          Text(
                            order.shippingAddress.addressLine2!,
                            style: theme.textTheme.bodyMedium,
                          ),
                        Text(
                          '${order.shippingAddress.city}, ${order.shippingAddress.state} ${order.shippingAddress.postalCode}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          order.shippingAddress.country ?? '',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Action buttons
                  Column(
                    children: [
                      CustomButton(
                        text: 'Track Order',
                        icon: Icons.local_shipping_outlined,
                        onPressed: () {
                          // Navigate to order tracking screen
                          // This could be implemented in a future enhancement
                        },
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        text: 'View My Orders',
                        isOutlined: true,
                        onPressed: () => _navigateToOrderHistory(context),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => _navigateToHome(context),
                        child: const Text('Continue Shopping'),
                      ),
                    ],
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
                  onPressed: () => _navigateToHome(context),
                  child: const Text('Return to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(BuildContext context, String label, String value, {bool isBold = false, Color? valueColor}) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppConstants.textSecondaryColor,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isBold ? FontWeight.bold : null,
                color: valueColor,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
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
  
  Color _getStatusColor(OrderStatus status, ThemeData theme) {
    switch (status) {
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.orange;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      default:
        return theme.textTheme.bodyMedium!.color!;
    }
  }
  
  void _navigateToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
  
  void _navigateToOrderHistory(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const OrderHistoryScreen(),
      ),
    );
  }
}
