import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:souq/constants/app_constants.dart';
import 'package:souq/models/product.dart';
import 'package:souq/providers/wishlist_provider.dart';
import 'package:souq/utils/formatter_util.dart';
import 'package:souq/widgets/rating_stars.dart';

class ProductCard extends ConsumerWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onWishlistToggle;
  final bool? isInWishlist;
  final bool showAddToCartButton;
  final bool showWishlistButton;
  final double width;
  final double height;

  const ProductCard({
    Key? key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.onWishlistToggle,
    this.isInWishlist,
    this.showAddToCartButton = true,
    this.showWishlistButton = true,
    this.width = 180.0,
    this.height = 250.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
      // If isInWishlist is not provided, check from the provider    // Use the provided isInWishlist value or false if not provided
    final bool inWishlist = isInWishlist ?? false;
    
    // If we need to check from the provider, we would use:
    // final inWishlist = isInWishlist ?? ref.watch(productInWishlistProvider(product.id)).value ?? false;
    
    // Calculate discount percentage if original price exists
    final hasDiscount = product.originalPrice != null && product.originalPrice! > product.price;
    final discountPercentage = hasDiscount
        ? ((product.originalPrice! - product.price) / product.originalPrice! * 100).toInt()
        : 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 2),
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
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.borderRadiusMedium),
                    topRight: Radius.circular(AppConstants.borderRadiusMedium),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: product.mainImage,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      height: height * 0.55,
                      width: double.infinity,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      height: height * 0.55,
                      width: double.infinity,
                      child: const Center(
                        child: Icon(Icons.error),
                      ),
                    ),
                    fit: BoxFit.cover,
                    height: height * 0.55,
                    width: double.infinity,
                  ),
                ),
                
                // Discount Badge
                if (hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, 
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                      ),
                      child: Text(
                        '$discountPercentage% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                
                // Wishlist Button
                if (showWishlistButton)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: onWishlistToggle ?? () {
                        ref.read(productInWishlistProvider(product.id).notifier).toggleWishlistStatus();
                      },
                      child: Container(
                        height: 32.0,
                        width: 32.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 0,
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            inWishlist ? Icons.favorite : Icons.favorite_border,
                            color: inWishlist ? Colors.red : Colors.grey,
                            size: 18.0,
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
                padding: const EdgeInsets.all(8.0),
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
                      ),
                    ),
                    
                    const SizedBox(height: 4.0),
                    
                    // Product Category
                    Text(
                      product.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    
                    const SizedBox(height: 4.0),
                    
                    // Product Rating
                    RatingStars(
                      rating: product.rating,
                      size: 16.0,
                      reviewCount: product.reviewCount,
                    ),
                    
                    const Spacer(),
                    
                    // Product Price
                    Row(
                      children: [
                        // Current price
                        Text(
                          FormatterUtil.formatCurrency(product.price),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: hasDiscount ? theme.colorScheme.primary : null,
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        // Original price if discounted
                        if (hasDiscount)
                          Text(
                            FormatterUtil.formatCurrency(product.originalPrice!),
                            style: theme.textTheme.bodySmall?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                        const Spacer(),
                        
                        // Add to Cart Button
                        if (showAddToCartButton && product.isAvailable)
                          InkWell(
                            onTap: onAddToCart,
                            child: Container(
                              padding: const EdgeInsets.all(6.0),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_shopping_cart,
                                color: Colors.white,
                                size: 18.0,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    // Out of stock indicator
                    if (!product.isAvailable)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Out of Stock',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
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
