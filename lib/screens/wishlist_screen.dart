import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:souq/providers/cart_provider.dart';
import 'package:souq/providers/wishlist_provider.dart';
import 'package:souq/screens/cart_screen.dart';
import 'package:souq/screens/product_details_screen.dart';
import 'package:souq/utils/responsive_util.dart';
import 'package:souq/core/widgets/product_card.dart';
import '../core/widgets/my_app_bar.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final wishlistState = ref.watch(wishlistProvider);

    return Scaffold(
      appBar: MyAppBar(
        title: const Text('My Wishlist'),

        actions: [
          wishlistState.maybeWhen(
            data: (products) => products.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: ResponsiveUtil.iconSize(
                          mobile: 24, tablet: 26, desktop: 28),
                    ),
                    onPressed: () => _showClearWishlistDialog(context, ref),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(wishlistProvider.notifier).loadWishlist();
        },
        child: wishlistState.when(
          loading: () => _buildLoadingState(context),
          error: (error, stack) =>
              _buildErrorState(context, ref, error.toString()),
          data: (products) {
            if (products.isEmpty) {
              return _buildEmptyState(context);
            }

            return GridView.builder(
              padding: EdgeInsets.all(
                  ResponsiveUtil.spacing(mobile: 16, tablet: 20, desktop: 24)),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveUtil.isDesktop(context)
                    ? 4
                    : ResponsiveUtil.isTablet(context)
                        ? 3
                        : 2,
                childAspectRatio: ResponsiveUtil.isDesktop(context)
                    ? 0.7
                    : ResponsiveUtil.isTablet(context)
                        ? 0.68
                        : 0.65,
                crossAxisSpacing:
                    ResponsiveUtil.spacing(mobile: 12, tablet: 16, desktop: 20),
                mainAxisSpacing:
                    ResponsiveUtil.spacing(mobile: 12, tablet: 16, desktop: 20),
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailsScreen(productId: product.id),
                    ),
                  ),
                  onAddToCart: () {
                    ref.read(cartProvider.notifier).addToCart(product, 1);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "${product.name} added to cart",
                          style: TextStyle(
                            fontSize: ResponsiveUtil.fontSize(
                                mobile: 14, tablet: 15, desktop: 16),
                          ),
                        ),
                        action: SnackBarAction(
                          label: "VIEW CART",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CartScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  isInWishlist: true,
                  onWishlistToggle: () {
                    ref
                        .read(wishlistProvider.notifier)
                        .removeFromWishlist(product.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "${product.name} removed from wishlist",
                          style: TextStyle(
                            fontSize: ResponsiveUtil.fontSize(
                                mobile: 14, tablet: 15, desktop: 16),
                          ),
                        ),
                        action: SnackBarAction(
                          label: "UNDO",
                          onPressed: () {
                            ref
                                .read(wishlistProvider.notifier)
                                .addToWishlist(product.id);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        padding: EdgeInsets.all(
            ResponsiveUtil.spacing(mobile: 16, tablet: 20, desktop: 24)),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ResponsiveUtil.isDesktop(context)
              ? 4
              : ResponsiveUtil.isTablet(context)
                  ? 3
                  : 2,
          childAspectRatio: ResponsiveUtil.isDesktop(context)
              ? 0.7
              : ResponsiveUtil.isTablet(context)
                  ? 0.68
                  : 0.65,
          crossAxisSpacing:
              ResponsiveUtil.spacing(mobile: 12, tablet: 16, desktop: 20),
          mainAxisSpacing:
              ResponsiveUtil.spacing(mobile: 12, tablet: 16, desktop: 20),
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  ResponsiveUtil.spacing(mobile: 12, tablet: 14, desktop: 16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(ResponsiveUtil.spacing(
                            mobile: 12, tablet: 14, desktop: 16)),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(ResponsiveUtil.spacing(
                        mobile: 12, tablet: 14, desktop: 16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 14.h,
                          width: double.infinity,
                          color: Colors.white,
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          height: 14.h,
                          width: 80.w,
                          color: Colors.white,
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          height: 14.h,
                          width: 60.w,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(
            ResponsiveUtil.spacing(mobile: 16, tablet: 20, desktop: 24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size:
                  ResponsiveUtil.iconSize(mobile: 60, tablet: 70, desktop: 80),
              color: theme.colorScheme.error,
            ),
            SizedBox(height: 16.h),
            Text(
              "Something went wrong",
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: ResponsiveUtil.fontSize(
                    mobile: 18, tablet: 20, desktop: 22),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: ResponsiveUtil.fontSize(
                    mobile: 14, tablet: 15, desktop: 16),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                ref.read(wishlistProvider.notifier).loadWishlist();
              },
              child: Text(
                "Try Again",
                style: TextStyle(
                  fontSize: ResponsiveUtil.fontSize(
                      mobile: 14, tablet: 15, desktop: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(
            ResponsiveUtil.spacing(mobile: 16, tablet: 20, desktop: 24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border,
              size:
                  ResponsiveUtil.iconSize(mobile: 80, tablet: 90, desktop: 100),
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            SizedBox(height: 16.h),
            Text(
              "Your wishlist is empty",
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: ResponsiveUtil.fontSize(
                    mobile: 18, tablet: 20, desktop: 22),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              "Save items you like by tapping the heart icon",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: ResponsiveUtil.fontSize(
                    mobile: 14, tablet: 15, desktop: 16),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text(
                "Continue Shopping",
                style: TextStyle(
                  fontSize: ResponsiveUtil.fontSize(
                      mobile: 14, tablet: 15, desktop: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearWishlistDialog(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Clear Wishlist",
          style: TextStyle(
            fontSize:
                ResponsiveUtil.fontSize(mobile: 18, tablet: 20, desktop: 22),
          ),
        ),
        content: Text(
          "Are you sure you want to remove all items from your wishlist?",
          style: TextStyle(
            fontSize:
                ResponsiveUtil.fontSize(mobile: 14, tablet: 15, desktop: 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              "Cancel",
              style: TextStyle(
                fontSize: ResponsiveUtil.fontSize(
                    mobile: 14, tablet: 15, desktop: 16),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(wishlistProvider.notifier).clearWishlist();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Wishlist has been cleared",
                    style: TextStyle(
                      fontSize: ResponsiveUtil.fontSize(
                          mobile: 14, tablet: 15, desktop: 16),
                    ),
                  ),
                ),
              );
            },
            style:
                TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
            child: Text(
              "Clear",
              style: TextStyle(
                fontSize: ResponsiveUtil.fontSize(
                    mobile: 14, tablet: 15, desktop: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
