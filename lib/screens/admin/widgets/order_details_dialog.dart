import 'package:flutter/material.dart';
import '/core/constants/app_constants.dart';
import 'package:souq/models/order.dart';
import 'package:souq/models/user.dart';
import 'package:souq/utils/formatter_util.dart';

class OrderDetailsDialog extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsDialog({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Details',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Info Card
                    _buildOrderInfoCard(theme),

                    const SizedBox(height: 16),

                    // Customer Info Card
                    _buildCustomerInfoCard(theme),

                    const SizedBox(height: 16),

                    // Items Card
                    _buildItemsCard(theme),

                    const SizedBox(height: 16),

                    // Payment Summary Card
                    _buildPaymentSummaryCard(theme),

                    const SizedBox(height: 16),

                    // Order Timeline Card
                    _buildTimelineCard(theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfoCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Order Number', order.orderNumber),
            _buildDetailRow('Status', order.status.name.toUpperCase()),
            _buildDetailRow(
                'Order Date', FormatterUtil.formatDateShort(order.createdAt)),
            _buildDetailRow(
                'Last Updated', FormatterUtil.formatDateShort(order.updatedAt)),
            if (order.trackingNumber != null)
              _buildDetailRow('Tracking Number', order.trackingNumber!),
            if (order.notes != null) _buildDetailRow('Notes', order.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfoCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Shipping Address
            Text(
              'Shipping Address',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            _buildAddressDetails(order.shippingAddress),

            if (order.billingAddress != null) ...[
              const SizedBox(height: 16),
              Text(
                'Billing Address',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              _buildAddressDetails(order.billingAddress!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddressDetails(Address address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Name', '${address.firstName} ${address.lastName}'),
        _buildDetailRow('Address', address.addressLine1),
        if (address.addressLine2 != null && address.addressLine2!.isNotEmpty)
          _buildDetailRow('Address 2', address.addressLine2!),
        _buildDetailRow(
          'Location',
          '${address.city}, ${address.state ?? ''} ${address.postalCode ?? ''}',
        ),
        _buildDetailRow('Country', address.country),
      ],
    );
  }

  Widget _buildItemsCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Items (${order.items.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...order.items.map((item) => _buildItemRow(item, theme)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(OrderItem item, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          // Product Image (placeholder)
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.shopping_bag,
              color: AppConstants.primaryColor,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
                Text(
                  'Unit Price: ${FormatterUtil.formatCurrency(item.price)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Total Price
          Text(
            FormatterUtil.formatCurrency(item.price * item.quantity),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Summary',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
                'Payment Method', order.paymentMethod.name.toUpperCase()),
            if (order.paymentId != null)
              _buildDetailRow('Payment ID', order.paymentId!),
            const Divider(),
            _buildDetailRow(
                'Subtotal', FormatterUtil.formatCurrency(order.subtotal)),
            _buildDetailRow('Tax', FormatterUtil.formatCurrency(order.tax)),
            _buildDetailRow(
                'Shipping', FormatterUtil.formatCurrency(order.shipping)),
            if (order.discount > 0)
              _buildDetailRow('Discount',
                  '-${FormatterUtil.formatCurrency(order.discount)}'),
            const Divider(),
            _buildDetailRow(
              'Total',
              FormatterUtil.formatCurrency(order.total),
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Timeline',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildTimelineItem(
              'Order Placed',
              FormatterUtil.formatDateShort(order.createdAt),
              true,
            ),
            if (order.confirmedAt != null)
              _buildTimelineItem(
                'Order Confirmed',
                FormatterUtil.formatDateShort(order.confirmedAt!),
                true,
              ),
            if (order.processedAt != null)
              _buildTimelineItem(
                'Order Processing',
                FormatterUtil.formatDateShort(order.processedAt!),
                true,
              ),
            if (order.shippedAt != null)
              _buildTimelineItem(
                'Order Shipped',
                FormatterUtil.formatDateShort(order.shippedAt!),
                true,
              ),
            if (order.deliveredAt != null)
              _buildTimelineItem(
                'Order Delivered',
                FormatterUtil.formatDateShort(order.deliveredAt!),
                true,
              ),
            if (order.cancelledAt != null)
              _buildTimelineItem(
                'Order Cancelled',
                FormatterUtil.formatDateShort(order.cancelledAt!),
                true,
                isNegative: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String timestamp,
    bool isCompleted, {
    bool isNegative = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isNegative
                  ? Colors.red
                  : isCompleted
                      ? Colors.green
                      : Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isNegative ? Colors.red : null,
                  ),
                ),
                Text(
                  timestamp,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppConstants.textSecondaryColor,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? AppConstants.primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }
}
