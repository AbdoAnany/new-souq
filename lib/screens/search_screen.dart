import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:souq/constants/app_constants.dart';
import 'package:souq/models/product.dart';
import 'package:souq/providers/product_provider.dart';
import 'package:souq/providers/cart_provider.dart';
import 'package:souq/screens/product_details_screen.dart';
import 'package:souq/widgets/product_card.dart';
import 'package:shimmer/shimmer.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;
  
  const SearchScreen({Key? key, this.initialQuery}) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Product> _searchResults = [];
  bool _isLoading = false;
  Map<String, dynamic> _filters = {};
  List<String> _recentSearches = [];
  
  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch(widget.initialQuery!);
      });
    } else {
      _loadRecentSearches();
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    // In a real app, this would come from shared preferences or a database
    setState(() {
      _recentSearches = [
        "Smartphones",
        "Laptops",
        "Headphones",
        "Smart watches",
        "Cameras"
      ];
    });
  }

  void _saveSearchQuery(String query) {
    if (query.isEmpty) return;
    
    setState(() {
      _recentSearches.removeWhere((element) => element == query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.sublist(0, 10);
      }
    });
    
    // In a real app, save to shared preferences or database
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Store the search query for history
      _saveSearchQuery(query);
        // Perform the search
      final results = await ref
          .read(productServiceProvider)
          .searchProducts(
            query: query,
            minPrice: _filters['minPrice']?.toDouble(),
            maxPrice: _filters['maxPrice']?.toDouble(),
            minRating: _filters['minRating']?.toDouble(),
            sortBy: _filters['sortBy']?.toString(),
            sortDescending: _filters['sortDescending'] as bool?,
            categoryId: _filters['categoryId']?.toString(),
          );
      
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showFilterDialog() {
    // Initialize filter values
    String? selectedCategory;
    RangeValues priceRange = const RangeValues(0, 10000);
    double minRating = 0;
    String? sortBy;
    bool sortDescending = false;
    
    // If filters exist, set the values
    if (_filters.isNotEmpty) {
      selectedCategory = _filters['categoryId'];
      
      if (_filters.containsKey('minPrice') && _filters.containsKey('maxPrice')) {
        priceRange = RangeValues(
          _filters['minPrice'].toDouble(),
          _filters['maxPrice'].toDouble(),
        );
      }
      
      minRating = _filters['minRating']?.toDouble() ?? 0;
      sortBy = _filters['sortBy'];
      sortDescending = _filters['sortDescending'] ?? false;
    }

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
            return Container(
              padding: EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Filter Search",
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
                      children: [
                        const Text("Price Range"),
                        const SizedBox(height: 8),
                        RangeSlider(
                          values: priceRange,
                          min: 0,
                          max: 10000,
                          divisions: 100,
                          labels: RangeLabels(
                            "\$${priceRange.start.round()}",
                            "\$${priceRange.end.round()}",
                          ),
                          onChanged: (values) {
                            setState(() {
                              priceRange = values;
                            });
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("\$${priceRange.start.round()}"),
                            Text("\$${priceRange.end.round()}"),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        const Text("Minimum Rating"),
                        const SizedBox(height: 8),
                        Slider(
                          value: minRating,
                          min: 0,
                          max: 5,
                          divisions: 5,
                          label: "$minRating",
                          onChanged: (value) {
                            setState(() {
                              minRating = value;
                            });
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Any"),
                            Row(
                              children: List.generate(
                                minRating.round(),
                                (index) => const Icon(Icons.star, color: Colors.amber, size: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        const Text("Sort By"),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildFilterChip(
                              "Relevance",
                              sortBy == null,
                              () {
                                setState(() {
                                  sortBy = null;
                                });
                              },
                            ),
                            _buildFilterChip(
                              "Price: Low to High",
                              sortBy == "price" && !sortDescending,
                              () {
                                setState(() {
                                  sortBy = "price";
                                  sortDescending = false;
                                });
                              },
                            ),
                            _buildFilterChip(
                              "Price: High to Low",
                              sortBy == "price" && sortDescending,
                              () {
                                setState(() {
                                  sortBy = "price";
                                  sortDescending = true;
                                });
                              },
                            ),
                            _buildFilterChip(
                              "Rating",
                              sortBy == "rating",
                              () {
                                setState(() {
                                  sortBy = "rating";
                                  sortDescending = true;
                                });
                              },
                            ),
                            _buildFilterChip(
                              "Newest",
                              sortBy == "createdAt",
                              () {
                                setState(() {
                                  sortBy = "createdAt";
                                  sortDescending = true;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Clear filters and re-search
                            this.setState(() {
                              _filters = {};
                            });
                            _performSearch(_searchController.text);
                          },
                          child: const Text("Clear Filters"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                              // Apply the filters
                            final newFilters = <String, dynamic>{
                              'minPrice': priceRange.start,
                              'maxPrice': priceRange.end,
                              'minRating': minRating,
                            };
                            
                            if (sortBy != null) {
                              newFilters['sortBy'] = sortBy;
                              newFilters['sortDescending'] = sortDescending;
                            }
                            
                            if (selectedCategory != null) {
                              newFilters['categoryId'] = selectedCategory;
                            }
                            
                            this.setState(() {
                              _filters = newFilters;
                            });
                            
                            // Re-search with new filters
                            _performSearch(_searchController.text);
                          },
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
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context);
    
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
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
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: "Search products...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey[400]),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchResults = [];
                      });
                      _searchFocusNode.requestFocus();
                    },
                  ),
          ),
          onSubmitted: _performSearch,
          textInputAction: TextInputAction.search,
          autofocus: widget.initialQuery == null,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _searchResults.isEmpty ? null : _showFilterDialog,
          ),
        ],
        automaticallyImplyLeading: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildSearchShimmer();
    }
    
    if (_searchResults.isEmpty) {
      return _searchController.text.isEmpty
          ? _buildRecentSearches()
          : _buildNoResults();
    }
    
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,      mainAxisSpacing: 12,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final product = _searchResults[index];
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
                    // Navigate to cart
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNoResults() {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "No results found",
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            "Try different keywords or filters",
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recent Searches",
                style: theme.textTheme.titleMedium,
              ),
              if (_recentSearches.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _recentSearches = [];
                    });
                    // In a real app, clear from shared preferences or database
                  },
                  child: const Text("Clear All"),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _recentSearches.isEmpty
                ? Center(
                    child: Text(
                      "No recent searches",
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _recentSearches.length,
                    itemBuilder: (context, index) {
                      final search = _recentSearches[index];
                      return ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(search),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () {
                            setState(() {
                              _recentSearches.removeAt(index);
                            });
                            // In a real app, update shared preferences or database
                          },
                        ),
                        onTap: () {
                          _searchController.text = search;
                          _performSearch(search);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchShimmer() {
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
