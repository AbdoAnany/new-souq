import 'package:flutter/material.dart';

import '../../../../utils/responsive_util.dart';
import '../../domain/entities/order_entity.dart';

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;
  final bool showIcon;
  final bool isLarge;

  const OrderStatusBadge({
    Key? key,
    required this.status,
    this.showIcon = true,
    this.isLarge = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtil.spacing(mobile: 8, tablet: 10, desktop: 12),
        vertical: ResponsiveUtil.spacing(mobile: 4, tablet: 6, desktop: 8),
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(status),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              _getStatusIcon(status),
              color: _getStatusColor(status),
              size: isLarge ? 18 : 14,
            ),
            SizedBox(
                width:
                    ResponsiveUtil.spacing(mobile: 4, tablet: 6, desktop: 8)),
          ],
          Text(
            _getStatusText(status),
            style: TextStyle(
              color: _getStatusColor(status),
              fontSize: isLarge
                  ? ResponsiveUtil.fontSize(mobile: 14, tablet: 15, desktop: 16)
                  : ResponsiveUtil.fontSize(
                      mobile: 12, tablet: 13, desktop: 14),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.purple;
      case OrderStatus.shipped:
        return Colors.teal;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.refunded:
        return Colors.grey;
      case OrderStatus.returned:
        return Colors.brown;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.refunded:
        return 'Refunded';
      case OrderStatus.returned:
        return 'Returned';
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.processing:
        return Icons.autorenew;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
      case OrderStatus.refunded:
        return Icons.money_off;
      case OrderStatus.returned:
        return Icons.keyboard_return;
    }
  }
}
