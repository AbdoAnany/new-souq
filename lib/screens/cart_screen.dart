import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/widgets/custom_button.dart';
import '../core/widgets/my_app_bar.dart';
import '/core/constants/app_constants.dart';
import 'package:souq/models/cart.dart';
import 'package:souq/providers/cart_provider.dart';
import 'package:souq/screens/checkout_screen.dart';
import '/core/constants/app_constants.dart';
import 'package:souq/utils/formatter_util.dart';
import 'package:souq/utils/responsive_util.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cartAsyncValue = ref.watch(cartProvider);

    return Scaffold(
      appBar: MyAppBar(
        title: const Text(AppStrings.cart),
        actions: [
          if (cartAsyncValue.hasValue &&
              cartAsyncValue.value != null &&
              cartAsyncValue.value!.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                _showClearCartDialog(context, ref);
              },
            ),
        ],
      ),
      body: cartAsyncValue.when(
        data: (cart) {
          if (cart == null || cart.items.isEmpty) {
            return _buildEmptyCart(context);
          }

          return _buildCartContent(context, ref, cart);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
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
                "Error loading cart",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: ResponsiveUtil.fontSize(
                      mobile: 16, tablet: 18, desktop: 20),
                ),
              ),
              SizedBox(height: 8.h),
              TextButton(
                onPressed: () {
                  ref.read(cartProvider.notifier).fetchCart();
                },
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: ResponsiveUtil.iconSize(mobile: 80, tablet: 96, desktop: 112),
            color: theme.dividerColor,
          ),
          SizedBox(height: 16.h),
          Text(
            'Your cart is empty',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize:
                  ResponsiveUtil.fontSize(mobile: 18, tablet: 20, desktop: 22),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add items to start shopping',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
              fontSize:
                  ResponsiveUtil.fontSize(mobile: 14, tablet: 15, desktop: 16),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          CustomButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            text: 'Start Shopping',
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, WidgetRef ref, Cart cart) {
    final theme = Theme.of(context);

    if (cart.items.isEmpty) {
      return _buildEmptyCart(context);
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(
                ResponsiveUtil.spacing(mobile: 16, tablet: 20, desktop: 24)),
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return Dismissible(
                key: Key(item.product.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20.w),
                  color: Colors.red,
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: ResponsiveUtil.iconSize(
                        mobile: 24, tablet: 28, desktop: 32),
                  ),
                ),
                onDismissed: (direction) {
                  ref
                      .read(cartProvider.notifier)
                      .removeFromCart(item.product.id);
                },
                child: Card(
                  margin: EdgeInsets.only(bottom: 16.h),
                  child: Padding(
                    padding: EdgeInsets.all(ResponsiveUtil.spacing(
                        mobile: 8, tablet: 12, desktop: 16)),
                    child: Row(
                      children: [
                        // Product image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: CachedNetworkImage(
                            imageUrl: item.product.images.first,
                            width: ResponsiveUtil.spacing(
                                mobile: 80, tablet: 96, desktop: 112),
                            height: ResponsiveUtil.spacing(
                                mobile: 80, tablet: 96, desktop: 112),
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.error,
                              color: Colors.red,
                              size: ResponsiveUtil.iconSize(
                                  mobile: 24, tablet: 28, desktop: 32),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        // Product details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontSize: ResponsiveUtil.fontSize(
                                      mobile: 14, tablet: 16, desktop: 18),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                FormatterUtil.formatCurrency(
                                    item.product.price),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.primaryColor,
                                  fontSize: ResponsiveUtil.fontSize(
                                      mobile: 16, tablet: 18, desktop: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Quantity controls
                        Row(
                          children: [
                            IconButton(
                              onPressed: item.quantity > 1
                                  ? () => ref
                                      .read(cartProvider.notifier)
                                      .updateQuantity(
                                          item.product.id, item.quantity - 1)
                                  : null,
                              icon: Icon(
                                Icons.remove,
                                size: ResponsiveUtil.iconSize(
                                    mobile: 20, tablet: 24, desktop: 28),
                              ),
                              color: theme.primaryColor,
                            ),
                            Text(
                              item.quantity.toString(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: ResponsiveUtil.fontSize(
                                    mobile: 16, tablet: 18, desktop: 20),
                              ),
                            ),
                            IconButton(
                              onPressed: () => ref
                                  .read(cartProvider.notifier)
                                  .updateQuantity(
                                      item.product.id, item.quantity + 1),
                              icon: Icon(
                                Icons.add,
                                size: ResponsiveUtil.iconSize(
                                    mobile: 20, tablet: 24, desktop: 28),
                              ),
                              color: theme.primaryColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Cart summary and checkout button
        Container(
          padding: EdgeInsets.all(
              ResponsiveUtil.spacing(mobile: 16, tablet: 20, desktop: 24)),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10.r,
                offset: Offset(0, -5.h),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtotal',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: ResponsiveUtil.fontSize(
                            mobile: 16, tablet: 18, desktop: 20),
                      ),
                    ),
                    Text(
                      FormatterUtil.formatCurrency(cart.subtotal),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: ResponsiveUtil.fontSize(
                            mobile: 16, tablet: 18, desktop: 20),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Shipping',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: ResponsiveUtil.fontSize(
                            mobile: 16, tablet: 18, desktop: 20),
                      ),
                    ),
                    Text(
                      FormatterUtil.formatCurrency(cart.shipping),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: ResponsiveUtil.fontSize(
                            mobile: 16, tablet: 18, desktop: 20),
                      ),
                    ),
                  ],
                ),
                Divider(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: ResponsiveUtil.fontSize(
                            mobile: 20, tablet: 22, desktop: 24),
                      ),
                    ),
                    Text(
                      FormatterUtil.formatCurrency(cart.total),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.primaryColor,
                        fontSize: ResponsiveUtil.fontSize(
                            mobile: 20, tablet: 22, desktop: 24),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                CustomButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CheckoutScreen(),
                      ),
                    );
                  },
                  text: 'Proceed to Checkout',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showClearCartDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Cart'),
          content: const Text('Are you sure you want to clear your cart?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(cartProvider.notifier).clearCart();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
}
