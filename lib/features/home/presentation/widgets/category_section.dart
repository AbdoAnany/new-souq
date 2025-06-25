import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:souq/providers/product_provider.dart';
import 'package:souq/screens/categories_screen.dart';
import 'package:souq/screens/category_products_screen.dart';
import 'package:souq/utils/responsive_util.dart';

class CategorySection extends ConsumerStatefulWidget {
  const CategorySection({super.key});

  @override
  ConsumerState<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends ConsumerState<CategorySection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
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
    final theme = Theme.of(context);
    final categoryState = ref.watch(categoryProvider);

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
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
                        child: Row(
                          children: [
                            Container(
                              width: 4.w,
                              height: 24.h,
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Shop by Category",
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: ResponsiveUtil.fontSize(
                                          mobile: 20, tablet: 22, desktop: 24),
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    "Explore our collection",
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                      fontSize: ResponsiveUtil.fontSize(
                                          mobile: 14, tablet: 15, desktop: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const CategoriesScreen()),
                            );
                          },
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            size: 14.sp,
                            color: theme.primaryColor,
                          ),
                          label: Text(
                            "See All",
                            style: TextStyle(
                              color: theme.primaryColor,
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

                // Categories Grid
                SizedBox(
                  height: ResponsiveUtil.spacing(
                      mobile: 120, tablet: 140, desktop: 160),
                  child: categoryState.when(
                    loading: () => _buildShimmerLoader(),
                    error: (error, _) => _buildErrorWidget(theme),
                    data: (categories) {
                      if (categories.isEmpty) {
                        return _buildEmptyState(theme);
                      }

                      final parentCategories = categories
                          .where((cat) => cat.isParentCategory)
                          .toList();

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        itemCount: parentCategories.length,
                        itemBuilder: (context, index) {
                          final category = parentCategories[index];
                          return _buildCategoryItem(category, theme, index);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryItem(category, ThemeData theme, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 300 + (index * 100)),
        tween: Tween<double>(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Opacity(
              opacity: value,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryProductsScreen(
                        category: category,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: ResponsiveUtil.spacing(
                      mobile: 85, tablet: 95, desktop: 105),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: ResponsiveUtil.spacing(
                            mobile: 65, tablet: 75, desktop: 85),
                        height: ResponsiveUtil.spacing(
                            mobile: 65, tablet: 75, desktop: 85),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.primaryColor.withOpacity(0.1),
                              theme.primaryColor.withOpacity(0.05),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withOpacity(0.1),
                              blurRadius: 10.r,
                              offset: Offset(0, 4.h),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: category.imageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: category.imageUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    decoration: BoxDecoration(
                                      color:
                                          theme.primaryColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.w,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          theme.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    decoration: BoxDecoration(
                                      color:
                                          theme.primaryColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.category,
                                      color: theme.primaryColor,
                                      size: ResponsiveUtil.fontSize(
                                          mobile: 28, tablet: 32, desktop: 36),
                                    ),
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.category,
                                    color: theme.primaryColor,
                                    size: ResponsiveUtil.fontSize(
                                        mobile: 28, tablet: 32, desktop: 36),
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        category.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: ResponsiveUtil.fontSize(
                              mobile: 12, tablet: 13, desktop: 14),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              children: [
                CircleAvatar(
                  radius: ResponsiveUtil.spacing(
                      mobile: 32, tablet: 37, desktop: 42),
                  backgroundColor: Colors.white,
                ),
                SizedBox(height: 12.h),
                Container(
                  width: 60.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: ResponsiveUtil.fontSize(mobile: 48, tablet: 56, desktop: 64),
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            "No categories available",
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
              fontSize:
                  ResponsiveUtil.fontSize(mobile: 16, tablet: 18, desktop: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade700,
            size: ResponsiveUtil.fontSize(mobile: 32, tablet: 36, desktop: 40),
          ),
          SizedBox(height: 12.h),
          Text(
            "Failed to load categories",
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize:
                  ResponsiveUtil.fontSize(mobile: 14, tablet: 16, desktop: 18),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          ElevatedButton(
            onPressed: () {
              ref.read(categoryProvider.notifier).fetchCategories();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}
