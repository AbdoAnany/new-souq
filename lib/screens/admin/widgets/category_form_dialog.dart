import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/category.dart';
import '../../../providers/admin_provider.dart';
import '../../../constants/app_constants.dart';

class CategoryFormDialog extends ConsumerStatefulWidget {
  final Category? category;

  const CategoryFormDialog({super.key, this.category});

  @override
  ConsumerState<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends ConsumerState<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final _sortOrderController = TextEditingController();

  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _initializeForm();
    } else {
      // Set default values for new category
      _sortOrderController.text = '0';
    }
  }

  void _initializeForm() {
    final category = widget.category!;
    _nameController.text = category.name;
    _descriptionController.text = category.description;
    _tagsController.text = category.tags.join(', ');
    _sortOrderController.text = category.sortOrder.toString();
    _isActive = category.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.category == null ? 'Add Category' : 'Edit Category',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            // Form
            Flexible(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: AppConstants.paddingMedium),
                      // Category Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Category Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter category name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),

                      // Tags
                      TextFormField(
                        controller: _tagsController,
                        decoration: const InputDecoration(
                          labelText: 'Tags (comma separated)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.tag),
                          hintText: 'e.g., smartphones, laptops, gaming',
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),

                      // Sort Order
                      TextFormField(
                        controller: _sortOrderController,
                        decoration: const InputDecoration(
                          labelText: 'Sort Order',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.sort),
                          hintText: 'Lower numbers appear first',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter sort order';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),

                      // Active Status
                      Card(
                        child: Padding(
                          padding:
                              const EdgeInsets.all(AppConstants.paddingMedium),
                          child: Row(
                            children: [
                              Icon(
                                _isActive
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: _isActive
                                    ? AppConstants.accentColor
                                    : Colors.grey,
                              ),
                              const SizedBox(width: AppConstants.paddingMedium),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Category Status',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      _isActive
                                          ? 'This category is visible to customers'
                                          : 'This category is hidden from customers',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppConstants.textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _isActive,
                                onChanged: (value) {
                                  setState(() {
                                    _isActive = value;
                                  });
                                },
                                activeColor: AppConstants.accentColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(),
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(widget.category == null
                          ? 'Add Category'
                          : 'Update Category'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final category = Category(
        id: widget.category?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        isActive: _isActive,
        sortOrder: int.parse(_sortOrderController.text),
        tags: tags,
        createdAt: widget.category?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.category == null) {
        await ref
            .read(adminCategoriesNotifierProvider.notifier)
            .addCategory(category);
      } else {
        await ref
            .read(adminCategoriesNotifierProvider.notifier)
            .updateCategory(category);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.category == null
                  ? 'Category added successfully'
                  : 'Category updated successfully',
            ),
            backgroundColor: AppConstants.accentColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
