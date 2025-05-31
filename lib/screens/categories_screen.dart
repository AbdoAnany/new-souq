import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:souq/models/category.dart';
import 'package:souq/providers/product_provider.dart';
import 'package:souq/screens/category_products_screen.dart';
import 'package:souq/utils/responsive_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch categories when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryProvider.notifier).fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesState = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Categories",
          style: TextStyle(
            fontSize:
                ResponsiveUtil.fontSize(mobile: 20, tablet: 22, desktop: 24),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(categoryProvider.notifier).fetchCategories();
        },
        child: categoriesState.when(
          loading: () => _buildCategoriesShimmer(),
          error: (error, stack) => _buildErrorWidget(error.toString()),
          data: (categories) {
            if (categories.isEmpty) {
              return Center(
                child: Text(
                  "No categories found.",
                  style: TextStyle(
                    fontSize: ResponsiveUtil.fontSize(
                        mobile: 16, tablet: 18, desktop: 20),
                  ),
                ),
              );
            }

            // Filter parent categories
            final parentCategories =
                categories.where((cat) => cat.isParentCategory).toList();

            // Use responsive grid or list based on screen size
            if (ResponsiveUtil.isDesktop(context) ||
                ResponsiveUtil.isTablet(context)) {
              return GridView.builder(
                padding: EdgeInsets.all(16.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ResponsiveUtil.gridColumns(context),
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  childAspectRatio: 1.2,
                ),
                itemCount: parentCategories.length,
                itemBuilder: (context, index) {
                  final category = parentCategories[index];
                  return _buildCategoryItem(category);
                },
              );
            } else {
              return ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: parentCategories.length,
                itemBuilder: (context, index) {
                  final category = parentCategories[index];
                  return _buildCategoryItem(category);
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildCategoryItem(Category category) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () {
          if (category.hasSubcategories) {
            _showSubcategories(category);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CategoryProductsScreen(category: category),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(12.r),
              ),
              child: SizedBox(
                height: ResponsiveUtil.spacing(
                    mobile: 120, tablet: 140, desktop: 160),
                width: double.infinity,
                child: category.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: category.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            color: Colors.white,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          child: Center(
                            child: Icon(
                              Icons.category,
                              size: ResponsiveUtil.fontSize(
                                  mobile: 40, tablet: 45, desktop: 50),
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        child: Center(
                          child: Icon(
                            Icons.category,
                            size: ResponsiveUtil.fontSize(
                                mobile: 40, tablet: 45, desktop: 50),
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          category.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveUtil.fontSize(
                                mobile: 16, tablet: 18, desktop: 20),
                          ),
                        ),
                      ),
                      if (category.hasSubcategories)
                        Icon(
                          Icons.arrow_forward_ios,
                          size: ResponsiveUtil.fontSize(
                              mobile: 16, tablet: 18, desktop: 20),
                          color: theme.colorScheme.primary,
                        ),
                    ],
                  ),
                  if (category.description.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      category.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: ResponsiveUtil.fontSize(
                            mobile: 14, tablet: 15, desktop: 16),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 8.h),
                  Text(
                    "${category.productCount} products",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      fontSize: ResponsiveUtil.fontSize(
                          mobile: 12, tablet: 13, desktop: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubcategories(Category category) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    category.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: ResponsiveUtil.fontSize(
                          mobile: 18, tablet: 20, desktop: 22),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      size: ResponsiveUtil.fontSize(
                          mobile: 24, tablet: 26, desktop: 28),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: category.subcategories.length,
                  itemBuilder: (context, index) {
                    final subcategory = category.subcategories[index];
                    return ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      title: Text(
                        subcategory.name,
                        style: TextStyle(
                          fontSize: ResponsiveUtil.fontSize(
                              mobile: 16, tablet: 17, desktop: 18),
                        ),
                      ),
                      subtitle: Text(
                        "${subcategory.productCount} products",
                        style: TextStyle(
                          fontSize: ResponsiveUtil.fontSize(
                              mobile: 14, tablet: 15, desktop: 16),
                        ),
                      ),
                      leading: subcategory.imageUrl != null
                          ? SizedBox(
                              width: ResponsiveUtil.spacing(
                                  mobile: 40, tablet: 45, desktop: 50),
                              height: ResponsiveUtil.spacing(
                                  mobile: 40, tablet: 45, desktop: 50),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: CachedNetworkImage(
                                  imageUrl: subcategory.imageUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.1),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.1),
                                    child: Icon(
                                      Icons.category,
                                      size: ResponsiveUtil.fontSize(
                                          mobile: 20, tablet: 22, desktop: 24),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : CircleAvatar(
                              radius: ResponsiveUtil.spacing(
                                  mobile: 20, tablet: 22, desktop: 25),
                              backgroundColor:
                                  theme.colorScheme.primary.withOpacity(0.1),
                              child: Icon(
                                Icons.category,
                                color: theme.colorScheme.primary,
                                size: ResponsiveUtil.fontSize(
                                    mobile: 20, tablet: 22, desktop: 24),
                              ),
                            ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: ResponsiveUtil.fontSize(
                            mobile: 16, tablet: 17, desktop: 18),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CategoryProductsScreen(category: subcategory),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoriesShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.only(bottom: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: ResponsiveUtil.spacing(
                      mobile: 120, tablet: 140, desktop: 160),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12.r),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 20.h,
                        width: 150.w,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        height: 14.h,
                        width: 100.w,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(
            ResponsiveUtil.spacing(mobile: 16, tablet: 20, desktop: 24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size:
                  ResponsiveUtil.iconSize(mobile: 60, tablet: 70, desktop: 80),
            ),
            SizedBox(height: 16.h),
            Text(
              "Something went wrong",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: ResponsiveUtil.fontSize(
                        mobile: 18, tablet: 20, desktop: 22),
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: ResponsiveUtil.fontSize(
                        mobile: 14, tablet: 15, desktop: 16),
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                ref.read(categoryProvider.notifier).fetchCategories();
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
    );
  }
}
