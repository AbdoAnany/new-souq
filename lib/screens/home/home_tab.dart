import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel_slider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:souq/core/constants/app_constants.dart';
import 'package:souq/core/widgets/my_app_bar.dart';
import 'package:souq/providers/auth_provider.dart';
import 'package:souq/providers/cart_provider.dart';
import 'package:souq/providers/product_provider.dart';
import 'package:souq/screens/categories_screen.dart';
import 'package:souq/screens/category_products_screen.dart';
import 'package:souq/screens/notifications_screen.dart';
import 'package:souq/screens/offers_screen.dart';
import 'package:souq/screens/product_details_screen.dart';
import 'package:souq/screens/search_screen.dart';
import 'package:souq/screens/wishlist_screen.dart';
import 'package:souq/utils/responsive_util.dart';
import 'package:souq/utils/size_config.dart';
import 'package:souq/core/widgets/offer_card.dart';import 'package:souq/core/widgets/product_card.dart';
import 'package:souq/core/widgets/section_header.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  int _currentCarouselSlide = 0;
  final carousel_slider.CarouselSliderController _carouselController =
      carousel_slider.CarouselSliderController();

  @override
  void initState() {
    super.initState();
    // Use Future.microtask to delay provider modifications until after the build phase
    Future.microtask(() {
      // Ensure we fetch featured products
      ref.read(productsProvider.notifier).fetchFeaturedProducts();
      // Ensure we fetch categories
      ref.read(categoryProvider.notifier).fetchCategories();
      // Fetch offers
      ref.read(offerProvider.notifier).fetchOffers();
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final theme = Theme.of(context);
    final productsState = ref.watch(productsProvider);
    final offersState = ref.watch(offerProvider);
    final authState = ref.watch(authProvider);

    final user = authState.value;
    final userName = user != null ? user.firstName : "Guest";

    return Scaffold(
      appBar:

      MyAppBar(
        title: Text(
          AppConstants.appName,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, size: 24.sp),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.favorite_border, size: 24.sp),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WishlistScreen(),
                ),
              );
            },
          ),
          SizedBox(width: 8.w),
        ],

      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(productsProvider.notifier).fetchFeaturedProducts();
          await ref.read(offerProvider.notifier).fetchOffers();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome User Section
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
                child: Text(
                  "Hello, $userName! 👋",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveUtil.fontSize(
                        mobile: 24, tablet: 28, desktop: 32),
                  ),
                ),
              ),

              // Search Bar
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: theme.dividerColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10.r,
                          offset: Offset(0, 2.h),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: theme.iconTheme.color,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          AppStrings.search,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.grey,
                            fontSize: ResponsiveUtil.fontSize(
                                mobile: 16, tablet: 18, desktop: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Banner Carousel
              offersState.when(
                loading: () => _buildBannerCarouselShimmer(),
                error: (error, stackTrace) =>
                    _buildErrorWidget("Failed to load offers"),
                data: (offers) {
                  if (offers.isEmpty) {
                    return _buildPlaceholderBanner();
                  }

                  return Column(
                    children: [
                      carousel_slider.CarouselSlider(
                        carouselController: _carouselController,
                        options: carousel_slider.CarouselOptions(
                          height: ResponsiveUtil.spacing(
                              mobile: 180, tablet: 220, desktop: 250),
                          viewportFraction: ResponsiveUtil.isDesktop(context)
                              ? 0.8
                              : ResponsiveUtil.isTablet(context)
                                  ? 0.85
                                  : 0.85,
                          enlargeCenterPage: true,
                          enableInfiniteScroll: offers.length > 1,
                          autoPlay: offers.length > 1,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentCarouselSlide = index;
                            });
                          },
                        ),
                        items: offers
                            .map((offer) => OfferCard(offer: offer))
                            .toList(),
                      ),
                      if (offers.length > 1)
                        Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: offers.asMap().entries.map((entry) {
                              return GestureDetector(
                                onTap: () => _carouselController
                                    .animateToPage(entry.key),
                                child: Container(
                                  width: 8.w,
                                  height: 8.h,
                                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentCarouselSlide == entry.key
                                        ? theme.primaryColor
                                        : theme.dividerColor,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  );
                },
              ),

              SizedBox(height: 24.h),

              // Special Offers Section
              SectionHeader(
                title: AppStrings.offers,
                onSeeAllPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OffersScreen(),
                    ),
                  );
                },
              ),

              offersState.when(
                loading: () => _buildOfferCardsShimmer(),
                error: (error, stackTrace) =>
                    _buildErrorWidget("Failed to load offers"),
                data: (offers) {
                  if (offers.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Text(
                          "No special offers available right now",
                          style: TextStyle(
                            fontSize: ResponsiveUtil.fontSize(
                                mobile: 14, tablet: 16, desktop: 16),
                          ),
                        ),
                      ),
                    );
                  }

                  return SizedBox(
                    height: ResponsiveUtil.spacing(
                        mobile: 120, tablet: 130, desktop: 150),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      itemCount: offers.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: OfferCard(
                            offer: offers[index],
                            isSmall: true,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              SizedBox(height: 24.h),

              // Featured Products
              SectionHeader(
                title: "Featured Products",
                onSeeAllPressed: () {
                  // Navigate to featured products page
                },
              ),

              productsState.when(
                loading: () => _buildProductsShimmer(),
                error: (error, stackTrace) =>
                    _buildErrorWidget("Failed to load products"),
                data: (products) {
                  if (products.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Text(
                          "No featured products available",
                          style: TextStyle(
                            fontSize: ResponsiveUtil.fontSize(
                                mobile: 14, tablet: 16, desktop: 16),
                          ),
                        ),
                      ),
                    );
                  }

                  return SizedBox(
                    height: ResponsiveUtil.spacing(
                        mobile: 255, tablet: 280, desktop: 320),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: ProductCard(
                            product: product,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailsScreen(
                                      productId: product.id),
                                ),
                              );
                            },
                            onAddToCart: () {
                              ref
                                  .read(cartProvider.notifier)
                                  .addToCart(product, 1);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text("${product.name} added to cart"),
                                  action: SnackBarAction(
                                    label: "VIEW CART",
                                    onPressed: () {
                                      // Switch to cart tab
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              SizedBox(height: 24.h),

              // New Arrivals
              SectionHeader(
                title: "New Arrivals",
                onSeeAllPressed: () {
                  // Navigate to new arrivals page
                },
              ),

              productsState.when(
                loading: () => _buildProductsShimmer(),
                error: (error, stackTrace) =>
                    _buildErrorWidget("Failed to load products"),
                data: (products) {
                  if (products.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Text(
                          "No new arrivals available",
                          style: TextStyle(
                            fontSize: ResponsiveUtil.fontSize(
                                mobile: 14, tablet: 16, desktop: 16),
                          ),
                        ),
                      ),
                    );
                  }

                  // Just use the first few products for demo purposes
                  final newProducts = products.take(5).toList();

                  return SizedBox(
                    height: ResponsiveUtil.spacing(
                        mobile: 255, tablet: 280, desktop: 320),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      itemCount: newProducts.length,
                      itemBuilder: (context, index) {
                        final product = newProducts[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: ProductCard(
                            product: product,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailsScreen(
                                      productId: product.id),
                                ),
                              );
                            },
                            onAddToCart: () {
                              ref
                                  .read(cartProvider.notifier)
                                  .addToCart(product, 1);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text("${product.name} added to cart"),
                                  action: SnackBarAction(
                                    label: "VIEW CART",
                                    onPressed: () {
                                      // Switch to cart tab
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 24.h),

              // Shop By Category Section
              SectionHeader(
                title: "Shop By Category",
                onSeeAllPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CategoriesScreen()),
                  );
                },
              ),

              SizedBox(
                height: ResponsiveUtil.spacing(
                    mobile: 100, tablet: 120, desktop: 140),
                child: Consumer(
                  builder: (context, ref, _) {
                    final categoryState = ref.watch(categoryProvider);

                    return categoryState.when(
                      loading: () => _buildCategoryShimmer(),
                      error: (error, _) =>
                          _buildErrorWidget("Failed to load categories"),
                      data: (categories) {
                        if (categories.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: Text(
                                "No categories available",
                                style: TextStyle(
                                  fontSize: ResponsiveUtil.fontSize(
                                      mobile: 14, tablet: 16, desktop: 16),
                                ),
                              ),
                            ),
                          );
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
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CategoryProductsScreen(
                                        category: category,
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: ResponsiveUtil.spacing(
                                          mobile: 30, tablet: 35, desktop: 40),
                                      backgroundColor: theme.colorScheme.primary
                                          .withOpacity(0.1),
                                      backgroundImage: category.imageUrl != null
                                          ? CachedNetworkImageProvider(
                                              category.imageUrl!)
                                          : null,
                                      child: category.imageUrl == null
                                          ? Icon(
                                              Icons.category,
                                              color: theme.colorScheme.primary,
                                              size: ResponsiveUtil.fontSize(
                                                  mobile: 24,
                                                  tablet: 28,
                                                  desktop: 32),
                                            )
                                          : null,
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      category.name,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        fontSize: ResponsiveUtil.fontSize(
                                            mobile: 12,
                                            tablet: 13,
                                            desktop: 14),
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
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

              SizedBox(height: 32.h),

              // App Info Banner
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.primaryColor,
                        theme.primaryColor.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Download Our App",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: ResponsiveUtil.fontSize(
                              mobile: 20, tablet: 24, desktop: 28),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Shop conveniently, track orders, and get exclusive app-only offers.",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontSize: ResponsiveUtil.fontSize(
                              mobile: 14, tablet: 16, desktop: 18),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: theme.primaryColor,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 8.h),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.apple,
                                      size: ResponsiveUtil.fontSize(
                                          mobile: 18, tablet: 20, desktop: 22)),
                                  SizedBox(width: 8.w),
                                  Text(
                                    "App Store",
                                    style: TextStyle(
                                      fontSize: ResponsiveUtil.fontSize(
                                          mobile: 12, tablet: 14, desktop: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: theme.primaryColor,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 8.h),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.android,
                                      size: ResponsiveUtil.fontSize(
                                          mobile: 18, tablet: 20, desktop: 22)),
                                  SizedBox(width: 8.w),
                                  Text(
                                    "Google Play",
                                    style: TextStyle(
                                      fontSize: ResponsiveUtil.fontSize(
                                          mobile: 12, tablet: 14, desktop: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerCarouselShimmer() {
    return SizedBox(
      height: ResponsiveUtil.spacing(mobile: 180, tablet: 220, desktop: 250),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  Widget _buildOfferCardsShimmer() {
    return SizedBox(
      height: ResponsiveUtil.spacing(mobile: 110, tablet: 130, desktop: 150),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: ResponsiveUtil.spacing(
                    mobile: 200, tablet: 220, desktop: 250),
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

  Widget _buildProductsShimmer() {
    return SizedBox(
      height: ResponsiveUtil.spacing(mobile: 255, tablet: 280, desktop: 320),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: ResponsiveUtil.spacing(
                    mobile: 180, tablet: 200, desktop: 220),
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

  Widget _buildPlaceholderBanner() {
    return Container(
      height: ResponsiveUtil.spacing(mobile: 180, tablet: 220, desktop: 250),
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size:
                  ResponsiveUtil.fontSize(mobile: 48, tablet: 56, desktop: 64),
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: 8.h),
            Text(
              "No offers available",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: ResponsiveUtil.fontSize(
                        mobile: 16, tablet: 18, desktop: 20),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryShimmer() {
    return SizedBox(
      height: ResponsiveUtil.spacing(mobile: 100, tablet: 120, desktop: 140),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: ResponsiveUtil.spacing(
                        mobile: 30, tablet: 35, desktop: 40),
                    backgroundColor: Colors.white,
                  ),
                  SizedBox(height: 8.h),
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
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      height: ResponsiveUtil.spacing(mobile: 120, tablet: 140, desktop: 160),
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12.r),
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
                  ResponsiveUtil.fontSize(mobile: 24, tablet: 28, desktop: 32),
            ),
            SizedBox(height: 6.h),
            Text(
              message,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: ResponsiveUtil.fontSize(
                    mobile: 14, tablet: 16, desktop: 18),
              ),
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: () {
                ref.read(productsProvider.notifier).fetchFeaturedProducts();
                ref.read(offerProvider.notifier).fetchOffers();
              },
              child: Text(
                "Retry",
                style: TextStyle(
                  fontSize: ResponsiveUtil.fontSize(
                      mobile: 14, tablet: 16, desktop: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
