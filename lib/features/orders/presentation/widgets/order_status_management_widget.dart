import 'package:flutter/material.dart';

import '../../../../utils/responsive_util.dart';
import '../../domain/entities/order_entity.dart';

class OrderStatusManagementWidget extends StatelessWidget {
  final OrderEntity order;
  final Function(OrderStatus) onStatusUpdate;

  const OrderStatusManagementWidget({
    Key? key,
    required this.order,
    required this.onStatusUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Only show for orders that can be managed (admin/employee view)
    if (!_shouldShowManagement()) {
      return const SizedBox.shrink();
    }

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
            Text(
              'Order Management',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildStatusButtons(context),
            if (order.status == OrderStatus.shipped) ...[
              const SizedBox(height: 16),
              _buildTrackingNumberInput(context),
            ],
          ],
        ),
      ),
    );
  }

  bool _shouldShowManagement() {
    // Only show for non-terminal states or if admin permissions
    return order.status != OrderStatus.delivered &&
        order.status != OrderStatus.cancelled &&
        order.status != OrderStatus.returned;
  }

  Widget _buildStatusButtons(BuildContext context) {
    final availableStatuses = _getAvailableStatusTransitions();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableStatuses.map((status) {
        final isCurrentStatus = status == order.status;
        return ElevatedButton(
          onPressed: isCurrentStatus ? null : () => onStatusUpdate(status),
          style: ElevatedButton.styleFrom(
            backgroundColor: isCurrentStatus
                ? Theme.of(context).disabledColor
                : _getStatusColor(status),
            foregroundColor: Colors.white,
          ),
          child: Text(_getStatusDisplayName(status)),
        );
      }).toList(),
    );
  }

  Widget _buildTrackingNumberInput(BuildContext context) {
    final controller = TextEditingController(text: order.trackingNumber ?? '');

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Tracking Number',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            // Update tracking number
            // This would typically trigger an update event
          },
          child: const Text('Update'),
        ),
      ],
    );
  }

  List<OrderStatus> _getAvailableStatusTransitions() {
    switch (order.status) {
      case OrderStatus.pending:
        return [
          OrderStatus.pending,
          OrderStatus.confirmed,
          OrderStatus.cancelled
        ];
      case OrderStatus.confirmed:
        return [
          OrderStatus.confirmed,
          OrderStatus.processing,
          OrderStatus.cancelled
        ];
      case OrderStatus.processing:
        return [
          OrderStatus.processing,
          OrderStatus.shipped,
          OrderStatus.cancelled
        ];
      case OrderStatus.shipped:
        return [
          OrderStatus.shipped,
          OrderStatus.delivered,
          OrderStatus.returned
        ];
      case OrderStatus.delivered:
        return [OrderStatus.delivered, OrderStatus.returned];
      case OrderStatus.cancelled:
        return [OrderStatus.cancelled, OrderStatus.refunded];
      case OrderStatus.returned:
        return [OrderStatus.returned, OrderStatus.refunded];
      case OrderStatus.refunded:
        return [OrderStatus.refunded];
    }
  }

  String _getStatusDisplayName(OrderStatus status) {
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
      case OrderStatus.returned:
        return 'Returned';
      case OrderStatus.refunded:
        return 'Refunded';
    }
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
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.returned:
        return Colors.brown;
      case OrderStatus.refunded:
        return Colors.deepOrange;
    }
  }
}
