import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/category.dart';
import '../../providers/admin_provider.dart';
import '../../constants/app_constants.dart';
import '../../utils/responsive_util.dart';
import 'widgets/category_form_dialog.dart';

// thia s new project wit without any data can add some dommy data and can add add screen to add data for admin user do the best way
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
      ref.read(adminCategoriesProvider.notifier).fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(adminCategoriesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Categories',
          style: TextStyle(
            fontSize: ResponsiveUtil.fontSize(
              mobile: 18,
              tablet: 20,
              desktop: 22,
            ),
          ),
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
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
              ref.read(adminCategoriesProvider.notifier).fetchCategories();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(ResponsiveUtil.spacing(
              mobile: 16,
              tablet: 20,
              desktop: 24,
            )),
            color: theme.cardColor,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search categories...',
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
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadiusMedium),
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
                          'No categories found',
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
                          'Add some categories to get started',
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
                      'Error loading categories',
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
                            .read(adminCategoriesProvider.notifier)
                            .fetchCategories();
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
        onPressed: () => _showCategoryDialog(context),
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

  Widget _buildCategoryCard(Category category) {
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
        child: Row(
          children: [
            // Category Icon
            Container(
              width: ResponsiveUtil.spacing(
                mobile: 60,
                tablet: 66,
                desktop: 72,
              ),
              height: ResponsiveUtil.spacing(
                mobile: 60,
                tablet: 66,
                desktop: 72,
              ),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
              child: Icon(
                _getCategoryIcon(category.name),
                size: ResponsiveUtil.iconSize(
                  mobile: 32,
                  tablet: 36,
                  desktop: 40,
                ),
                color: AppConstants.primaryColor,
              ),
            ),
            SizedBox(
                width: ResponsiveUtil.spacing(
              mobile: 16,
              tablet: 18,
              desktop: 20,
            )),
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
                          style: TextStyle(
                            fontSize: ResponsiveUtil.fontSize(
                              mobile: 18,
                              tablet: 19,
                              desktop: 20,
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Active Status
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
                          color: category.isActive
                              ? AppConstants.accentColor
                              : Colors.grey[400],
                          borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusSmall),
                        ),
                        child: Text(
                          category.isActive ? 'Active' : 'Inactive',
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
                    category.description,
                    style: TextStyle(
                      color: AppConstants.textSecondaryColor,
                      fontSize: ResponsiveUtil.fontSize(
                        mobile: 14,
                        tablet: 15,
                        desktop: 16,
                      ),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                      height: ResponsiveUtil.spacing(
                    mobile: 8,
                    tablet: 10,
                    desktop: 12,
                  )),
                  if (category.name.isNotEmpty)
                    Wrap(
                      spacing: ResponsiveUtil.spacing(
                        mobile: 4,
                        tablet: 5,
                        desktop: 6,
                      ),
                      runSpacing: ResponsiveUtil.spacing(
                        mobile: 4,
                        tablet: 5,
                        desktop: 6,
                      ),
                      children: category.subcategories.take(3).map((tag) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtil.spacing(
                              mobile: 6,
                              tablet: 7,
                              desktop: 8,
                            ),
                            vertical: ResponsiveUtil.spacing(
                              mobile: 2,
                              tablet: 3,
                              desktop: 4,
                            ),
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
                            tag.name,
                            style: TextStyle(
                              color: AppConstants.primaryColor,
                              fontSize: ResponsiveUtil.fontSize(
                                mobile: 10,
                                tablet: 11,
                                desktop: 12,
                              ),
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
                  icon: Icon(
                    Icons.edit,
                    size: ResponsiveUtil.iconSize(
                      mobile: 20,
                      tablet: 22,
                      desktop: 24,
                    ),
                  ),
                  color: AppConstants.primaryColor,
                  onPressed: () => _showCategoryDialog(context, category),
                ),
                IconButton(
                  icon: Icon(
                    category.isActive ? Icons.visibility_off : Icons.visibility,
                    size: ResponsiveUtil.iconSize(
                      mobile: 20,
                      tablet: 22,
                      desktop: 24,
                    ),
                  ),
                  color: category.isActive
                      ? Colors.orange
                      : AppConstants.accentColor,
                  onPressed: () => _toggleActive(category),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    size: ResponsiveUtil.iconSize(
                      mobile: 20,
                      tablet: 22,
                      desktop: 24,
                    ),
                  ),
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
    ref.read(adminCategoriesProvider.notifier).toggleStatus(
          category.id,
          !category.isActive,
        );
  }

  void _confirmDelete(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Category',
          style: TextStyle(
            fontSize: ResponsiveUtil.fontSize(
              mobile: 18,
              tablet: 20,
              desktop: 22,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${category.name}"?',
              style: TextStyle(
                fontSize: ResponsiveUtil.fontSize(
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                ),
              ),
            ),
            SizedBox(
                height: ResponsiveUtil.spacing(
              mobile: 16,
              tablet: 18,
              desktop: 20,
            )),
            Container(
              padding: EdgeInsets.all(ResponsiveUtil.spacing(
                mobile: 16,
                tablet: 18,
                desktop: 20,
              )),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusMedium),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.orange[700],
                    size: ResponsiveUtil.iconSize(
                      mobile: 20,
                      tablet: 22,
                      desktop: 24,
                    ),
                  ),
                  SizedBox(
                      width: ResponsiveUtil.spacing(
                    mobile: 8,
                    tablet: 10,
                    desktop: 12,
                  )),
                  Expanded(
                    child: Text(
                      'This will also affect products in this category.',
                      style: TextStyle(
                        fontSize: ResponsiveUtil.fontSize(
                          mobile: 12,
                          tablet: 13,
                          desktop: 14,
                        ),
                      ),
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
                  .read(adminCategoriesProvider.notifier)
                  .deleteCategory(category.id);
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
