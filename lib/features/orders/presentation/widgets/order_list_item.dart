import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/formatter_util.dart';
import '../../../../utils/responsive_util.dart';
import '../../domain/entities/order_entity.dart';
import 'order_status_badge.dart';

class OrderListItem extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback onTap;

  const OrderListItem({
    Key? key,
    required this.order,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.all(ResponsiveUtil.spacing(
            mobile: 16,
            tablet: 18,
            desktop: 20,
          )),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Order #${order.orderNumber}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  OrderStatusBadge(status: order.status),
                ],
              ),
              SizedBox(height: 8.h),

              // Order info
              Text(
                'Placed on ${FormatterUtil.formatDateTime(order.orderDate)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.totalItems} items',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    FormatterUtil.formatCurrency(order.total),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),

              // Show first few items
              if (order.items.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  order.items
                          .take(2)
                          .map((item) => item.productName)
                          .join(', ') +
                      (order.items.length > 2 ? '...' : ''),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Tracking number if available
              if (order.trackingNumber != null) ...[
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.local_shipping,
                      size: 16.sp,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Tracking: ${order.trackingNumber}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
