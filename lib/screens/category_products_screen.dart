import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:souq/core/constants/app_constants.dart';
import 'package:souq/models/category.dart';
import 'package:souq/models/product.dart';
import 'package:souq/providers/cart_provider.dart';
import 'package:souq/providers/product_provider.dart';
import 'package:souq/screens/cart_screen.dart';
import 'package:souq/screens/product_details_screen.dart';
import 'package:souq/utils/responsive_util.dart';
import 'package:souq/core/widgets/product_card.dart';

import '../core/widgets/my_app_bar.dart';

class CategoryProductsScreen extends ConsumerStatefulWidget {
  final Category category;

  const CategoryProductsScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  ConsumerState<CategoryProductsScreen> createState() =>
      _CategoryProductsScreenState();
}

class _CategoryProductsScreenState
    extends ConsumerState<CategoryProductsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasMoreProducts = true;
  List<Product> _products = [];
  String? _selectedSort;
  RangeValues _priceRange = const RangeValues(0, 10000);
  double _minRating = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMoreProducts) {
      _loadMoreProducts();
    }
  }

  void _applyFilters() {
    setState(() {
      _products = []; // Clear existing products
      _hasMoreProducts = true; // Reset pagination
    });
    _loadProducts(); // Reload with new filters
    Navigator.pop(context);
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final products =
          await ref.read(productServiceProvider).getProductsByCategory(
                categoryId: widget.category.id,
                minPrice: _priceRange.start,
                maxPrice: _priceRange.end,
                minRating: _minRating,
                sortBy: _selectedSort,
              );

      if (!mounted) return;

      setState(() {
        _products = products;
        _isLoading = false;
        _hasMoreProducts = products.length >= AppConstants.pageSize;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load products: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoading || !_hasMoreProducts || !mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final lastProduct = _products.isNotEmpty ? _products.last : null;

      final moreProducts =
          await ref.read(productServiceProvider).getProductsByCategory(
                categoryId: widget.category.id,
                lastProductId: lastProduct?.id,
                minPrice: _priceRange.start,
                maxPrice: _priceRange.end,
                minRating: _minRating,
                sortBy: _selectedSort,
              );

      if (!mounted) return;

      setState(() {
        _products.addAll(moreProducts);
        _isLoading = false;
        _hasMoreProducts = moreProducts.length >= AppConstants.pageSize;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load more products: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showFilterBottomSheet() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            ResponsiveUtil.spacing(
                mobile: AppConstants.borderRadiusLarge,
                tablet: 16,
                desktop: 20),
          ),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: EdgeInsets.all(
                    ResponsiveUtil.spacing(
                        mobile: AppConstants.paddingMedium,
                        tablet: 18,
                        desktop: 20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Filter Products",
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: ResponsiveUtil.fontSize(
                                  mobile: 18, tablet: 20, desktop: 22),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              size: ResponsiveUtil.iconSize(
                                  mobile: 24, tablet: 26, desktop: 28),
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const Divider(),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          children: [
                            // Price Range
                            Text(
                              "Price Range",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: ResponsiveUtil.fontSize(
                                    mobile: 16, tablet: 17, desktop: 18),
                              ),
                            ),
                            SizedBox(
                                height: ResponsiveUtil.spacing(
                                    mobile: 8, tablet: 10, desktop: 12)),
                            RangeSlider(
                              values: _priceRange,
                              min: 0,
                              max: 10000,
                              divisions: 100,
                              labels: RangeLabels(
                                "\$${_priceRange.start.round()}",
                                "\$${_priceRange.end.round()}",
                              ),
                              onChanged: (values) {
                                setState(() {
                                  _priceRange = values;
                                });
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "\$${_priceRange.start.round()}",
                                  style: TextStyle(
                                    fontSize: ResponsiveUtil.fontSize(
                                        mobile: 14, tablet: 15, desktop: 16),
                                  ),
                                ),
                                Text(
                                  "\$${_priceRange.end.round()}",
                                  style: TextStyle(
                                    fontSize: ResponsiveUtil.fontSize(
                                        mobile: 14, tablet: 15, desktop: 16),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                                height: ResponsiveUtil.spacing(
                                    mobile: 24, tablet: 28, desktop: 32)),

                            // Rating
                            Text(
                              "Minimum Rating",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: ResponsiveUtil.fontSize(
                                    mobile: 16, tablet: 17, desktop: 18),
                              ),
                            ),
                            SizedBox(
                                height: ResponsiveUtil.spacing(
                                    mobile: 8, tablet: 10, desktop: 12)),
                            Slider(
                              value: _minRating,
                              min: 0,
                              max: 5,
                              divisions: 5,
                              label: "${_minRating.round()}",
                              onChanged: (value) {
                                setState(() {
                                  _minRating = value;
                                });
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Any",
                                  style: TextStyle(
                                    fontSize: ResponsiveUtil.fontSize(
                                        mobile: 14, tablet: 15, desktop: 16),
                                  ),
                                ),
                                Row(
                                  children: List.generate(
                                    _minRating.round(),
                                    (index) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: ResponsiveUtil.iconSize(
                                          mobile: 16, tablet: 18, desktop: 20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                                height: ResponsiveUtil.spacing(
                                    mobile: 24, tablet: 28, desktop: 32)),

                            // Sort By
                            Text(
                              "Sort By",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: ResponsiveUtil.fontSize(
                                    mobile: 16, tablet: 17, desktop: 18),
                              ),
                            ),
                            SizedBox(
                                height: ResponsiveUtil.spacing(
                                    mobile: 8, tablet: 10, desktop: 12)),
                            Wrap(
                              spacing: ResponsiveUtil.spacing(
                                  mobile: 8, tablet: 10, desktop: 12),
                              runSpacing: ResponsiveUtil.spacing(
                                  mobile: 4, tablet: 6, desktop: 8),
                              children: [
                                _buildChip("Newest", "newest", setState),
                                _buildChip("Price: Low to High", "price_asc",
                                    setState),
                                _buildChip("Price: High to Low", "price_desc",
                                    setState),
                                _buildChip("Rating", "rating", setState),
                                _buildChip(
                                    "Popularity", "popularity", setState),
                              ],
                            ),
                            SizedBox(
                                height: ResponsiveUtil.spacing(
                                    mobile: 16, tablet: 18, desktop: 20)),
                          ],
                        ),
                      ),
                      const Divider(),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _priceRange = const RangeValues(0, 10000);
                                  _minRating = 0;
                                  _selectedSort = null;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: ResponsiveUtil.spacing(
                                      mobile: 12, tablet: 14, desktop: 16),
                                ),
                              ),
                              child: Text(
                                "Reset",
                                style: TextStyle(
                                  fontSize: ResponsiveUtil.fontSize(
                                      mobile: 14, tablet: 15, desktop: 16),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                              width: ResponsiveUtil.spacing(
                                  mobile: 16, tablet: 18, desktop: 20)),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _applyFilters,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: ResponsiveUtil.spacing(
                                      mobile: 12, tablet: 14, desktop: 16),
                                ),
                              ),
                              child: Text(
                                "Apply Filters",
                                style: TextStyle(
                                  fontSize: ResponsiveUtil.fontSize(
                                      mobile: 14, tablet: 15, desktop: 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildChip(String label, String value, StateSetter setState) {
    final theme = Theme.of(context);
    final isSelected = _selectedSort == value;

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize:
              ResponsiveUtil.fontSize(mobile: 12, tablet: 13, desktop: 14),
          color: isSelected ? theme.colorScheme.primary : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedSort = selected ? value : null;
        });
      },
      backgroundColor: theme.cardColor,
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: MyAppBar(
        title: Text(
          widget.category.name,
          style: TextStyle(
            fontSize:
                ResponsiveUtil.fontSize(mobile: 18, tablet: 20, desktop: 22),
          ),
        ),

        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              size:
                  ResponsiveUtil.iconSize(mobile: 24, tablet: 26, desktop: 28),
            ),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: _products.isEmpty && _isLoading
            ? _buildProductsShimmer()
            : _products.isEmpty
                ? Center(
                    child: Text(
                      "No products found in this category.",
                      style: TextStyle(
                        fontSize: ResponsiveUtil.fontSize(
                            mobile: 16, tablet: 18, desktop: 20),
                      ),
                    ),
                  )
                : GridView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(
                      ResponsiveUtil.spacing(
                          mobile: AppConstants.paddingMedium,
                          tablet: 18,
                          desktop: 20),
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveUtil.gridColumns(context),
                      childAspectRatio: ResponsiveUtil.isDesktop(context)
                          ? 0.7
                          : ResponsiveUtil.isTablet(context)
                              ? 0.68
                              : 0.65,
                      crossAxisSpacing: ResponsiveUtil.spacing(
                          mobile: 12, tablet: 14, desktop: 16),
                      mainAxisSpacing: ResponsiveUtil.spacing(
                          mobile: 12, tablet: 14, desktop: 16),
                    ),
                    itemCount: _products.length + (_hasMoreProducts ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= _products.length) {
                        return _buildLoadingIndicator();
                      }

                      final product = _products[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailsScreen(productId: product.id),
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
                        },
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: SizedBox(
        width: ResponsiveUtil.iconSize(mobile: 24, tablet: 28, desktop: 32),
        height: ResponsiveUtil.iconSize(mobile: 24, tablet: 28, desktop: 32),
        child: const CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildProductsShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        padding: EdgeInsets.all(
          ResponsiveUtil.spacing(
              mobile: AppConstants.paddingMedium, tablet: 18, desktop: 20),
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ResponsiveUtil.gridColumns(context),
          childAspectRatio: ResponsiveUtil.isDesktop(context)
              ? 0.7
              : ResponsiveUtil.isTablet(context)
                  ? 0.68
                  : 0.65,
          crossAxisSpacing:
              ResponsiveUtil.spacing(mobile: 12, tablet: 14, desktop: 16),
          mainAxisSpacing:
              ResponsiveUtil.spacing(mobile: 12, tablet: 14, desktop: 16),
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtil.spacing(
                    mobile: AppConstants.borderRadiusMedium,
                    tablet: 10,
                    desktop: 12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(
                          ResponsiveUtil.spacing(
                              mobile: AppConstants.borderRadiusMedium,
                              tablet: 10,
                              desktop: 12),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(
                      ResponsiveUtil.spacing(
                          mobile: 12, tablet: 14, desktop: 16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: ResponsiveUtil.fontSize(
                              mobile: 14, tablet: 15, desktop: 16),
                          width: double.infinity,
                          color: Colors.white,
                        ),
                        SizedBox(
                            height: ResponsiveUtil.spacing(
                                mobile: 8, tablet: 10, desktop: 12)),
                        Container(
                          height: ResponsiveUtil.fontSize(
                              mobile: 14, tablet: 15, desktop: 16),
                          width: ResponsiveUtil.spacing(
                              mobile: 80, tablet: 90, desktop: 100),
                          color: Colors.white,
                        ),
                        SizedBox(
                            height: ResponsiveUtil.spacing(
                                mobile: 8, tablet: 10, desktop: 12)),
                        Container(
                          height: ResponsiveUtil.fontSize(
                              mobile: 14, tablet: 15, desktop: 16),
                          width: ResponsiveUtil.spacing(
                              mobile: 60, tablet: 70, desktop: 80),
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
