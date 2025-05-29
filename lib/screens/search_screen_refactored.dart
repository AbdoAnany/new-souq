import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../core/config/app_config.dart';
import '../core/utils/responsive_helper.dart';
import '../domain/usecases/product_usecases.dart';
import '../models/product.dart';
import '../presentation/providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';
import 'product_details_screen.dart';
import 'package:shimmer/shimmer.dart';

class SearchScreenRefactored extends ConsumerStatefulWidget {
  final String? initialQuery;
  
  const SearchScreenRefactored({Key? key, this.initialQuery}) : super(key: key);

  @override
  ConsumerState<SearchScreenRefactored> createState() => _SearchScreenRefactoredState();
}

class _SearchScreenRefactoredState extends ConsumerState<SearchScreenRefactored> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  
  SearchProductsParams? _currentSearchParams;
  List<String> _recentSearches = [];
  bool _isLoadingMore = false;
  
  // Filters
  double _minPrice = 0;
  double _maxPrice = 10000;
  double _minRating = 0;
  String? _selectedCategory;
  String _sortBy = 'newest';
  
  @override
  void initState() {
    super.initState();
    
    // Initialize with query if provided
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch();
      });
    }
    
    _scrollController.addListener(_onScroll);
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreResults();
    }
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      ref.read(searchProductsNotifierProvider.notifier).clearResults();
      return;
    }

    final params = SearchProductsParams(
      query: query,
      categoryId: _selectedCategory,
      minPrice: _minPrice > 0 ? _minPrice : null,
      maxPrice: _maxPrice < 10000 ? _maxPrice : null,
      minRating: _minRating > 0 ? _minRating : null,
      page: 1,
      limit: ref.read(paginationLimitProvider),
      sortBy: _sortBy,
      descending: _sortBy.contains('desc'),
    );

    _currentSearchParams = params;
    ref.read(searchProductsNotifierProvider.notifier).search(params);
    _saveSearchQuery(query);
  }

  void _loadMoreResults() {
    if (!_isLoadingMore && _currentSearchParams != null) {
      final notifier = ref.read(searchProductsNotifierProvider.notifier);
      if (notifier.hasMore) {
        setState(() => _isLoadingMore = true);
        notifier.loadMoreResults().then((_) {
          if (mounted) {
            setState(() => _isLoadingMore = false);
          }
        });
      }
    }
  }

  void _saveSearchQuery(String query) {
    if (!_recentSearches.contains(query)) {
      setState(() {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 10) {
          _recentSearches.removeLast();
        }
      });
      // TODO: Save to local storage
    }
  }

  void _loadRecentSearches() {
    // TODO: Load from local storage
    setState(() {
      _recentSearches = ['headphones', 'laptop', 'smartphone', 'books'];
    });
  }

  void _showFiltersBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadiusLarge),
        ),
      ),
      builder: (context) => _buildFiltersSheet(),
    );
  }

  Widget _buildFiltersSheet() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
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
                        "Search Filters",
                        style: Theme.of(context).textTheme.titleLarge,
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
                        _buildPriceRangeSection(setModalState),
                        const SizedBox(height: 16),
                        _buildRatingSection(setModalState),
                        const SizedBox(height: 16),
                        _buildSortSection(setModalState),
                        const SizedBox(height: 16),
                        _buildCategorySection(setModalState),
                      ],
                    ),
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              _minPrice = 0;
                              _maxPrice = 10000;
                              _minRating = 0;
                              _selectedCategory = null;
                              _sortBy = 'newest';
                            });
                          },
                          child: const Text("Clear All"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _performSearch();
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

  Widget _buildPriceRangeSection(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Price Range",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: RangeValues(_minPrice, _maxPrice),
          min: 0,
          max: 10000,
          divisions: 100,
          labels: RangeLabels(
            '\$${_minPrice.round()}',
            '\$${_maxPrice.round()}',
          ),
          onChanged: (values) {
            setModalState(() {
              _minPrice = values.start;
              _maxPrice = values.end;
            });
          },
        ),
      ],
    );
  }

  Widget _buildRatingSection(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Minimum Rating",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Slider(
          value: _minRating,
          min: 0,
          max: 5,
          divisions: 5,
          label: '${_minRating.round()} stars',
          onChanged: (value) {
            setModalState(() {
              _minRating = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSortSection(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Sort By",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildSortChip("Newest", "newest", setModalState),
            _buildSortChip("Price: Low to High", "price_asc", setModalState),
            _buildSortChip("Price: High to Low", "price_desc", setModalState),
            _buildSortChip("Rating", "rating", setModalState),
            _buildSortChip("Popularity", "popularity", setModalState),
          ],
        ),
      ],
    );
  }

  Widget _buildSortChip(String label, String value, StateSetter setModalState) {
    final isSelected = _sortBy == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setModalState(() {
          _sortBy = value;
        });
      },
    );
  }

  Widget _buildCategorySection(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Category",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Consumer(
          builder: (context, ref, child) {
            final categoriesAsync = ref.watch(categoriesProvider);
            return categoriesAsync.when(
              data: (categories) => Wrap(
                spacing: 8,
                children: categories.map((category) {
                  final isSelected = _selectedCategory == category.id;
                  return FilterChip(
                    label: Text(category.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      setModalState(() {
                        _selectedCategory = selected ? category.id : null;
                      });
                    },
                  );
                }).toList(),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error loading categories: $error'),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveHelper.isDesktop();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Products"),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: "Search products...",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(searchProductsNotifierProvider.notifier).clearResults();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                      ),
                    ),
                    onSubmitted: (_) => _performSearch(),
                    onChanged: (value) {
                      setState(() {});
                      if (value.isEmpty) {
                        ref.read(searchProductsNotifierProvider.notifier).clearResults();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFiltersBottomSheet,
                ),
              ],
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final searchResults = ref.watch(searchProductsNotifierProvider);
    
    return searchResults.when(
      data: (products) {
        if (_searchController.text.isEmpty) {
          return _buildRecentSearches();
        }
        
        if (products.isEmpty) {
          return _buildNoResults();
        }
        
        return _buildSearchResults(products);
      },
      loading: () => _buildSearchShimmer(),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildSearchResults(List<Product> products) {
    final gridCount = ref.watch(gridCountProvider);
    
    return RefreshIndicator(
      onRefresh: () async {
        _performSearch();
      },
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridCount,
          childAspectRatio: ResponsiveHelper.getProductCardAspectRatio(),
          crossAxisSpacing: AppConstants.paddingSmall,
          mainAxisSpacing: AppConstants.paddingSmall,
        ),
        itemCount: products.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= products.length) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final product = products[index];
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
      ),
    );
  }

  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) {
      return const Center(
        child: Text("Start typing to search for products"),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recent Searches",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches.map((search) {
              return ActionChip(
                label: Text(search),
                onPressed: () {
                  _searchController.text = search;
                  _performSearch();
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "No results found",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            "Try different keywords or adjust filters",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            "Something went wrong",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _performSearch,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchShimmer() {
    final gridCount = ref.watch(gridCountProvider);
    
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridCount,
          childAspectRatio: ResponsiveHelper.getProductCardAspectRatio(),
          crossAxisSpacing: AppConstants.paddingSmall,
          mainAxisSpacing: AppConstants.paddingSmall,
        ),
        itemCount: 8,
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
