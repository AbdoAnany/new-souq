import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:souq/constants/app_constants.dart';
import 'package:souq/models/product.dart';
import 'package:souq/providers/cart_provider.dart';
import 'package:souq/providers/product_provider.dart';
import 'package:souq/widgets/custom_button.dart';
import 'package:souq/widgets/rating_stars.dart';
import 'package:souq/utils/formatter_util.dart';
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
  ConsumerState<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  int _quantity = 1;
  int _currentImageIndex = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();
  bool _isInWishlist = false;
  
  @override
  void initState() {
    super.initState();
    // Initialize product details
    Future.microtask(() {
      ref.read(productDetailsProvider(widget.productId).notifier).fetchProductDetails(widget.productId);
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
        content: Text(_isInWishlist ? "Added to wishlist" : "Removed from wishlist"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productAsyncValue = ref.watch(productDetailsProvider(widget.productId));
    
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            spreadRadius: 1,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: theme.iconTheme.color,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              spreadRadius: 1,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.shopping_cart_outlined,
                          color: theme.iconTheme.color,
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
                        children: [                          CarouselSlider(
                            carouselController: _carouselController,
                            options: CarouselOptions(
                              height: 300,
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
                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                          
                          // Image indicators
                          if (product.images.length > 1)
                            Positioned(
                              bottom: 10,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: product.images.asMap().entries.map((entry) {
                                  return GestureDetector(
                                    onTap: () => _carouselController.animateToPage(entry.key),
                                    child: Container(
                                      width: 8.0,
                                      height: 8.0,
                                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
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
                            right: 16,
                            top: 16,
                            child: InkWell(
                              onTap: _toggleWishlist,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      spreadRadius: 1,
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _isInWishlist ? Icons.favorite : Icons.favorite_border,
                                  color: _isInWishlist ? Colors.red : theme.iconTheme.color,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Product Info
                      Padding(
                        padding: const EdgeInsets.all(AppConstants.paddingMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category
                            Text(
                              product.category.toUpperCase(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            
                            // Product Name
                            Text(
                              product.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Rating
                            Row(
                              children: [
                                RatingStars(
                                  rating: product.rating,
                                  size: 20,
                                  reviewCount: product.reviewCount,
                                ),
                                if (product.reviewCount > 0) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    "(${product.reviewCount} ${product.reviewCount == 1 ? 'review' : 'reviews'})",
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppConstants.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Price
                            Row(
                              children: [
                                Text(
                                  FormatterUtil.formatCurrency(product.price),
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: product.hasDiscount ? theme.primaryColor : null,
                                  ),
                                ),
                                if (product.hasDiscount) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    FormatterUtil.formatCurrency(product.originalPrice!),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      color: AppConstants.textSecondaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                                    ),
                                    child: Text(
                                      "${(((product.originalPrice! - product.price) / product.originalPrice!) * 100).round()}% OFF",
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            
                            // Stock Status
                            Row(
                              children: [
                                Icon(
                                  product.inStock ? Icons.check_circle : Icons.cancel,
                                  color: product.inStock ? Colors.green : Colors.red,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  product.inStock ? AppStrings.inStock : AppStrings.outOfStock,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: product.inStock ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // Description
                            Text(
                              AppStrings.description,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.description,
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 24),
                            
                            // Add to Cart Section
                            Row(
                              children: [
                                // Quantity Selector
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: theme.dividerColor),
                                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: _decrementQuantity,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: SizedBox(
                                          width: 30,
                                          child: Text(
                                            _quantity.toString(),
                                            textAlign: TextAlign.center,
                                            style: theme.textTheme.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: _incrementQuantity,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(width: 16),
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
                            
                            const SizedBox(height: 16),
                            
                            // Buy Now Button
                            CustomButton(
                              text: AppStrings.buyNow,
                              onPressed: product.inStock
                                  ? () {
                                      _addToCart(product);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const CartScreen(),
                                        ),
                                      );
                                    }
                                  : () {}, // Provide empty function instead of null
                              color: AppConstants.secondaryColor,
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Product Details / Specifications
                            Text(
                              "Specifications",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Display specifications if available
                            if (product.specifications.isNotEmpty)
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: product.specifications.length,
                                itemBuilder: (context, index) {
                                  final specKey = product.specifications.keys.elementAt(index);
                                  final specValue = product.specifications[specKey];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 100,
                                          child: Text(
                                            "$specKey:",
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: AppConstants.textSecondaryColor,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            specValue.toString(),
                                            style: theme.textTheme.bodyMedium,
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
                                ),
                              ),
                              
                            const SizedBox(height: 24),
                            
                            // Reviews
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppStrings.reviews,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
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
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            
                            // Display reviews placeholder
                            product.reviewCount > 0
                                ? const Text("Reviews will be displayed here")
                                : Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.rate_review_outlined,
                                            size: 48,
                                            color: theme.dividerColor,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "No reviews yet",
                                            style: theme.textTheme.bodyLarge?.copyWith(
                                              color: AppConstants.textSecondaryColor,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ElevatedButton(
                                            onPressed: () {
                                              // Add review logic
                                            },
                                            child: const Text("Write a Review"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                            const SizedBox(height: 32),
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
                const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  "Error loading product details",
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    ref.read(productDetailsProvider(widget.productId).notifier).fetchProductDetails(widget.productId);
                  },
                  child: const Text("Retry"),
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
              height: 300,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 100,
                    height: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: double.infinity,
                    height: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 150,
                    height: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: double.infinity,
                    height: 120,
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
