import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/widgets/my_app_bar.dart';
import '../../models/product.dart';
import '../../providers/admin_provider.dart';
import '../../utils/responsive_util.dart';
import 'widgets/product_form_dialog.dart';

class AdminProductsScreen extends ConsumerStatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  ConsumerState<AdminProductsScreen> createState() =>
      _AdminProductsScreenState();
}

class _AdminProductsScreenState extends ConsumerState<AdminProductsScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    // Load products when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProductsProvider.notifier).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(adminProductsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: MyAppBar(
        title: Text(
          'Manage Products',
          style: TextStyle(
            fontSize: ResponsiveUtil.fontSize(
              mobile: 18,
              tablet: 20,
              desktop: 22,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              size: ResponsiveUtil.iconSize(
                mobile: 24,
                tablet: 26,
                desktop: 28,
              ),
            ),
            onPressed: () {
              ref.read(adminProductsProvider.notifier).fetchProducts();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: EdgeInsets.all(ResponsiveUtil.spacing(
              mobile: 16,
              tablet: 20,
              desktop: 24,
            )),
            color: theme.cardColor,
            child: Column(
              children: [
                // Search Field
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    hintStyle: TextStyle(
                      fontSize: ResponsiveUtil.fontSize(
                        mobile: 14,
                        tablet: 15,
                        desktop: 16,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: ResponsiveUtil.iconSize(
                        mobile: 20,
                        tablet: 22,
                        desktop: 24,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusMedium),
                    ),
                    filled: true,
                    fillColor: AppConstants.backgroundColor,
                  ),
                  style: TextStyle(
                    fontSize: ResponsiveUtil.fontSize(
                      mobile: 14,
                      tablet: 15,
                      desktop: 16,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
                SizedBox(
                    height: ResponsiveUtil.spacing(
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                )),
                // Category Filter
                Row(
                  children: [
                    Text(
                      'Category: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveUtil.fontSize(
                          mobile: 14,
                          tablet: 15,
                          desktop: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        style: TextStyle(
                          fontSize: ResponsiveUtil.fontSize(
                            mobile: 14,
                            tablet: 15,
                            desktop: 16,
                          ),
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                        items: ['All', ...AppConstants.productCategories]
                            .map((category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Products List
          Expanded(
            child: productsState.when(
              data: (products) {
                final filteredProducts = products.where((product) {
                  final matchesSearch = product.name
                          .toLowerCase()
                          .contains(_searchQuery) ||
                      product.description.toLowerCase().contains(_searchQuery);
                  final matchesCategory = _selectedCategory == 'All' ||
                      product.categoryId == _selectedCategory;
                  return matchesSearch && matchesCategory;
                }).toList();

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: ResponsiveUtil.iconSize(
                            mobile: 64,
                            tablet: 72,
                            desktop: 80,
                          ),
                          color: Colors.grey[400],
                        ),
                        SizedBox(
                            height: ResponsiveUtil.spacing(
                          mobile: 16,
                          tablet: 18,
                          desktop: 20,
                        )),
                        Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: ResponsiveUtil.fontSize(
                              mobile: 18,
                              tablet: 20,
                              desktop: 22,
                            ),
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(
                            height: ResponsiveUtil.spacing(
                          mobile: 8,
                          tablet: 10,
                          desktop: 12,
                        )),
                        Text(
                          'Add some products to get started',
                          style: TextStyle(
                            fontSize: ResponsiveUtil.fontSize(
                              mobile: 14,
                              tablet: 15,
                              desktop: 16,
                            ),
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return _buildProductCard(product);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: ResponsiveUtil.iconSize(
                        mobile: 64,
                        tablet: 72,
                        desktop: 80,
                      ),
                      color: AppConstants.errorColor,
                    ),
                    SizedBox(
                        height: ResponsiveUtil.spacing(
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    )),
                    Text(
                      'Error loading products',
                      style: TextStyle(
                        fontSize: ResponsiveUtil.fontSize(
                          mobile: 18,
                          tablet: 20,
                          desktop: 22,
                        ),
                        color: AppConstants.errorColor,
                      ),
                    ),
                    SizedBox(
                        height: ResponsiveUtil.spacing(
                      mobile: 8,
                      tablet: 10,
                      desktop: 12,
                    )),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: ResponsiveUtil.fontSize(
                          mobile: 14,
                          tablet: 15,
                          desktop: 16,
                        ),
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(
                        height: ResponsiveUtil.spacing(
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    )),
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(adminProductsProvider.notifier)
                            .fetchProducts();
                      },
                      child: Text(
                        'Try Again',
                        style: TextStyle(
                          fontSize: ResponsiveUtil.fontSize(
                            mobile: 14,
                            tablet: 15,
                            desktop: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        onPressed: () => _showProductDialog(context),
        child: Icon(
          Icons.add,
          size: ResponsiveUtil.iconSize(
            mobile: 24,
            tablet: 26,
            desktop: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final imageSize = ResponsiveUtil.spacing(
      mobile: 80,
      tablet: 90,
      desktop: 100,
    );

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtil.spacing(
          mobile: 16,
          tablet: 20,
          desktop: 24,
        ),
        vertical: ResponsiveUtil.spacing(
          mobile: 8,
          tablet: 10,
          desktop: 12,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtil.spacing(
          mobile: 16,
          tablet: 18,
          desktop: 20,
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadiusMedium),
                  child: Image.network(
                    product.images.first,
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: imageSize,
                        height: imageSize,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.image_not_supported,
                          size: ResponsiveUtil.iconSize(
                            mobile: 24,
                            tablet: 26,
                            desktop: 28,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                    width: ResponsiveUtil.spacing(
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                )),
                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: TextStyle(
                                fontSize: ResponsiveUtil.fontSize(
                                  mobile: 16,
                                  tablet: 17,
                                  desktop: 18,
                                ),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Featured Badge
                          if (product.isFeatured)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveUtil.spacing(
                                  mobile: 8,
                                  tablet: 10,
                                  desktop: 12,
                                ),
                                vertical: ResponsiveUtil.spacing(
                                  mobile: 4,
                                  tablet: 5,
                                  desktop: 6,
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: AppConstants.accentColor,
                                borderRadius: BorderRadius.circular(
                                    AppConstants.borderRadiusSmall),
                              ),
                              child: Text(
                                'Featured',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ResponsiveUtil.fontSize(
                                    mobile: 12,
                                    tablet: 13,
                                    desktop: 14,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(
                          height: ResponsiveUtil.spacing(
                        mobile: 8,
                        tablet: 10,
                        desktop: 12,
                      )),
                      Text(
                        product.categoryId,
                        style: TextStyle(
                          color: AppConstants.textSecondaryColor,
                          fontSize: ResponsiveUtil.fontSize(
                            mobile: 14,
                            tablet: 15,
                            desktop: 16,
                          ),
                        ),
                      ),
                      SizedBox(
                          height: ResponsiveUtil.spacing(
                        mobile: 8,
                        tablet: 10,
                        desktop: 12,
                      )),
                      Row(
                        children: [
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: ResponsiveUtil.fontSize(
                                mobile: 16,
                                tablet: 17,
                                desktop: 18,
                              ),
                              fontWeight: FontWeight.bold,
                              color: AppConstants.primaryColor,
                            ),
                          ),
                          SizedBox(
                              width: ResponsiveUtil.spacing(
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
                          )),
                          Text(
                            'Stock: ${product.quantity}',
                            style: TextStyle(
                              fontSize: ResponsiveUtil.fontSize(
                                mobile: 14,
                                tablet: 15,
                                desktop: 16,
                              ),
                              color: product.quantity > 0
                                  ? AppConstants.accentColor
                                  : AppConstants.errorColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                          height: ResponsiveUtil.spacing(
                        mobile: 8,
                        tablet: 10,
                        desktop: 12,
                      )),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: ResponsiveUtil.iconSize(
                              mobile: 16,
                              tablet: 17,
                              desktop: 18,
                            ),
                            color: Colors.amber[700],
                          ),
                          SizedBox(
                              width: ResponsiveUtil.spacing(
                            mobile: 4,
                            tablet: 5,
                            desktop: 6,
                          )),
                          Text(
                            '${product.rating.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: ResponsiveUtil.fontSize(
                                mobile: 14,
                                tablet: 15,
                                desktop: 16,
                              ),
                            ),
                          ),
                          SizedBox(
                              width: ResponsiveUtil.spacing(
                            mobile: 8,
                            tablet: 10,
                            desktop: 12,
                          )),
                          Text(
                            '(${product.reviewCount} reviews)',
                            style: TextStyle(
                              fontSize: ResponsiveUtil.fontSize(
                                mobile: 14,
                                tablet: 15,
                                desktop: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
                height: ResponsiveUtil.spacing(
              mobile: 16,
              tablet: 18,
              desktop: 20,
            )),
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.edit,
                  label: 'Edit',
                  color: AppConstants.primaryColor,
                  onPressed: () => _showProductDialog(context, product),
                ),
                _buildActionButton(
                  icon: product.isFeatured ? Icons.star : Icons.star_border,
                  label: product.isFeatured ? 'Unfeature' : 'Feature',
                  color: Colors.amber[700]!,
                  onPressed: () => _toggleFeatured(product),
                ),
                _buildActionButton(
                  icon: Icons.inventory,
                  label: 'Stock',
                  color: AppConstants.accentColor,
                  onPressed: () => _showStockDialog(product),
                ),
                _buildActionButton(
                  icon: Icons.delete,
                  label: 'Delete',
                  color: AppConstants.errorColor,
                  onPressed: () => _confirmDelete(product),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            icon,
            color: color,
            size: ResponsiveUtil.iconSize(
              mobile: 20,
              tablet: 22,
              desktop: 24,
            ),
          ),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUtil.fontSize(
              mobile: 12,
              tablet: 13,
              desktop: 14,
            ),
            color: color,
          ),
        ),
      ],
    );
  }

  void _showProductDialog(BuildContext context, [Product? product]) {
    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(product: product),
    );
  }

  void _toggleFeatured(Product product) {
    ref.read(adminProductsProvider.notifier).toggleFeatured(
          product.id,
          !product.isFeatured,
        );
  }

  void _showStockDialog(Product product) {
    final controller = TextEditingController(text: product.quantity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Update Stock - ${product.name}',
          style: TextStyle(
            fontSize: ResponsiveUtil.fontSize(
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(
            fontSize: ResponsiveUtil.fontSize(
              mobile: 14,
              tablet: 15,
              desktop: 16,
            ),
          ),
          decoration: InputDecoration(
            labelText: 'Stock Quantity',
            labelStyle: TextStyle(
              fontSize: ResponsiveUtil.fontSize(
                mobile: 14,
                tablet: 15,
                desktop: 16,
              ),
            ),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: ResponsiveUtil.fontSize(
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newStock = int.tryParse(controller.text) ?? 0;
              ref.read(adminProductsProvider.notifier).updateStock(
                    product.id,
                    newStock,
                  );
              Navigator.pop(context);
            },
            child: Text(
              'Update',
              style: TextStyle(
                fontSize: ResponsiveUtil.fontSize(
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Product',
          style: TextStyle(
            fontSize: ResponsiveUtil.fontSize(
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${product.name}"?',
          style: TextStyle(
            fontSize: ResponsiveUtil.fontSize(
              mobile: 14,
              tablet: 15,
              desktop: 16,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: ResponsiveUtil.fontSize(
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                ),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ref
                  .read(adminProductsProvider.notifier)
                  .deleteProduct(product.id);
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: TextStyle(
                fontSize: ResponsiveUtil.fontSize(
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
