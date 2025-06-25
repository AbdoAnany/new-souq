import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
          SizedBox(width: 12.w),

          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  'Qty: ${item.quantity}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      FormatterUtil.formatCurrency(item.unitPrice),
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      FormatterUtil.formatCurrency(item.totalPrice),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    if (item.productImageUrl != null && item.productImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          item.productImageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderImage();
          },
        ),
      );
    }
    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[300],
      ),
      child: Icon(
        Icons.image,
        color: Colors.grey[600],
        size: 30,
      ),
    );
  }
}
