import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/core/constants/app_constants.dart';
import 'package:souq/models/product.dart';
import 'package:souq/providers/product_provider.dart';
import 'package:souq/providers/cart_provider.dart';
import 'package:souq/screens/product_details_screen.dart';
import 'package:souq/utils/responsive_util.dart';
import '/core/widgets/product_card.dart';
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
      final results = await ref.read(productServiceProvider).searchProducts(
            query: query,
            minPrice: _filters['minPrice']?.toDouble(),
            maxPrice: _filters['maxPrice']?.toDouble(),
            minRating: _filters['minRating']?.toDouble(),
            sortBy: _filters['sortBy']?.toString(),
            // sortDescending: _filters['sortDescending'] as bool?,
            // categoryId: _filters['categoryId']?.toString(),
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

      if (_filters.containsKey('minPrice') &&
          _filters.containsKey('maxPrice')) {
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
                top:
                    ResponsiveUtil.spacing(mobile: 16, tablet: 20, desktop: 24),
                left:
                    ResponsiveUtil.spacing(mobile: 16, tablet: 20, desktop: 24),
                right:
                    ResponsiveUtil.spacing(mobile: 16, tablet: 20, desktop: 24),
                bottom: ResponsiveUtil.spacing(
                        mobile: 16, tablet: 20, desktop: 24) +
                    MediaQuery.of(context).viewInsets.bottom,
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
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: ResponsiveUtil.fontSize(
                              mobile: 20, tablet: 22, desktop: 24),
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
                      children: [
                        Text(
                          "Price Range",
                          style: TextStyle(
                            fontSize: ResponsiveUtil.fontSize(
                                mobile: 16, tablet: 18, desktop: 20),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),
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
                            Text(
                              "\$${priceRange.start.round()}",
                              style: TextStyle(
                                fontSize: ResponsiveUtil.fontSize(
                                    mobile: 14, tablet: 15, desktop: 16),
                              ),
                            ),
                            Text(
                              "\$${priceRange.end.round()}",
                              style: TextStyle(
                                fontSize: ResponsiveUtil.fontSize(
                                    mobile: 14, tablet: 15, desktop: 16),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          "Minimum Rating",
                          style: TextStyle(
                            fontSize: ResponsiveUtil.fontSize(
                                mobile: 16, tablet: 18, desktop: 20),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),
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
                            Text(
                              "Any",
                              style: TextStyle(
                                fontSize: ResponsiveUtil.fontSize(
                                    mobile: 14, tablet: 15, desktop: 16),
                              ),
                            ),
                            Row(
                              children: List.generate(
                                minRating.round(),
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
                        SizedBox(height: 16.h),
                        Text(
                          "Sort By",
                          style: TextStyle(
                            fontSize: ResponsiveUtil.fontSize(
                                mobile: 16, tablet: 18, desktop: 20),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: ResponsiveUtil.spacing(
                              mobile: 8, tablet: 10, desktop: 12),
                          runSpacing: ResponsiveUtil.spacing(
                              mobile: 8, tablet: 10, desktop: 12),
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
                          child: Text(
                            "Clear Filters",
                            style: TextStyle(
                              fontSize: ResponsiveUtil.fontSize(
                                  mobile: 14, tablet: 15, desktop: 16),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
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
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context);

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize:
              ResponsiveUtil.fontSize(mobile: 12, tablet: 13, desktop: 14),
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: theme.cardColor,
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.primary : null,
        fontWeight: isSelected ? FontWeight.bold : null,
        fontSize: ResponsiveUtil.fontSize(mobile: 12, tablet: 13, desktop: 14),
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
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize:
                  ResponsiveUtil.fontSize(mobile: 16, tablet: 17, desktop: 18),
            ),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: ResponsiveUtil.iconSize(
                          mobile: 20, tablet: 22, desktop: 24),
                    ),
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
            icon: Icon(
              Icons.filter_list,
              size:
                  ResponsiveUtil.iconSize(mobile: 24, tablet: 26, desktop: 28),
            ),
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
      padding: EdgeInsets.all(
          ResponsiveUtil.spacing(mobile: 16, tablet: 20, desktop: 24)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveUtil.gridColumns(context),
        childAspectRatio: ResponsiveUtil.isDesktop(context)
            ? 0.7
            : ResponsiveUtil.isTablet(context)
                ? 0.68
                : 0.65,
        crossAxisSpacing:
            ResponsiveUtil.spacing(mobile: 12, tablet: 16, desktop: 20),
        mainAxisSpacing:
            ResponsiveUtil.spacing(mobile: 12, tablet: 16, desktop: 20),
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
                builder: (context) =>
                    ProductDetailsScreen(productId: product.id),
              ),
            );
          },
          onAddToCart: () {
            ref.read(cartProvider.notifier).addToCart(product, 1);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "${product.name} added to cart",
                  style: TextStyle(
                    fontSize: ResponsiveUtil.fontSize(
                        mobile: 14, tablet: 15, desktop: 16),
                  ),
                ),
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
      child: Padding(
        padding: EdgeInsets.all(
            ResponsiveUtil.spacing(mobile: 16, tablet: 20, desktop: 24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size:
                  ResponsiveUtil.iconSize(mobile: 80, tablet: 90, desktop: 100),
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            SizedBox(height: 16.h),
            Text(
              "No results found",
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: ResponsiveUtil.fontSize(
                    mobile: 18, tablet: 20, desktop: 22),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Try different keywords or filters",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
                fontSize: ResponsiveUtil.fontSize(
                    mobile: 14, tablet: 15, desktop: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(
          ResponsiveUtil.spacing(mobile: 16, tablet: 20, desktop: 24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recent Searches",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: ResponsiveUtil.fontSize(
                      mobile: 16, tablet: 18, desktop: 20),
                ),
              ),
              if (_recentSearches.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _recentSearches = [];
                    });
                    // In a real app, clear from shared preferences or database
                  },
                  child: Text(
                    "Clear All",
                    style: TextStyle(
                      fontSize: ResponsiveUtil.fontSize(
                          mobile: 14, tablet: 15, desktop: 16),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: _recentSearches.isEmpty
                ? Center(
                    child: Text(
                      "No recent searches",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                        fontSize: ResponsiveUtil.fontSize(
                            mobile: 14, tablet: 15, desktop: 16),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _recentSearches.length,
                    itemBuilder: (context, index) {
                      final search = _recentSearches[index];
                      return ListTile(
                        leading: Icon(
                          Icons.history,
                          size: ResponsiveUtil.iconSize(
                              mobile: 20, tablet: 22, desktop: 24),
                        ),
                        title: Text(
                          search,
                          style: TextStyle(
                            fontSize: ResponsiveUtil.fontSize(
                                mobile: 16, tablet: 17, desktop: 18),
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.close,
                            size: ResponsiveUtil.iconSize(
                                mobile: 16, tablet: 18, desktop: 20),
                          ),
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
        padding: EdgeInsets.all(
            ResponsiveUtil.spacing(mobile: 16, tablet: 20, desktop: 24)),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ResponsiveUtil.gridColumns(context),
          childAspectRatio: ResponsiveUtil.isDesktop(context)
              ? 0.7
              : ResponsiveUtil.isTablet(context)
                  ? 0.68
                  : 0.65,
          crossAxisSpacing:
              ResponsiveUtil.spacing(mobile: 12, tablet: 16, desktop: 20),
          mainAxisSpacing:
              ResponsiveUtil.spacing(mobile: 12, tablet: 16, desktop: 20),
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  ResponsiveUtil.spacing(mobile: 8, tablet: 10, desktop: 12)),
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
                        top: Radius.circular(ResponsiveUtil.spacing(
                            mobile: 8, tablet: 10, desktop: 12)),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(ResponsiveUtil.spacing(
                        mobile: 12, tablet: 14, desktop: 16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 14.h,
                          width: double.infinity,
                          color: Colors.white,
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          height: 14.h,
                          width: 80.w,
                          color: Colors.white,
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          height: 14.h,
                          width: 60.w,
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
