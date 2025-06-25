import 'package:flutter/material.dart';

import '../../../../utils/formatter_util.dart';
import '../../../../utils/responsive_util.dart';
import '../../domain/entities/order_entity.dart';

class OrderItemCard extends StatelessWidget {
  final OrderItemEntity item;
  final bool showActions;
  final Function(OrderItemEntity)? onQuantityChanged;
  final Function(OrderItemEntity)? onRemoveItem;
  final bool isEditable;

  const OrderItemCard({
    Key? key,
    required this.item,
    this.showActions = false,
    this.onQuantityChanged,
    this.onRemoveItem,
    this.isEditable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(ResponsiveUtil.spacing(
        mobile: 12,
        tablet: 14,
        desktop: 16,
      )),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: theme.cardColor,
      ),
      child: Row(
        children: [
          // Product image
          Container(
            width: ResponsiveUtil.spacing(mobile: 60, tablet: 70, desktop: 80),
            height: ResponsiveUtil.spacing(mobile: 60, tablet: 70, desktop: 80),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: _buildProductImage(),
          ),

          SizedBox(
              width:
                  ResponsiveUtil.spacing(mobile: 12, tablet: 14, desktop: 16)),

          // Product details
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
                SizedBox(
                    height: ResponsiveUtil.spacing(
                        mobile: 4, tablet: 6, desktop: 8)),
                Text(
                  FormatterUtil.formatCurrency(item.unitPrice),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                    height: ResponsiveUtil.spacing(
                        mobile: 4, tablet: 6, desktop: 8)),
                Row(
                  children: [
                    Text(
                      'Qty: ${item.quantity}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      FormatterUtil.formatCurrency(
                          item.unitPrice * item.quantity),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (showActions && isEditable) ...[
                  SizedBox(
                      height: ResponsiveUtil.spacing(
                          mobile: 8, tablet: 10, desktop: 12)),
                  _buildActionButtons(context),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: item.productImageUrl != null
          ? Image.network(
              item.productImageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildImagePlaceholder(),
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(
        Icons.shopping_bag_outlined,
        color: Colors.grey,
        size: 30,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onQuantityChanged != null)
          IconButton(
            onPressed: () => onQuantityChanged?.call(item),
            icon: const Icon(Icons.edit),
            iconSize: 20,
            tooltip: 'Edit quantity',
          ),
        if (onRemoveItem != null)
          IconButton(
            onPressed: () => onRemoveItem?.call(item),
            icon: const Icon(Icons.delete_outline),
            iconSize: 20,
            color: Colors.red,
            tooltip: 'Remove item',
          ),
      ],
    );
  }
}
