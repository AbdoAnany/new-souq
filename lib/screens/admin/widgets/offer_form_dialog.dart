import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:souq/core/constants/app_constants.dart';
import 'package:souq/models/offer.dart';
import 'package:souq/providers/admin_provider.dart';

class OfferFormDialog extends ConsumerStatefulWidget {
  final Offer? offer;

  const OfferFormDialog({super.key, this.offer});

  @override
  ConsumerState<OfferFormDialog> createState() => _OfferFormDialogState();
}

class _OfferFormDialogState extends ConsumerState<OfferFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _discountPercentageController = TextEditingController();
  final _discountAmountController = TextEditingController();
  final _minimumPurchaseController = TextEditingController();
  final _usageLimitController = TextEditingController();
  final _applicableProductsController = TextEditingController();
  final _applicableCategoriesController = TextEditingController();

  OfferType _selectedType = OfferType.percentage;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.offer != null) {
      _populateFields();
    } else {
      // Set default values for new offer
      _imageUrlController.text =
          'https://via.placeholder.com/300x200?text=Offer+Image';
      _usageLimitController.text = '0';
    }
  }

  void _populateFields() {
    final offer = widget.offer!;
    _titleController.text = offer.title;
    _descriptionController.text = offer.description;
    _imageUrlController.text = offer.imageUrl;
    _selectedType = offer.type;
    _discountPercentageController.text =
        offer.discountPercentage?.toString() ?? '';
    _discountAmountController.text = offer.discountAmount?.toString() ?? '';
    _minimumPurchaseController.text = offer.minimumPurchase?.toString() ?? '';
    _usageLimitController.text = offer.usageLimit.toString();
    _applicableProductsController.text = offer.applicableProducts.join(', ');
    _applicableCategoriesController.text =
        offer.applicableCategories.join(', ');
    _startDate = offer.startDate;
    _endDate = offer.endDate;
    _isActive = offer.isActive;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _discountPercentageController.dispose();
    _discountAmountController.dispose();
    _minimumPurchaseController.dispose();
    _usageLimitController.dispose();
    _applicableProductsController.dispose();
    _applicableCategoriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.offer != null;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.local_offer,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  isEditing ? 'Edit Offer' : 'Add Offer',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information
                      _buildSectionHeader('Basic Information'),
                      _buildTextField(
                        controller: _titleController,
                        label: 'Title',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter offer title';
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
                            return 'Please enter offer description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
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
                      const SizedBox(height: AppConstants.paddingLarge),

                      // Offer Type & Discount
                      _buildSectionHeader('Offer Type & Discount'),
                      DropdownButtonFormField<OfferType>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Offer Type',
                          border: OutlineInputBorder(),
                        ),
                        items: OfferType.values
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type.displayName),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),

                      // Conditional discount fields based on type
                      if (_selectedType == OfferType.percentage) ...[
                        _buildTextField(
                          controller: _discountPercentageController,
                          label: 'Discount Percentage',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter discount percentage';
                            }
                            final percentage = double.tryParse(value);
                            if (percentage == null ||
                                percentage < 0 ||
                                percentage > 100) {
                              return 'Please enter valid percentage (0-100)';
                            }
                            return null;
                          },
                        ),
                      ] else if (_selectedType == OfferType.fixed) ...[
                        _buildTextField(
                          controller: _discountAmountController,
                          label: 'Discount Amount (\$)',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter discount amount';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter valid amount';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: AppConstants.paddingMedium),

                      _buildTextField(
                        controller: _minimumPurchaseController,
                        label: 'Minimum Purchase Amount (\$) - Optional',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),

                      // Date Range
                      _buildSectionHeader('Date Range'),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context, true),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Start Date',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(_formatDate(_startDate)),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppConstants.paddingMedium),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context, false),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'End Date',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(_formatDate(_endDate)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),

                      // Usage & Restrictions
                      _buildSectionHeader('Usage & Restrictions'),
                      _buildTextField(
                        controller: _usageLimitController,
                        label: 'Usage Limit (0 for unlimited)',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter usage limit';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),

                      _buildTextField(
                        controller: _applicableProductsController,
                        label:
                            'Applicable Product IDs (comma-separated) - Optional',
                        maxLines: 2,
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),

                      _buildTextField(
                        controller: _applicableCategoriesController,
                        label:
                            'Applicable Category IDs (comma-separated) - Optional',
                        maxLines: 2,
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),

                      // Status
                      SwitchListTile(
                        title: const Text('Active'),
                        subtitle: const Text(
                            'Whether this offer is currently active'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      _isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveOffer,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEditing ? 'Update' : 'Create'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final firstDate = isStartDate ? DateTime.now() : _startDate;
    final lastDate = DateTime.now().add(const Duration(days: 365 * 2));

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selectedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = selectedDate;
          // If start date is after end date, adjust end date
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = selectedDate;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _saveOffer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final offerData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),
        'type': _selectedType.name,
        'discountPercentage': _selectedType == OfferType.percentage
            ? double.tryParse(_discountPercentageController.text.trim())
            : null,
        'discountAmount': _selectedType == OfferType.fixed
            ? double.tryParse(_discountAmountController.text.trim())
            : null,
        'minimumPurchase': _minimumPurchaseController.text.trim().isNotEmpty
            ? double.tryParse(_minimumPurchaseController.text.trim())
            : null,
        'applicableProducts':
            _applicableProductsController.text.trim().isNotEmpty
                ? _applicableProductsController.text
                    .trim()
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList()
                : <String>[],
        'applicableCategories':
            _applicableCategoriesController.text.trim().isNotEmpty
                ? _applicableCategoriesController.text
                    .trim()
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList()
                : <String>[],
        'startDate': _startDate.toIso8601String(),
        'endDate': _endDate.toIso8601String(),
        'isActive': _isActive,
        'usageLimit': int.parse(_usageLimitController.text.trim()),
      };

      if (widget.offer == null) {
        await ref
            .read(adminOffersProvider.notifier)
            .addOffer(offerData);
      } else {
        await ref
            .read(adminOffersProvider.notifier)
            .updateOffer(widget.offer!.id, offerData);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.offer == null
                  ? 'Offer created successfully'
                  : 'Offer updated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
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
