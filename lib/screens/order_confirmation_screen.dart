import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/widgets/custom_button.dart';
import '../core/widgets/my_app_bar.dart';
import '/core/constants/app_constants.dart';
import 'package:souq/models/cart.dart';
import 'package:souq/models/order.dart';
import 'package:souq/providers/order_provider.dart';
import 'package:souq/screens/order_history_screen.dart';
import 'package:souq/utils/formatter_util.dart';
import '/core/constants/app_constants.dart';
// import 'package:lottie/lottie.dart';
import '../utils/responsive_util.dart';

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
        appBar: MyAppBar(
          title: Text(
            'Order Confirmation',
            style: TextStyle(
              fontSize: ResponsiveUtil.fontSize(
                mobile: 18,
                tablet: 20,
                desktop: 22,
              ),
            ),
          ),
          automaticallyImplyLeading: false,
        ),
        body: orderStream.when(
          data: (order) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(ResponsiveUtil.spacing(
                mobile: 16,
                tablet: 20,
                desktop: 24,
              )),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Success animation
                  // Lottie.asset(
                  //   'assets/animations/order_success.json',
                  //   width: ResponsiveUtil.spacing(
                  //     mobile: 200,
                  //     tablet: 240,
                  //     desktop: 280,
                  //   ),
                  //   height: ResponsiveUtil.spacing(
                  //     mobile: 200,
                  //     tablet: 240,
                  //     desktop: 280,
                  //   ),
                  //   repeat: false,
                  // ),

                  SizedBox(
                      height: ResponsiveUtil.spacing(
                    mobile: 16,
                    tablet: 20,
                    desktop: 24,
                  )),

                  // Thank you message
                  Text(
                    'Thank you for your order!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveUtil.fontSize(
                        mobile: 24,
                        tablet: 28,
                        desktop: 32,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(
                      height: ResponsiveUtil.spacing(
                    mobile: 8,
                    tablet: 10,
                    desktop: 12,
                  )),
                  Text(
                    'Your order has been placed successfully.',
                    style: theme.textTheme.bodyMedium?.copyWith(
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
                    mobile: 24,
                    tablet: 28,
                    desktop: 32,
                  )),

                  // Order details
                  Container(
                    padding: EdgeInsets.all(ResponsiveUtil.spacing(
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    )),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusMedium),
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
                        Divider(
                            height: ResponsiveUtil.spacing(
                          mobile: 24,
                          tablet: 26,
                          desktop: 28,
                        )),
                        _buildInfoRow(context, 'Order Date:',
                            FormatterUtil.formatDateTime(order.createdAt)),
                        _buildInfoRow(context, 'Payment Method:',
                            order.paymentMethod.displayName),
                        _buildInfoRow(
                          context,
                          'Status:',
                          order.status.name,
                          valueColor: _getStatusColor(order.status, theme),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                      height: ResponsiveUtil.spacing(
                    mobile: 16,
                    tablet: 18,
                    desktop: 20,
                  )),

                  // Order items
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusMedium),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(ResponsiveUtil.spacing(
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
                          )),
                          child: Text(
                            'Order Summary',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveUtil.fontSize(
                                mobile: 16,
                                tablet: 17,
                                desktop: 18,
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1),

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
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: ResponsiveUtil.spacing(
                                  mobile: 16,
                                  tablet: 18,
                                  desktop: 20,
                                ),
                                vertical: ResponsiveUtil.spacing(
                                  mobile: 8,
                                  tablet: 10,
                                  desktop: 12,
                                ),
                              ),
                              leading: Container(
                                width: ResponsiveUtil.spacing(
                                  mobile: 60,
                                  tablet: 66,
                                  desktop: 72,
                                ),
                                height: ResponsiveUtil.spacing(
                                  mobile: 60,
                                  tablet: 66,
                                  desktop: 72,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(item.image ?? ''),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              title: Text(
                                item.title,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: ResponsiveUtil.fontSize(
                                    mobile: 14,
                                    tablet: 15,
                                    desktop: 16,
                                  ),
                                ),
                              ),
                              subtitle: Text(
                                '${item.quantity} × ${FormatterUtil.formatCurrency(item.price)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: ResponsiveUtil.fontSize(
                                    mobile: 12,
                                    tablet: 13,
                                    desktop: 14,
                                  ),
                                ),
                              ),
                              trailing: Text(
                                FormatterUtil.formatCurrency(item.total),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontSize: ResponsiveUtil.fontSize(
                                    mobile: 14,
                                    tablet: 15,
                                    desktop: 16,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const Divider(height: 1),

                        // Price details
                        Padding(
                          padding: EdgeInsets.all(ResponsiveUtil.spacing(
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
                          )),
                          child: Column(
                            children: [
                              _buildPriceRow(context, 'Subtotal',
                                  FormatterUtil.formatCurrency(order.subtotal)),
                              _buildPriceRow(
                                  context,
                                  'Shipping',
                                  order.shipping > 0
                                      ? FormatterUtil.formatCurrency(
                                          order.shipping)
                                      : 'Free',
                                  isGreen: order.shipping == 0),
                              _buildPriceRow(context, 'Tax',
                                  FormatterUtil.formatCurrency(order.tax)),
                              Divider(
                                  height: ResponsiveUtil.spacing(
                                mobile: 16,
                                tablet: 18,
                                desktop: 20,
                              )),
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

                  SizedBox(
                      height: ResponsiveUtil.spacing(
                    mobile: 24,
                    tablet: 28,
                    desktop: 32,
                  )),

                  // Shipping address
                  Container(
                    padding: EdgeInsets.all(ResponsiveUtil.spacing(
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    )),
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
                          'Shipping Address',
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
                          mobile: 12,
                          tablet: 14,
                          desktop: 16,
                        )),
                        Text(
                          '${order.shippingAddress.firstName} ${order.shippingAddress.lastName}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: ResponsiveUtil.fontSize(
                              mobile: 14,
                              tablet: 15,
                              desktop: 16,
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
                          order.shippingAddress.addressLine1,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: ResponsiveUtil.fontSize(
                              mobile: 14,
                              tablet: 15,
                              desktop: 16,
                            ),
                          ),
                        ),
                        if (order.shippingAddress.addressLine2 != null)
                          Text(
                            order.shippingAddress.addressLine2!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: ResponsiveUtil.fontSize(
                                mobile: 14,
                                tablet: 15,
                                desktop: 16,
                              ),
                            ),
                          ),
                        Text(
                          '${order.shippingAddress.city}, ${order.shippingAddress.state} ${order.shippingAddress.postalCode}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: ResponsiveUtil.fontSize(
                              mobile: 14,
                              tablet: 15,
                              desktop: 16,
                            ),
                          ),
                        ),
                        Text(
                          order.shippingAddress.country,
                          style: theme.textTheme.bodyMedium?.copyWith(
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

                  SizedBox(
                      height: ResponsiveUtil.spacing(
                    mobile: 24,
                    tablet: 28,
                    desktop: 32,
                  )),

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
                      SizedBox(
                          height: ResponsiveUtil.spacing(
                        mobile: 12,
                        tablet: 14,
                        desktop: 16,
                      )),
                      CustomButton(
                        text: 'View My Orders',
                        isOutlined: true,
                        onPressed: () => _navigateToOrderHistory(context),
                      ),
                      SizedBox(
                          height: ResponsiveUtil.spacing(
                        mobile: 12,
                        tablet: 14,
                        desktop: 16,
                      )),
                      TextButton(
                        onPressed: () => _navigateToHome(context),
                        child: Text(
                          'Continue Shopping',
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
                    mobile: 48,
                    tablet: 54,
                    desktop: 60,
                  ),
                  color: Colors.red,
                ),
                SizedBox(
                    height: ResponsiveUtil.spacing(
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                )),
                Text(
                  'Error loading order details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: ResponsiveUtil.fontSize(
                      mobile: 16,
                      tablet: 17,
                      desktop: 18,
                    ),
                  ),
                ),
                SizedBox(
                    height: ResponsiveUtil.spacing(
                  mobile: 8,
                  tablet: 10,
                  desktop: 12,
                )),
                TextButton(
                  onPressed: () => _navigateToHome(context),
                  child: Text(
                    'Return to Home',
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
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value,
      {bool isBold = false, Color? valueColor}) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveUtil.spacing(
          mobile: 4,
          tablet: 5,
          desktop: 6,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppConstants.textSecondaryColor,
              fontSize: ResponsiveUtil.fontSize(
                mobile: 14,
                tablet: 15,
                desktop: 16,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isBold ? FontWeight.bold : null,
                color: valueColor,
                fontSize: ResponsiveUtil.fontSize(
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                ),
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(BuildContext context, String label, String value,
      {bool isBold = false, bool isGreen = false}) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveUtil.spacing(
          mobile: 4,
          tablet: 5,
          desktop: 6,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : null,
              fontSize: ResponsiveUtil.fontSize(
                mobile: 14,
                tablet: 15,
                desktop: 16,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : null,
              color: isGreen ? Colors.green : null,
              fontSize: ResponsiveUtil.fontSize(
                mobile: 14,
                tablet: 15,
                desktop: 16,
              ),
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
