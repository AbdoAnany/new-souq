import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/app_constants.dart';
import '../../../models/product.dart';
import '../../../providers/admin_provider.dart';

class ProductFormDialog extends ConsumerStatefulWidget {
  final Product? product;

  const ProductFormDialog({super.key, this.product});

  @override
  ConsumerState<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends ConsumerState<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _brandController = TextEditingController();
  final _skuController = TextEditingController();
  final _weightController = TextEditingController();
  final _dimensionsController = TextEditingController();
  final _materialsController = TextEditingController();
  final _ratingController = TextEditingController();
  final _reviewCountController = TextEditingController();

  String _selectedCategory = AppConstants.productCategories.first;
  bool _isFeatured = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _initializeForm();
    } else {
      // Set default values for new product
      _ratingController.text = '4.5';
      _reviewCountController.text = '0';
      _stockController.text = '10';
    }
  }

  void _initializeForm() {
    final product = widget.product!;
    _nameController.text = product.name;
    _descriptionController.text = product.description;
    _priceController.text = product.price.toString();
    _stockController.text = product.quantity.toString();
    _imageUrlController.text = product.mainImage;
    _brandController.text = product.brand ?? '';
    _skuController.text = product.sku ?? '';
    _weightController.text = product.weight?.toString() ?? '';
    _dimensionsController.text = product.dimensions ?? '';
    // _materialsController.text = product.specifications?.join(', ') ?? '';
    _ratingController.text = product.rating.toString();
    _reviewCountController.text = product.reviewCount.toString();
    _selectedCategory = product.categoryId;
    _isFeatured = product.isFeatured;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    _brandController.dispose();
    _skuController.dispose();
    _weightController.dispose();
    _dimensionsController.dispose();
    _materialsController.dispose();
    _ratingController.dispose();
    _reviewCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.product == null ? 'Add Product' : 'Edit Product',
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
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Basic Information
                      _buildSectionHeader('Basic Information'),
                      _buildTextField(
                        controller: _nameController,
                        label: 'Product Name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter product name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: AppConstants.productCategories
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
                      const SizedBox(height: AppConstants.paddingMedium),
                      _buildTextField(
                        controller: _brandController,
                        label: 'Brand (Optional)',
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      _buildTextField(
                        controller: _skuController,
                        label: 'SKU (Optional)',
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),

                      // Pricing & Stock
                      _buildSectionHeader('Pricing & Stock'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _priceController,
                              label: 'Price (\$)',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter price';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter valid price';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: AppConstants.paddingMedium),
                          Expanded(
                            child: _buildTextField(
                              controller: _stockController,
                              label: 'Stock Quantity',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter stock';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Please enter valid stock';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),

                      // Product Details
                      _buildSectionHeader('Product Details'),
                      _buildTextField(
                        controller: _imageUrlController,
                        label: 'Image URL',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter image URL';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      _buildTextField(
                        controller: _weightController,
                        label: 'Weight (kg) - Optional',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      _buildTextField(
                        controller: _dimensionsController,
                        label: 'Dimensions (L x W x H) - Optional',
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      _buildTextField(
                        controller: _materialsController,
                        label: 'Materials (comma separated) - Optional',
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),

                      // Rating & Reviews
                      _buildSectionHeader('Rating & Reviews'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _ratingController,
                              label: 'Rating (0-5)',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter rating';
                                }
                                final rating = double.tryParse(value);
                                if (rating == null ||
                                    rating < 0 ||
                                    rating > 5) {
                                  return 'Rating must be between 0 and 5';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: AppConstants.paddingMedium),
                          Expanded(
                            child: _buildTextField(
                              controller: _reviewCountController,
                              label: 'Review Count',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter review count';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Please enter valid review count';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),

                      // Featured Toggle
                      CheckboxListTile(
                        title: const Text('Featured Product'),
                        subtitle:
                            const Text('Show in featured products section'),
                        value: _isFeatured,
                        onChanged: (value) {
                          setState(() {
                            _isFeatured = value!;
                          });
                        },
                      ),
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
                  onPressed: _isLoading ? null : _saveProduct,
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
                      : Text(widget.product == null
                          ? 'Add Product'
                          : 'Update Product'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
          ),
          Container(
            height: 1,
            color: AppConstants.primaryColor.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final product = Product(
        id: widget.product?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        quantity: int.parse(_stockController.text),
        categoryId: _selectedCategory,
        images: [_imageUrlController.text.trim()],
        isFeatured: _isFeatured,
        brand: _brandController.text.trim().isEmpty
            ? null
            : _brandController.text.trim(),
        sku: _skuController.text.trim().isEmpty
            ? null
            : _skuController.text.trim(),
        weight: _weightController.text.trim().isEmpty
            ? null
            : double.tryParse(_weightController.text.trim()),
        dimensions: _dimensionsController.text.trim().isEmpty
            ? null
            : _dimensionsController.text.trim(),
        // materials: _materialsController.text.trim().isEmpty
        //     ? null
        //     : _materialsController.text
        //         .trim()
        //         .split(',')
        //         .map((e) => e.trim())
        //         .toList(),
        rating: double.parse(_ratingController.text),
        reviewCount: int.parse(_reviewCountController.text),
        createdAt: widget.product?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(), category: '',
      );

      if (widget.product == null) {
        await ref
            .read(adminProductsProvider.notifier)
            .addProduct(product.toJson());
      } else {
        await ref
            .read(adminProductsProvider.notifier)
            .updateProduct(widget.product!.id, product.toJson());
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.product == null
                  ? 'Product added successfully'
                  : 'Product updated successfully',
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
