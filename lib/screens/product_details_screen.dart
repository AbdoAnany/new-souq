import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel;
import '../core/widgets/custom_button.dart';
import '/core/constants/app_constants.dart';
import 'package:souq/models/product.dart';
import 'package:souq/providers/cart_provider.dart';
import 'package:souq/providers/product_provider.dart';
import '/core/constants/app_constants.dart';
import '/core/widgets/rating_stars.dart';
import 'package:souq/utils/formatter_util.dart';
import 'package:souq/utils/responsive_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:souq/screens/cart_screen.dart';
import 'package:shimmer/shimmer.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailsScreen({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  int _quantity = 1;
  int _currentImageIndex = 0;
  final carousel.CarouselSliderController _carouselController =
      carousel.CarouselSliderController();
  bool _isInWishlist = false;

  @override
  void initState() {
    super.initState();
    // Initialize product details
    Future.microtask(() {
      ref
          .read(productDetailsProvider(widget.productId).notifier)
          .fetchProductDetails(widget.productId);
    });

    // TODO: Check if product is in wishlist
  }

  void _incrementQuantity() {
    setState(() {
      if (_quantity < AppConstants.maxCartQuantity) {
        _quantity++;
      }
    });
  }

  void _decrementQuantity() {
    setState(() {
      if (_quantity > 1) {
        _quantity--;
      }
    });
  }

  void _addToCart(Product product) {
    ref.read(cartProvider.notifier).addToCart(product, _quantity);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${product.name} added to cart"),
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
  }

  void _toggleWishlist() {
    setState(() {
      _isInWishlist = !_isInWishlist;
    });
    // TODO: Implement wishlist functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(_isInWishlist ? "Added to wishlist" : "Removed from wishlist"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productAsyncValue =
        ref.watch(productDetailsProvider(widget.productId));

    return Scaffold(
      body: SafeArea(
        child: productAsyncValue.when(
          data: (product) {
            if (product == null) {
              return const Center(
                child: Text("Product not found"),
              );
            }

            return CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 0,
                  floating: true,
                  pinned: true,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  elevation: 0,
                  leading: IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            spreadRadius: 1.w,
                            blurRadius: 10.r,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: theme.iconTheme.color,
                        size: ResponsiveUtil.iconSize(
                            mobile: 20, tablet: 22, desktop: 24),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    IconButton(
                      icon: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              spreadRadius: 1.w,
                              blurRadius: 10.r,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.shopping_cart_outlined,
                          color: theme.iconTheme.color,
                          size: ResponsiveUtil.iconSize(
                              mobile: 20, tablet: 22, desktop: 24),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CartScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),

                // Content
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Images Carousel
                      Stack(
                        children: [
                          carousel.CarouselSlider(
                            carouselController: _carouselController,
                            options: carousel.CarouselOptions(
                              height: ResponsiveUtil.spacing(
                                  mobile: 300, tablet: 400, desktop: 500),
                              viewportFraction: 1.0,
                              enableInfiniteScroll: product.images.length > 1,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _currentImageIndex = index;
                                });
                              },
                            ),
                            items: product.images.map((imageUrl) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.contain,
                                    placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator(
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  );
                                },
                              );
                            }).toList(),
                          ),

                          // Image indicators
                          if (product.images.length > 1)
                            Positioned(
                              bottom: 10.h,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:
                                    product.images.asMap().entries.map((entry) {
                                  return GestureDetector(
                                    onTap: () => _carouselController
                                        .animateToPage(entry.key),
                                    child: Container(
                                      width: 8.w,
                                      height: 8.h,
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 4.w),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _currentImageIndex == entry.key
                                            ? theme.primaryColor
                                            : theme.dividerColor,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                          // Wishlist button
                          Positioned(
                            right: 16.w,
                            top: 16.h,
                            child: InkWell(
                              onTap: _toggleWishlist,
                              child: Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      spreadRadius: 1.w,
                                      blurRadius: 10.r,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _isInWishlist
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: _isInWishlist
                                      ? Colors.red
                                      : theme.iconTheme.color,
                                  size: ResponsiveUtil.iconSize(
                                      mobile: 20, tablet: 22, desktop: 24),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Product Info
                      Padding(
                        padding: ResponsiveUtil.padding(
                          mobile: EdgeInsets.all(16.w),
                          tablet: EdgeInsets.all(20.w),
                          desktop: EdgeInsets.all(24.w),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category
                            Text(
                              product.category.toUpperCase(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: ResponsiveUtil.fontSize(
                                    mobile: 12, tablet: 13, desktop: 14),
                              ),
                            ),
                            SizedBox(height: 4.h),

                            // Product Name
                            Text(
                              product.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: ResponsiveUtil.fontSize(
                                    mobile: 24, tablet: 26, desktop: 28),
                              ),
                            ),
                            SizedBox(height: 8.h),

                            // Rating
                            Row(
                              children: [
                                RatingStars(
                                  rating: product.rating,
                                  size: ResponsiveUtil.spacing(
                                      mobile: 20, tablet: 22, desktop: 24),
                                  reviewCount: product.reviewCount,
                                ),
                                if (product.reviewCount > 0) ...[
                                  SizedBox(width: 4.w),
                                  Text(
                                    "(${product.reviewCount} ${product.reviewCount == 1 ? 'review' : 'reviews'})",
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppConstants.textSecondaryColor,
                                      fontSize: ResponsiveUtil.fontSize(
                                          mobile: 12, tablet: 13, desktop: 14),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 16.h),

                            // Price
                            Row(
                              children: [
                                Text(
                                  FormatterUtil.formatCurrency(product.price),
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: product.hasDiscount
                                        ? theme.primaryColor
                                        : null,
                                    fontSize: ResponsiveUtil.fontSize(
                                        mobile: 22, tablet: 24, desktop: 26),
                                  ),
                                ),
                                if (product.hasDiscount) ...[
                                  SizedBox(width: 8.w),
                                  Text(
                                    FormatterUtil.formatCurrency(
                                        product.originalPrice!),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      color: AppConstants.textSecondaryColor,
                                      fontSize: ResponsiveUtil.fontSize(
                                          mobile: 14, tablet: 15, desktop: 16),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      "${(((product.originalPrice! - product.price) / product.originalPrice!) * 100).round()}% OFF",
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: ResponsiveUtil.fontSize(
                                            mobile: 12,
                                            tablet: 13,
                                            desktop: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 8.h),

                            // Stock Status
                            Row(
                              children: [
                                Icon(
                                  product.inStock
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: product.inStock
                                      ? Colors.green
                                      : Colors.red,
                                  size: ResponsiveUtil.iconSize(
                                      mobile: 16, tablet: 18, desktop: 20),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  product.inStock
                                      ? AppStrings.inStock
                                      : AppStrings.outOfStock,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: product.inStock
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: ResponsiveUtil.fontSize(
                                        mobile: 12, tablet: 13, desktop: 14),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24.h),

                            // Description
                            Text(
                              AppStrings.description,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: ResponsiveUtil.fontSize(
                                    mobile: 18, tablet: 20, desktop: 22),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              product.description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: ResponsiveUtil.fontSize(
                                    mobile: 14, tablet: 15, desktop: 16),
                              ),
                            ),
                            SizedBox(height: 24.h),

                            // Add to Cart Section
                            Row(
                              children: [
                                // Quantity Selector
                                Container(
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: theme.dividerColor),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.remove,
                                          size: ResponsiveUtil.iconSize(
                                              mobile: 18,
                                              tablet: 20,
                                              desktop: 22),
                                        ),
                                        onPressed: _decrementQuantity,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.w),
                                        child: SizedBox(
                                          width: 30.w,
                                          child: Text(
                                            _quantity.toString(),
                                            textAlign: TextAlign.center,
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: ResponsiveUtil.fontSize(
                                                  mobile: 16,
                                                  tablet: 18,
                                                  desktop: 20),
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.add,
                                          size: ResponsiveUtil.iconSize(
                                              mobile: 18,
                                              tablet: 20,
                                              desktop: 22),
                                        ),
                                        onPressed: _incrementQuantity,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(width: 16.w),
                                // Add to Cart Button
                                Expanded(
                                  child: CustomButton(
                                    text: AppStrings.addToCart,
                                    onPressed: product.inStock
                                        ? () => _addToCart(product)
                                        : () {}, // Provide empty function instead of null
                                    icon: Icons.shopping_cart,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 16.h),

                            // Buy Now Button
                            CustomButton(
                              text: AppStrings.buyNow,
                              onPressed: product.inStock
                                  ? () {
                                      _addToCart(product);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const CartScreen(),
                                        ),
                                      );
                                    }
                                  : () {}, // Provide empty function instead of null
                              color: AppConstants.secondaryColor,
                            ),

                            SizedBox(height: 24.h),

                            // Product Details / Specifications
                            Text(
                              "Specifications",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: ResponsiveUtil.fontSize(
                                    mobile: 18, tablet: 20, desktop: 22),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            // Display specifications if available
                            if (product.specifications.isNotEmpty)
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: product.specifications.length,
                                itemBuilder: (context, index) {
                                  final specKey = product.specifications.keys
                                      .elementAt(index);
                                  final specValue =
                                      product.specifications[specKey];
                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 4.h),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 100.w,
                                          child: Text(
                                            "$specKey:",
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: AppConstants
                                                  .textSecondaryColor,
                                              fontSize: ResponsiveUtil.fontSize(
                                                  mobile: 14,
                                                  tablet: 15,
                                                  desktop: 16),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            specValue.toString(),
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              fontSize: ResponsiveUtil.fontSize(
                                                  mobile: 14,
                                                  tablet: 15,
                                                  desktop: 16),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                            else
                              Text(
                                "No specifications available",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppConstants.textSecondaryColor,
                                  fontSize: ResponsiveUtil.fontSize(
                                      mobile: 14, tablet: 15, desktop: 16),
                                ),
                              ),

                            SizedBox(height: 24.h),

                            // Reviews
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppStrings.reviews,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: ResponsiveUtil.fontSize(
                                        mobile: 18, tablet: 20, desktop: 22),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Navigate to all reviews
                                  },
                                  child: Text(
                                    'See All',
                                    style: TextStyle(
                                      color: theme.primaryColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: ResponsiveUtil.fontSize(
                                          mobile: 14, tablet: 15, desktop: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),

                            // Display reviews placeholder
                            product.reviewCount > 0
                                ? Text(
                                    "Reviews will be displayed here",
                                    style: TextStyle(
                                      fontSize: ResponsiveUtil.fontSize(
                                          mobile: 14, tablet: 15, desktop: 16),
                                    ),
                                  )
                                : Center(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 20.h),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.rate_review_outlined,
                                            size: ResponsiveUtil.iconSize(
                                                mobile: 48,
                                                tablet: 52,
                                                desktop: 56),
                                            color: theme.dividerColor,
                                          ),
                                          SizedBox(height: 8.h),
                                          Text(
                                            "No reviews yet",
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                              color: AppConstants
                                                  .textSecondaryColor,
                                              fontSize: ResponsiveUtil.fontSize(
                                                  mobile: 16,
                                                  tablet: 17,
                                                  desktop: 18),
                                            ),
                                          ),
                                          SizedBox(height: 8.h),
                                          ElevatedButton(
                                            onPressed: () {
                                              // Add review logic
                                            },
                                            child: Text(
                                              "Write a Review",
                                              style: TextStyle(
                                                fontSize:
                                                    ResponsiveUtil.fontSize(
                                                        mobile: 14,
                                                        tablet: 15,
                                                        desktop: 16),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                            SizedBox(height: 32.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => _buildLoadingState(),
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: ResponsiveUtil.iconSize(
                      mobile: 60, tablet: 65, desktop: 70),
                  color: Colors.red,
                ),
                SizedBox(height: 16.h),
                Text(
                  "Error loading product details",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: ResponsiveUtil.fontSize(
                        mobile: 16, tablet: 18, desktop: 20),
                  ),
                ),
                SizedBox(height: 8.h),
                TextButton(
                  onPressed: () {
                    ref
                        .read(productDetailsProvider(widget.productId).notifier)
                        .fetchProductDetails(widget.productId);
                  },
                  child: Text(
                    "Retry",
                    style: TextStyle(
                      fontSize: ResponsiveUtil.fontSize(
                          mobile: 14, tablet: 15, desktop: 16),
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

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: double.infinity,
              height: ResponsiveUtil.spacing(
                  mobile: 300, tablet: 400, desktop: 500),
              color: Colors.white,
            ),
          ),
          Padding(
            padding: ResponsiveUtil.padding(
              mobile: EdgeInsets.all(16.w),
              tablet: EdgeInsets.all(20.w),
              desktop: EdgeInsets.all(24.w),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 100.w,
                    height: 16.h,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: double.infinity,
                    height: 24.h,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16.h),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 150.w,
                    height: 20.h,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16.h),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: double.infinity,
                    height: 120.h,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
