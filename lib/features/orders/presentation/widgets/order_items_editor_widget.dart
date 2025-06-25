import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/responsive_util.dart';
import '../../domain/entities/order_entity.dart';

class OrderItemsEditorWidget extends StatefulWidget {
  final OrderEntity order;
  final Function(Map<String, int>) onQuantityUpdates;
  final bool isEditable;

  const OrderItemsEditorWidget({
    Key? key,
    required this.order,
    required this.onQuantityUpdates,
    this.isEditable = true,
  }) : super(key: key);

  @override
  State<OrderItemsEditorWidget> createState() => _OrderItemsEditorWidgetState();
}

class _OrderItemsEditorWidgetState extends State<OrderItemsEditorWidget> {
  final Map<String, TextEditingController> _quantityControllers = {};
  final Map<String, int> _quantityUpdates = {};

  @override
  void initState() {
    super.initState();

    // Initialize quantity controllers
    for (final item in widget.order.items) {
      _quantityControllers[item.productId] = TextEditingController(
        text: item.quantity.toString(),
      );
    }

    // Add listeners to track changes
    for (final entry in _quantityControllers.entries) {
      entry.value.addListener(() => _onQuantityChanged(entry.key));
    }
  }

  @override
  void dispose() {
    for (final controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onQuantityChanged(String productId) {
    final controller = _quantityControllers[productId];
    if (controller != null) {
      final newQuantity = int.tryParse(controller.text);
      if (newQuantity != null && newQuantity >= 0) {
        final originalItem = widget.order.items
            .firstWhere((item) => item.productId == productId);

        if (newQuantity != originalItem.quantity) {
          _quantityUpdates[productId] = newQuantity;
        } else {
          _quantityUpdates.remove(productId);
        }

        widget.onQuantityUpdates(_quantityUpdates);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtil.spacing(
          mobile: 16,
          tablet: 20,
          desktop: 24,
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Items (${widget.order.items.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.isEditable && _canEditQuantities())
                  Chip(
                    label: const Text('Editable'),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 12.sp,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ...widget.order.items.map((item) => _buildItemRow(context, item)),
            if (_quantityUpdates.isNotEmpty) ...[
              const Divider(),
              _buildUpdateSummary(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, OrderItemEntity item) {
    final theme = Theme.of(context);
    final controller = _quantityControllers[item.productId];
    final hasChanges = _quantityUpdates.containsKey(item.productId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: hasChanges ? theme.primaryColor : theme.dividerColor,
          width: hasChanges ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: hasChanges ? theme.primaryColor.withOpacity(0.05) : null,
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 60,
              height: 60,
              color: theme.colorScheme.surface,
              child: item.productImageUrl?.isNotEmpty == true
                  ? Image.network(
                      item.productImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildImagePlaceholder(),
                    )
                  : _buildImagePlaceholder(),
            ),
          ),

          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.unitPrice.toStringAsFixed(2)} each',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                if (hasChanges) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Modified',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Quantity Controls
          if (widget.isEditable && _canEditQuantities())
            _buildQuantityControls(context, item, controller!)
          else
            _buildQuantityDisplay(context, item),
        ],
      ),
    );
  }

  Widget _buildQuantityControls(BuildContext context, OrderItemEntity item,
      TextEditingController controller) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => _decrementQuantity(controller),
          icon: const Icon(Icons.remove_circle_outline),
          iconSize: 20,
        ),
        SizedBox(
          width: 60,
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              isDense: true,
            ),
            style: TextStyle(fontSize: 14.sp),
          ),
        ),
        IconButton(
          onPressed: () => _incrementQuantity(controller),
          icon: const Icon(Icons.add_circle_outline),
          iconSize: 20,
        ),
      ],
    );
  }

  Widget _buildQuantityDisplay(BuildContext context, OrderItemEntity item) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Text(
        'Qty: ${item.quantity}',
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.image,
        color: Colors.grey,
        size: 30,
      ),
    );
  }

  Widget _buildUpdateSummary(BuildContext context) {
    final theme = Theme.of(context);
    final itemsChanged = _quantityUpdates.length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.edit,
            color: theme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$itemsChanged item${itemsChanged == 1 ? '' : 's'} modified',
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: _resetChanges,
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _incrementQuantity(TextEditingController controller) {
    final currentValue = int.tryParse(controller.text) ?? 0;
    controller.text = (currentValue + 1).toString();
  }

  void _decrementQuantity(TextEditingController controller) {
    final currentValue = int.tryParse(controller.text) ?? 0;
    if (currentValue > 0) {
      controller.text = (currentValue - 1).toString();
    }
  }

  void _resetChanges() {
    setState(() {
      _quantityUpdates.clear();

      // Reset all controllers to original values
      for (final item in widget.order.items) {
        _quantityControllers[item.productId]?.text = item.quantity.toString();
      }

      widget.onQuantityUpdates({});
    });
  }

  bool _canEditQuantities() {
    // Only allow editing for pending and confirmed orders
    return widget.order.status == OrderStatus.pending ||
        widget.order.status == OrderStatus.confirmed;
  }
}
