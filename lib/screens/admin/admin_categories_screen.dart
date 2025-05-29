import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/category.dart';
import '../../providers/admin_provider.dart';
import '../../constants/app_constants.dart';
import 'widgets/category_form_dialog.dart';
thia s new project wit without any data can add some dommy data and can add add screen to add data for admin user do the best way
class AdminCategoriesScreen extends ConsumerStatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  ConsumerState<AdminCategoriesScreen> createState() =>
      _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends ConsumerState<AdminCategoriesScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load categories when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminCategoriesNotifierProvider.notifier).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(adminCategoriesNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref
                  .read(adminCategoriesNotifierProvider.notifier)
                  .loadCategories();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            color: theme.cardColor,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadiusMedium),
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
          ),
          const Divider(height: 1),
          // Categories List
          Expanded(
            child: categoriesState.when(
              data: (categories) {
                final filteredCategories = categories.where((category) {
                  return category.name.toLowerCase().contains(_searchQuery) ||
                      category.description.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredCategories.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: AppConstants.paddingMedium),
                        Text(
                          'No categories found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        Text(
                          'Add some categories to get started',
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
                    return _buildCategoryCard(category);
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
                      'Error loading categories',
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
                            .read(adminCategoriesNotifierProvider.notifier)
                            .loadCategories();
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
        onPressed: () => _showCategoryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Row(
          children: [
            // Category Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
              child: Icon(
                _getCategoryIcon(category.name),
                size: 32,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            // Category Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Active Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: category.isActive
                              ? AppConstants.accentColor
                              : Colors.grey[400],
                          borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusSmall),
                        ),
                        child: Text(
                          category.isActive ? 'Active' : 'Inactive',
                          style: const TextStyle(
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
                    category.description,
                    style: TextStyle(
                      color: AppConstants.textSecondaryColor,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  if (category.tags.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: category.tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                                AppConstants.borderRadiusSmall),
                            border: Border.all(
                              color: AppConstants.primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: AppConstants.primaryColor,
                              fontSize: 10,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            // Action Buttons
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  color: AppConstants.primaryColor,
                  onPressed: () => _showCategoryDialog(context, category),
                ),
                IconButton(
                  icon: Icon(
                    category.isActive ? Icons.visibility_off : Icons.visibility,
                  ),
                  color: category.isActive
                      ? Colors.orange
                      : AppConstants.accentColor,
                  onPressed: () => _toggleActive(category),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: AppConstants.errorColor,
                  onPressed: () => _confirmDelete(category),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'electronics':
        return Icons.devices;
      case 'fashion':
      case 'clothing':
        return Icons.checkroom;
      case 'home & garden':
      case 'home':
        return Icons.home;
      case 'sports':
      case 'fitness':
        return Icons.sports;
      case 'beauty':
      case 'health':
        return Icons.spa;
      case 'books':
        return Icons.book;
      case 'toys':
        return Icons.toys;
      case 'automotive':
        return Icons.directions_car;
      default:
        return Icons.category;
    }
  }

  void _showCategoryDialog(BuildContext context, [Category? category]) {
    showDialog(
      context: context,
      builder: (context) => CategoryFormDialog(category: category),
    );
  }

  void _toggleActive(Category category) {
    ref.read(adminCategoriesNotifierProvider.notifier).toggleActive(
          category.id,
          !category.isActive,
        );
  }

  void _confirmDelete(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${category.name}"?'),
            const SizedBox(height: AppConstants.paddingMedium),
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusMedium),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange[700]),
                  const SizedBox(width: AppConstants.paddingSmall),
                  const Expanded(
                    child: Text(
                      'This will also affect products in this category.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
                  .read(adminCategoriesNotifierProvider.notifier)
                  .deleteCategory(category.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
