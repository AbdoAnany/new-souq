import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product.dart';
import '../../providers/admin_provider.dart';
import '../../constants/app_constants.dart';
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
      ref.read(adminProductsNotifierProvider.notifier).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(adminProductsNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(adminProductsNotifierProvider.notifier).loadProducts();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            color: theme.cardColor,
            child: Column(
              children: [
                // Search Field
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusMedium),
                    ),
                    filled: true,
                    fillColor: AppConstants.backgroundColor,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                // Category Filter
                Row(
                  children: [
                    const Text('Category: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
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
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: AppConstants.paddingMedium),
                        Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        Text(
                          'Add some products to get started',
                          style: TextStyle(
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
                      size: 64,
                      color: AppConstants.errorColor,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Text(
                      'Error loading products',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppConstants.errorColor,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(adminProductsNotifierProvider.notifier)
                            .loadProducts();
                      },
                      child: const Text('Try Again'),
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
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
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
                    product.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
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
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Featured Badge
                          if (product.isFeatured)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppConstants.accentColor,
                                borderRadius: BorderRadius.circular(
                                    AppConstants.borderRadiusSmall),
                              ),
                              child: const Text(
                                'Featured',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Text(
                        product.categoryId,
                        style: TextStyle(
                          color: AppConstants.textSecondaryColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Row(
                        children: [
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.primaryColor,
                            ),
                          ),
                          const SizedBox(width: AppConstants.paddingMedium),
                          Text(
                            'Stock: ${product.stock}',
                            style: TextStyle(
                              color: product.stock > 0
                                  ? AppConstants.accentColor
                                  : AppConstants.errorColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber[700],
                          ),
                          const SizedBox(width: 4),
                          Text('${product.rating.toStringAsFixed(1)}'),
                          const SizedBox(width: AppConstants.paddingSmall),
                          Text('(${product.reviewCount} reviews)'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
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
          icon: Icon(icon, color: color),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
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
    ref.read(adminProductsNotifierProvider.notifier).toggleFeatured(
          product.id,
          !product.isFeatured,
        );
  }

  void _showStockDialog(Product product) {
    final controller = TextEditingController(text: product.stock.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Stock - ${product.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Stock Quantity',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newStock = int.tryParse(controller.text) ?? 0;
              ref.read(adminProductsNotifierProvider.notifier).updateStock(
                    product.id,
                    newStock,
                  );
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ref
                  .read(adminProductsNotifierProvider.notifier)
                  .deleteProduct(product.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
