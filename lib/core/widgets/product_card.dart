import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/core/widgets/rating_stars.dart';
import 'package:souq/models/product.dart';
import 'package:souq/utils/formatter_util.dart';
import 'package:souq/utils/responsive_util.dart';
import 'package:souq/providers/wishlist_provider.dart';

class ProductCard extends ConsumerWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onWishlistToggle;
  final bool? isInWishlist;
  final bool showAddToCartButton;
  final bool showWishlistButton;
  final double? width;
  final double? height;

  const ProductCard({
    Key? key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.onWishlistToggle,
    this.isInWishlist,
    this.showAddToCartButton = true,
    this.showWishlistButton = true,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Responsive dimensions
    final cardWidth =
        width ?? ResponsiveUtil.spacing(mobile: 180, tablet: 200, desktop: 220);
    final cardHeight = height ??
        ResponsiveUtil.spacing(mobile: 250, tablet: 280, desktop: 320);

    // If isInWishlist is not provided, check from the provider    // Use the provided isInWishlist value or false if not provided
    final bool inWishlist = isInWishlist ?? false;

    // If we need to check from the provider, we would use:
    // final inWishlist = isInWishlist ?? ref.watch(productInWishlistProvider(product.id)).value ?? false;

    // Calculate discount percentage if original price exists
    final hasDiscount =
        product.originalPrice != null && product.originalPrice! > product.price;
    final discountPercentage = hasDiscount
        ? ((product.originalPrice! - product.price) /
                product.originalPrice! *
                100)
            .toInt()
        : 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 10.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Discount Badge
            Stack(
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: product.mainImage,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      height: cardHeight * 0.55,
                      width: double.infinity,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      height: cardHeight * 0.55,
                      width: double.infinity,
                      child: const Center(
                        child: Icon(Icons.error),
                      ),
                    ),
                    fit: BoxFit.cover,
                    height: cardHeight * 0.55,
                    width: double.infinity,
                  ),
                ),

                // Discount Badge
                if (hasDiscount)
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        '$discountPercentage% OFF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveUtil.fontSize(
                              mobile: 10, tablet: 11, desktop: 12),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Wishlist Button
                if (showWishlistButton)
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: InkWell(
                      onTap: onWishlistToggle ??
                          () {
                            ref
                                .read(productInWishlistProvider(product.id)
                                    .notifier)
                                .toggleWishlistStatus();
                          },
                      child: Container(
                        height: ResponsiveUtil.spacing(
                            mobile: 32, tablet: 36, desktop: 40),
                        width: ResponsiveUtil.spacing(
                            mobile: 32, tablet: 36, desktop: 40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 0,
                              blurRadius: 4.r,
                              offset: Offset(0, 1.h),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            inWishlist ? Icons.favorite : Icons.favorite_border,
                            color: inWishlist ? Colors.red : Colors.grey,
                            size: ResponsiveUtil.fontSize(
                                mobile: 16, tablet: 18, desktop: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Product Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveUtil.fontSize(
                            mobile: 14, tablet: 15, desktop: 16),
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // Product Category
                    Text(
                      product.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontSize: ResponsiveUtil.fontSize(
                            mobile: 12, tablet: 13, desktop: 14),
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // Product Rating
                    RatingStars(
                      rating: product.rating,
                      size: ResponsiveUtil.fontSize(
                          mobile: 14, tablet: 16, desktop: 18),
                      reviewCount: product.reviewCount,
                    ),

                    const Spacer(),

                    // Product Price
                    Row(
                      children: [
                        // Current price
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              FormatterUtil.formatCurrency(product.price),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: hasDiscount
                                    ? theme.colorScheme.primary
                                    : null,
                                fontSize: ResponsiveUtil.fontSize(
                                    mobile: 14, tablet: 16, desktop: 18),
                              ),
                            ),
                            // Original price if discounted
                            if (hasDiscount)
                              Text(
                                FormatterUtil.formatCurrency(
                                    product.originalPrice!),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                  fontSize: ResponsiveUtil.fontSize(
                                      mobile: 12, tablet: 13, desktop: 14),
                                ),
                              ),
                          ],
                        ),

                        SizedBox(width: 4.w),

                        const Spacer(),

                        // Add to Cart Button
                        if (showAddToCartButton && product.isAvailable)
                          InkWell(
                            onTap: onAddToCart,
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add_shopping_cart,
                                color: Colors.white,
                                size: ResponsiveUtil.fontSize(
                                    mobile: 16, tablet: 18, desktop: 20),
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Out of stock indicator
                    if (!product.isAvailable)
                      Container(
                        margin: EdgeInsets.only(top: 4.h),
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'Out of Stock',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveUtil.fontSize(
                                mobile: 10, tablet: 11, desktop: 12),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
