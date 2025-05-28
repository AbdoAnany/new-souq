import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel_slider;
import 'package:souq/constants/app_constants.dart';
import 'package:souq/models/offer.dart';
import 'package:souq/models/product.dart';
import 'package:souq/providers/product_provider.dart';
import 'package:souq/providers/auth_provider.dart';
import 'package:souq/providers/cart_provider.dart';
import 'package:souq/screens/product_details_screen.dart';
import 'package:souq/screens/offers_screen.dart';
import 'package:souq/screens/notifications_screen.dart';
import 'package:souq/screens/wishlist_screen.dart';
import 'package:souq/screens/search_screen.dart';
import 'package:souq/screens/categories_screen.dart';
import 'package:souq/screens/category_products_screen.dart';
import 'package:souq/widgets/product_card.dart';
import 'package:souq/widgets/section_header.dart';
import 'package:souq/widgets/offer_card.dart';
import 'package:souq/utils/size_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  int _currentCarouselSlide = 0;
  final carousel_slider.CarouselController _carouselController = carousel_slider.CarouselController();

  @override
  void initState() {
    super.initState();
    // Ensure we fetch featured products
    ref.read(productsProvider.notifier).fetchFeaturedProducts();
    // Fetch offers
    ref.read(offerProvider.notifier).fetchOffers();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final theme = Theme.of(context);
    final productsState = ref.watch(productsProvider);
    final offersState = ref.watch(offerProvider);
    final authState = ref.watch(authProvider);
    
    final user = authState.value;
    final userName = user != null ? "${user.firstName}" : "Guest";
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WishlistScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: AppConstants.paddingSmall,
                ),
                child: Text(
                  "Hello, $userName! 👋",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: AppConstants.paddingSmall,
                ),                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMedium,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                      border: Border.all(color: theme.dividerColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: theme.iconTheme.color,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.search,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Banner Carousel
              offersState.when(
                loading: () => _buildBannerCarouselShimmer(),
                error: (error, stackTrace) => _buildErrorWidget("Failed to load offers"),
                data: (offers) {
                  if (offers.isEmpty) {
                    return _buildPlaceholderBanner();
                  }
                  
                  return Column(
                    children: [
                      carousel_slider.CarouselSlider(
                        carouselController: _carouselController,
                        options: carousel_slider.CarouselOptions(
                          height: 180,
                          viewportFraction: 0.92,
                          enlargeCenterPage: true,
                          enableInfiniteScroll: offers.length > 1,
                          autoPlay: offers.length > 1,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentCarouselSlide = index;
                            });
                          },
                        ),
                        items: offers.map((offer) => OfferCard(offer: offer)).toList(),
                      ),
                      if (offers.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: offers.asMap().entries.map((entry) {
                              return GestureDetector(
                                onTap: () => _carouselController.animateToPage(entry.key),
                                child: Container(
                                  width: 8.0,
                                  height: 8.0,
                                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
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

              const SizedBox(height: 24),

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
                error: (error, stackTrace) => _buildErrorWidget("Failed to load offers"),
                data: (offers) {
                  if (offers.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("No special offers available right now"),
                      ),
                    );
                  }
                  
                  return SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: offers.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
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

              const SizedBox(height: 24),

              // Featured Products
              SectionHeader(
                title: "Featured Products",
                onSeeAllPressed: () {
                  // Navigate to featured products page
                },
              ),

              productsState.when(
                loading: () => _buildProductsShimmer(),
                error: (error, stackTrace) => _buildErrorWidget("Failed to load products"),
                data: (products) {
                  if (products.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("No featured products available"),
                      ),
                    );
                  }
                  
                  return SizedBox(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ProductCard(
                            product: product,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailsScreen(productId: product.id),
                                ),
                              );
                            },
                            onAddToCart: () {
                              ref.read(cartProvider.notifier).addToCart(product, 1);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("${product.name} added to cart"),
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

              const SizedBox(height: 24),

              // New Arrivals
              SectionHeader(
                title: "New Arrivals",
                onSeeAllPressed: () {
                  // Navigate to new arrivals page
                },
              ),

              productsState.when(
                loading: () => _buildProductsShimmer(),
                error: (error, stackTrace) => _buildErrorWidget("Failed to load products"),
                data: (products) {
                  if (products.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("No new arrivals available"),
                      ),
                    );
                  }
                  
                  // Just use the first few products for demo purposes
                  final newProducts = products.take(5).toList();
                  
                  return SizedBox(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: newProducts.length,
                      itemBuilder: (context, index) {
                        final product = newProducts[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ProductCard(
                            product: product,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailsScreen(productId: product.id),
                                ),
                              );
                            },
                            onAddToCart: () {
                              ref.read(cartProvider.notifier).addToCart(product, 1);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("${product.name} added to cart"),
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
              ),              const SizedBox(height: 24),

              // Shop By Category Section
              SectionHeader(
                title: "Shop By Category",
                onSeeAllPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CategoriesScreen()),
                  );
                },
              ),

              SizedBox(
                height: 100,
                child: Consumer(
                  builder: (context, ref, _) {
                    final categoryState = ref.watch(categoryProvider);
                    
                    return categoryState.when(
                      loading: () => _buildCategoryShimmer(),
                      error: (error, _) => _buildErrorWidget("Failed to load categories"),
                      data: (categories) {
                        if (categories.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text("No categories available"),
                            ),
                          );
                        }
                        
                        final parentCategories = categories
                            .where((cat) => cat.isParentCategory)
                            .toList();
                        
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: parentCategories.length,
                          itemBuilder: (context, index) {
                            final category = parentCategories[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
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
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                      backgroundImage: category.imageUrl != null
                                          ? CachedNetworkImageProvider(category.imageUrl!)
                                          : null,
                                      child: category.imageUrl == null
                                          ? Icon(
                                              Icons.category,
                                              color: theme.colorScheme.primary,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      category.name,
                                      style: theme.textTheme.bodySmall,
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

              const SizedBox(height: 32),

              // App Info Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.primaryColor,
                        theme.primaryColor.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Download Our App",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Shop conveniently, track orders, and get exclusive app-only offers.",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: theme.primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.apple),
                                SizedBox(width: 8),
                                Text("App Store"),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: theme.primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.android),
                                SizedBox(width: 8),
                                Text("Google Play"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerCarouselShimmer() {
    return SizedBox(
      height: 180,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
        ),
      ),
    );
  }

  Widget _buildOfferCardsShimmer() {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
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
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
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
      height: 180,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              "No offers available",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryShimmer() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 60,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
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
      height: 120,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.red.shade700),
            ),
            TextButton(
              onPressed: () {
                ref.read(productsProvider.notifier).fetchFeaturedProducts();
                ref.read(offerProvider.notifier).fetchOffers();
              },
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
