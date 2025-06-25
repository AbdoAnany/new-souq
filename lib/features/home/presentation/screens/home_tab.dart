import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:souq/core/constants/app_constants.dart';
import 'package:souq/providers/product_provider.dart';
import 'package:souq/screens/notifications_screen.dart';
import 'package:souq/screens/wishlist_screen.dart';

import '../../../../core/import_core.dart';
import '../widgets/app_download_banner.dart';
import '../widgets/category_section.dart';
import '../widgets/enhanced_search_bar.dart' as enhanced_search;
import '../widgets/improved_offer_carousel.dart';
import '../widgets/product_section.dart';
import '../widgets/special_offers_section.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab>
    with TickerProviderStateMixin {
  late AnimationController _scrollAnimationController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _scrollAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Add scroll listener for header animation
    _scrollController.addListener(_onScroll);

    // Fetch data
    Future.microtask(() {
      ref.read(productsProvider.notifier).fetchFeaturedProducts();
      ref.read(categoryProvider.notifier).fetchCategories();
      ref.read(offerProvider.notifier).fetchOffers();
    });
  }

  @override
  void dispose() {
    _scrollAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final scrollOffset = _scrollController.offset;
      final maxScroll = 100.0; // Adjust this value as needed

      final animationValue = (scrollOffset / maxScroll).clamp(0.0, 1.0);
      _scrollAnimationController.value = animationValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Enhanced App Bar with gradient
      appBar: _buildEnhancedAppBar(),

      // Pull-to-refresh functionality
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        strokeWidth: 2.5,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Enhanced Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(vertical: 16.h), // Minimal top padding
                child: const enhanced_search.SearchBar(),
              ),
            ),

            // // Offer Carousel
            // const SliverToBoxAdapter(
            //   child: OfferCarousel(),
            // ),

            // Spacer
            SliverToBoxAdapter(
              child: SizedBox(height: 16.h),
            ),

            // Special Offers Section
            const SliverToBoxAdapter(
              child: SpecialOffersSection(),
            ),

            // Spacer
            SliverToBoxAdapter(
              child: SizedBox(height: 16.h),
            ),

            // Featured Products Section
            const SliverToBoxAdapter(
              child: ProductSection(
                title: "Featured Products",
                subtitle: "Handpicked just for you",
                onSeeAll: null, // Add navigation if needed
              ),
            ),

            // Spacer
            SliverToBoxAdapter(
              child: SizedBox(height: 16.h),
            ),

            // New Arrivals Section
            const SliverToBoxAdapter(
              child: ProductSection(
                title: "New Arrivals",
                subtitle: "Latest additions to our store",
                isNewArrivals: true,
                onSeeAll: null, // Add navigation if needed
              ),
            ),

            // Spacer
            SliverToBoxAdapter(
              child: SizedBox(height: 16.h),
            ),

            // Categories Section
            const SliverToBoxAdapter(
              child: CategorySection(),
            ),

            // App Download Banner
            const SliverToBoxAdapter(
              child: AppDownloadBanner(),
            ),

            // Bottom padding
            SliverToBoxAdapter(
              child: SizedBox(height: 32.h),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildEnhancedAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(60.h),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColorScheme.primary,
              AppColorScheme.primary.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColorScheme.primary.withOpacity(0.3),
              blurRadius: 10.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                // App Logo/Name
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.shopping_bag,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        AppConstants.appName,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Buttons
                _buildAppBarAction(
                  icon: Icons.notifications_outlined,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                _buildAppBarAction(
                  icon: Icons.favorite_border,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WishlistScreen(),
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

  Widget _buildAppBarAction({
    required IconData icon,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Stack(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 24.sp,
              ),
              if (badgeCount != null && badgeCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16.w,
                      minHeight: 16.h,
                    ),
                    child: Text(
                      badgeCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    try {
      await Future.wait([
        ref.read(productsProvider.notifier).fetchFeaturedProducts(),
        ref.read(offerProvider.notifier).fetchOffers(),
        ref.read(categoryProvider.notifier).fetchCategories(),
      ]);

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
                const Text("Content refreshed successfully"),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            margin: EdgeInsets.all(16.w),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                const Text("Failed to refresh content"),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            margin: EdgeInsets.all(16.w),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
