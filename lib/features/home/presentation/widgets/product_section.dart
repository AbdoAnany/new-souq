import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:souq/core/import_core.dart';
import 'package:souq/core/widgets/product_card.dart';
import 'package:souq/providers/cart_provider.dart';
import 'package:souq/providers/product_provider.dart';
import 'package:souq/screens/product_details_screen.dart';
import 'package:souq/utils/responsive_util.dart';
import 'package:shimmer/shimmer.dart';

class ProductSection extends ConsumerStatefulWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;
  final bool isNewArrivals;

  const ProductSection({
    super.key,
    required this.title,
    this.subtitle,
    this.onSeeAll,
    this.isNewArrivals = false,
  });

  @override
  ConsumerState<ProductSection> createState() => _ProductSectionState();
}

class _ProductSectionState extends ConsumerState<ProductSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced Section Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 4.w,
                                    height: 24.h,
                                    decoration: BoxDecoration(
                                      color: AppColorScheme.primary,
                                      borderRadius: BorderRadius.circular(2.r),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Text(
                                    widget.title,
                                    style: AppTextTheme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: ResponsiveUtil.fontSize(
                                          mobile: 20, tablet: 22, desktop: 24),
                                    ),
                                  ),
                                ],
                              ),
                              if (widget.subtitle != null) ...[
                                SizedBox(height: 4.h),
                                Padding(
                                  padding: EdgeInsets.only(left: 16.w),
                                  child: Text(
                                    widget.subtitle!,
                                    style: AppTextTheme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                      fontSize: ResponsiveUtil.fontSize(
                                          mobile: 14, tablet: 15, desktop: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (widget.onSeeAll != null)
                          Container(
                            decoration: BoxDecoration(
                              color: AppColorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: TextButton.icon(
                              onPressed: widget.onSeeAll,
                              icon: Icon(
                                Icons.arrow_forward_ios,
                                size: 14.sp,
                                color: AppColorScheme.primary,
                              ),
                              label: Text(
                                "See All",
                                style: TextStyle(
                                  color: AppColorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: ResponsiveUtil.fontSize(
                                      mobile: 12, tablet: 13, desktop: 14),
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 6.h),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Products List
                  productsState.when(
                    loading: () => _buildShimmerLoader(),
                    error: (error, stackTrace) => _buildErrorWidget(),
                    data: (products) {
                      if (products.isEmpty) {
                        return _buildEmptyState();
                      }

                      final displayProducts = widget.isNewArrivals
                          ? products.take(5).toList()
                          : products;

                      return SizedBox(
                        height: ResponsiveUtil.spacing(
                            mobile: 280, tablet: 320, desktop: 360),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          itemCount: displayProducts.length,
                          itemBuilder: (context, index) {
                            final product = displayProducts[index];
                            return Container(
                              width: ResponsiveUtil.spacing(
                                  mobile: 180, tablet: 200, desktop: 220),
                              margin: EdgeInsets.symmetric(horizontal: 8.w),
                              child: ProductCard(
                                product: product,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProductDetailsScreen(
                                              productId: product.id),
                                    ),
                                  );
                                },
                                onAddToCart: () => _handleAddToCart(product),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleAddToCart(product) {
    ref.read(cartProvider.notifier).addToCart(product, 1);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  "${product.name} added to cart",
                  style: TextStyle(
                    fontSize: ResponsiveUtil.fontSize(
                        mobile: 14, tablet: 15, desktop: 16),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          margin: EdgeInsets.all(16.w),
          action: SnackBarAction(
            label: "VIEW CART",
            textColor: Colors.white,
            onPressed: () {
              // Navigate to cart tab
            },
          ),
        ),
      );
    }
  }

  Widget _buildShimmerLoader() {
    return SizedBox(
      height: ResponsiveUtil.spacing(mobile: 280, tablet: 320, desktop: 360),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width:
                ResponsiveUtil.spacing(mobile: 180, tablet: 200, desktop: 220),
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: ResponsiveUtil.spacing(mobile: 200, tablet: 240, desktop: 280),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColorScheme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColorScheme.dividerColor.withOpacity(0.5)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size:
                  ResponsiveUtil.fontSize(mobile: 48, tablet: 56, desktop: 64),
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              "No ${widget.title.toLowerCase()} available",
              style: AppTextTheme.textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
                fontSize: ResponsiveUtil.fontSize(
                    mobile: 16, tablet: 18, desktop: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: ResponsiveUtil.spacing(mobile: 200, tablet: 240, desktop: 280),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade700,
              size:
                  ResponsiveUtil.fontSize(mobile: 32, tablet: 36, desktop: 40),
            ),
            SizedBox(height: 12.h),
            Text(
              "Failed to load products",
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: ResponsiveUtil.fontSize(
                    mobile: 16, tablet: 18, desktop: 20),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12.h),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(productsProvider.notifier).fetchFeaturedProducts();
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
