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
import 'package:souq/core/widgets/product_card.dart';

import '../core/widgets/my_app_bar.dart';

class CategoryProductsScreen extends ConsumerStatefulWidget {
  final Category category;

  const CategoryProductsScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  ConsumerState<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends ConsumerState<CategoryProductsScreen> {
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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
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
      final products = await ref.read(productServiceProvider).getProductsByCategory(
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
      
      final moreProducts = await ref.read(productServiceProvider).getProductsByCategory(
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadiusLarge),
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
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Filter Products",
                            style: theme.textTheme.titleLarge,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
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
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
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
                                Text("\$${_priceRange.start.round()}"),
                                Text("\$${_priceRange.end.round()}"),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // Rating
                            Text(
                              "Minimum Rating",
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
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
                                const Text("Any"),
                                Row(
                                  children: List.generate(
                                    _minRating.round(),
                                    (index) => const Icon(Icons.star, color: Colors.amber, size: 16),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // Sort By
                            Text(
                              "Sort By",
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                _buildChip("Newest", "newest", setState),
                                _buildChip("Price: Low to High", "price_asc", setState),
                                _buildChip("Price: High to Low", "price_desc", setState),
                                _buildChip("Rating", "rating", setState),
                                _buildChip("Popularity", "popularity", setState),
                              ],
                            ),
                            const SizedBox(height: 16),
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
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text("Reset"),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _applyFilters,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text("Apply Filters"),
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
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedSort = selected ? value : null;
        });
      },
      backgroundColor: theme.cardColor,
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.primary : null,
        fontWeight: isSelected ? FontWeight.bold : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: MyAppBar(
        title: Text(widget.category.name),

        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: _products.isEmpty && _isLoading
            ? _buildProductsShimmer()
            : _products.isEmpty
                ? const Center(
                    child: Text("No products found in this category."),
                  )
                : GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
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
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildProductsShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppConstants.borderRadiusMedium),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 14,
                          width: double.infinity,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 14,
                          width: 80,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 14,
                          width: 60,
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
