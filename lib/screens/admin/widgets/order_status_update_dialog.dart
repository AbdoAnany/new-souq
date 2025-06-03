import 'package:flutter/material.dart';
import 'package:souq/models/order.dart';

class OrderStatusUpdateDialog extends StatefulWidget {
  final OrderModel order;
  final Function(OrderStatus status, String? trackingNumber, String? notes)
      onUpdate;

  const OrderStatusUpdateDialog({
    super.key,
    required this.order,
    required this.onUpdate,
  });

  @override
  State<OrderStatusUpdateDialog> createState() =>
      _OrderStatusUpdateDialogState();
}

class _OrderStatusUpdateDialogState extends State<OrderStatusUpdateDialog> {
  late OrderStatus _selectedStatus;
  final TextEditingController _trackingNumberController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order.status;
    _trackingNumberController.text = widget.order.trackingNumber ?? '';
    _notesController.text = widget.order.notes ?? '';
  }

  @override
  void dispose() {
    _trackingNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('Update Order #${widget.order.orderNumber}'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Current Status: ${widget.order.status.name.toUpperCase()}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Status Selection
            Text(
              'New Status',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<OrderStatus>(
              value: _selectedStatus,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: _getAvailableStatuses().map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Row(
                    children: [
                      _buildStatusIndicator(status),
                      const SizedBox(width: 8),
                      Text(_getStatusDisplayName(status)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (status) {
                if (status != null) {
                  setState(() {
                    _selectedStatus = status;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Tracking Number (only for shipped status)
            if (_selectedStatus == OrderStatus.shipped) ...[
              Text(
                'Tracking Number',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _trackingNumberController,
                decoration: InputDecoration(
                  hintText: 'Enter tracking number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Notes
            Text(
              'Notes (Optional)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add notes about this status update...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),

            const SizedBox(height: 16),

            // Warning for cancelled status
            if (_selectedStatus == OrderStatus.cancelled)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: Colors.orange,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cancelling this order will restore product quantities.',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleUpdate,
          style: ElevatedButton.styleFrom(
            backgroundColor: _getStatusColor(_selectedStatus),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Update to ${_getStatusDisplayName(_selectedStatus)}',
                  style: const TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }

  List<OrderStatus> _getAvailableStatuses() {
    // Define the logical progression of order statuses
    switch (widget.order.status) {
      case OrderStatus.pending:
        return [
          OrderStatus.pending,
          OrderStatus.confirmed,
          OrderStatus.cancelled,
        ];
      case OrderStatus.confirmed:
        return [
          OrderStatus.confirmed,
          OrderStatus.processing,
          OrderStatus.cancelled,
        ];
      case OrderStatus.processing:
        return [
          OrderStatus.processing,
          OrderStatus.shipped,
          OrderStatus.cancelled,
        ];
      case OrderStatus.shipped:
        return [
          OrderStatus.shipped,
          OrderStatus.delivered,
          OrderStatus.returned,
        ];
      case OrderStatus.delivered:
        return [
          OrderStatus.delivered,
          OrderStatus.returned,
        ];
      case OrderStatus.cancelled:
        return [OrderStatus.cancelled];
      case OrderStatus.returned:
        return [OrderStatus.returned];
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
    }
  }

  Widget _buildStatusIndicator(OrderStatus status) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getStatusColor(status),
      ),
    );
  }

  Future<void> _handleUpdate() async {
    if (_selectedStatus == widget.order.status) {
      // No status change, just update notes/tracking if provided
      if (_trackingNumberController.text.trim() ==
              (widget.order.trackingNumber ?? '') &&
          _notesController.text.trim() == (widget.order.notes ?? '')) {
        Navigator.pop(context);
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final trackingNumber = _trackingNumberController.text.trim().isNotEmpty
          ? _trackingNumberController.text.trim()
          : null;

      final notes = _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null;

      await widget.onUpdate(_selectedStatus, trackingNumber, notes);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
