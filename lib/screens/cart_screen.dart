import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:souq/core/constants/app_constants.dart';
import 'package:souq/models/cart.dart';
import 'package:souq/providers/cart_provider.dart';
import 'package:souq/screens/checkout_screen.dart';
import 'package:souq/utils/formatter_util.dart';
import 'package:souq/utils/responsive_util.dart';
import 'package:souq/core/widgets/custom_button.dart';

import '../core/widgets/my_app_bar.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  // Track loading states for UI feedback
  final Map<String, bool> _itemLoadingStates = {};
  bool _isClearing = false;

  // Show a snackbar with a message
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Update quantity with loading state
  Future<void> _updateQuantity(String itemId, int newQuantity) async {
    // Set loading state for this item
    setState(() {
      _itemLoadingStates[itemId] = true;
    });

    try {
      // Call the provider to update quantity
      await ref.read(cartProvider.notifier).updateQuantity(itemId, newQuantity);
    } catch (e) {
      _showSnackBar('Could not update quantity: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _itemLoadingStates[itemId] = false;
        });
      }
    }
  }

  // Remove item
  Future<void> _removeItem(String itemId) async {
    try {
      await ref.read(cartProvider.notifier).removeFromCart(itemId);
      _showSnackBar('Item removed from cart');
    } catch (e) {
      _showSnackBar('Could not remove item: ${e.toString()}', isError: true);
    }
  }

  // Clear cart with confirmation
  Future<void> _clearCart() async {
    setState(() {
      _isClearing = true;
    });

    try {
      await ref.read(cartProvider.notifier).clearCart();
      _showSnackBar('Cart cleared successfully');
    } catch (e) {
      _showSnackBar('Could not clear cart: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isClearing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartAsyncValue = ref.watch(cartProvider);

    return Scaffold(
      appBar: MyAppBar(
        title: const Text('My Cart'),
        actions: [
          if (cartAsyncValue.hasValue &&
              cartAsyncValue.value != null &&
              cartAsyncValue.value!.items.isNotEmpty)
            IconButton(
              icon: _isClearing
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.delete_outline),
              onPressed: _isClearing ? null : () => _showClearCartDialog(context),
            ),
        ],
      ),
      body: cartAsyncValue.when(
        data: (cart) {
          if (cart == null || cart.items.isEmpty) {
            return _buildEmptyCart(context);
          }

          return _buildCartContent(context, cart);
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

  Widget _buildCartContent(BuildContext context, Cart cart) {
    final theme = Theme.of(context);

    if (cart.items.isEmpty) {
      return _buildEmptyCart(context);
    }

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(
                  ResponsiveUtil.spacing(mobile: 16, tablet: 20, desktop: 24)),
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                final bool isLoading = _itemLoadingStates[item.id] == true;

                return Dismissible(
                  key: ValueKey(item.id), // Use ValueKey with item.id
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
                  confirmDismiss: (_) async {
                    // Show confirmation dialog for important items
                    if (item.quantity > 1) {
                      return await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Remove Item'),
                            content: Text('Remove ${item.product.name} from your cart?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Remove'),
                              ),
                            ],
                          );
                        },
                      ) ?? false;
                    }
                    return true;
                  },
                  onDismissed: (direction) {
                    _removeItem(item.id);
                  },
                  child: Card(
                    margin: EdgeInsets.only(bottom: 16.h),
                    child: Padding(
                      padding: EdgeInsets.all(ResponsiveUtil.spacing(
                          mobile: 8, tablet: 12, desktop: 16)),
                      child: IntrinsicHeight( // Add IntrinsicHeight to ensure proper height constraints
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Container(
                                width: ResponsiveUtil.spacing(
                                    mobile: 80, tablet: 96, desktop: 112),
                                height: ResponsiveUtil.spacing(
                                    mobile: 80, tablet: 96, desktop: 112),
                                child: CachedNetworkImage(
                                  imageUrl: item.product.images.isNotEmpty
                                      ? item.product.images.first
                                      : 'https://via.placeholder.com/100',
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: Colors.grey[200],
                                    child: Icon(
                                      Icons.error,
                                      color: Colors.red,
                                      size: ResponsiveUtil.iconSize(
                                          mobile: 24, tablet: 28, desktop: 32),
                                    ),
                                  ),
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
                                        item.price),
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: theme.primaryColor,
                                      fontSize: ResponsiveUtil.fontSize(
                                          mobile: 16, tablet: 18, desktop: 20),
                                    ),
                                  ),
                                  if (item.selectedVariants != null && item.selectedVariants!.isNotEmpty)
                                    Padding(
                                      padding: EdgeInsets.only(top: 4.h),
                                      child: Text(
                                        item.selectedVariants!.entries
                                            .map((e) => '${e.key}: ${e.value}')
                                            .join(', '),
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.grey[600],
                                          fontSize: ResponsiveUtil.fontSize(
                                              mobile: 12, tablet: 13, desktop: 14),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Quantity controls
                            Container(
                              height: ResponsiveUtil.spacing(
                                  mobile: 80, tablet: 96, desktop: 112),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        constraints: BoxConstraints(
                                          minWidth: 30,
                                          minHeight: 30,
                                        ),
                                        padding: EdgeInsets.zero,
                                        onPressed: isLoading || item.quantity <= 1
                                            ? null
                                            : () => _updateQuantity(item.id, item.quantity - 1),
                                        icon: Icon(
                                          Icons.remove,
                                          size: ResponsiveUtil.iconSize(
                                              mobile: 20, tablet: 24, desktop: 28),
                                        ),
                                        color: isLoading || item.quantity <= 1
                                            ? theme.disabledColor
                                            : theme.primaryColor,
                                      ),
                                      SizedBox(
                                        width: 30,
                                        child: isLoading
                                          ? SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.0,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                    theme.primaryColor),
                                              ),
                                            )
                                          : Text(
                                              item.quantity.toString(),
                                              textAlign: TextAlign.center,
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontSize: ResponsiveUtil.fontSize(
                                                    mobile: 16, tablet: 18, desktop: 20),
                                              ),
                                            ),
                                      ),
                                      IconButton(
                                        constraints: BoxConstraints(
                                          minWidth: 30,
                                          minHeight: 30,
                                        ),
                                        padding: EdgeInsets.zero,
                                        onPressed: isLoading
                                            ? null
                                            : () => _updateQuantity(item.id, item.quantity + 1),
                                        icon: Icon(
                                          Icons.add,
                                          size: ResponsiveUtil.iconSize(
                                              mobile: 20, tablet: 24, desktop: 28),
                                        ),
                                        color: isLoading ? theme.disabledColor : theme.primaryColor,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Cart summary and checkout button
          _buildCartSummary(cart, theme),
        ],
      ),
    );
  }

  Widget _buildCartSummary(Cart cart, ThemeData theme) {
    return Container(
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
            onPressed:  cart.items.isEmpty ? null : () {
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
    );
  }

  void _showClearCartDialog(BuildContext context) {
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
