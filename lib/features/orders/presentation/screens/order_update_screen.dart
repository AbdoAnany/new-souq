import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/my_app_bar.dart';
import '../../../../utils/responsive_util.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';
import '../widgets/order_status_management_widget.dart';
import '../widgets/order_items_editor_widget.dart';
import '../widgets/order_notes_widget.dart';

class OrderUpdateScreen extends StatefulWidget {
  final OrderEntity order;

  const OrderUpdateScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<OrderUpdateScreen> createState() => _OrderUpdateScreenState();
}

class _OrderUpdateScreenState extends State<OrderUpdateScreen> {
  late OrderStatus _selectedStatus;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _trackingController = TextEditingController();
  final Map<String, int> _quantityUpdates = {};
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order.status;
    _trackingController.text = widget.order.trackingNumber ?? '';
    _notesController.addListener(_checkForChanges);
    _trackingController.addListener(_checkForChanges);
  }

  @override
  void dispose() {
    _notesController.dispose();
    _trackingController.dispose();
    super.dispose();
  }

  void _checkForChanges() {
    setState(() {
      _hasChanges = _notesController.text.trim().isNotEmpty ||
          _selectedStatus != widget.order.status ||
          _trackingController.text.trim() !=
              (widget.order.trackingNumber ?? '') ||
          _quantityUpdates.isNotEmpty;
    });
  }

  void _onStatusChanged(OrderStatus newStatus) {
    setState(() {
      _selectedStatus = newStatus;
    });
    _checkForChanges();
  }

  void _onQuantityChanged(Map<String, int> quantityUpdates) {
    setState(() {
      _quantityUpdates.clear();
      _quantityUpdates.addAll(quantityUpdates);
    });
    _checkForChanges();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OrderBloc>(
          create: (context) => di.sl<OrderBloc>(),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => di.sl<AuthBloc>(),
        ),
      ],
      child: BlocConsumer<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'View Orders',
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/order-history',
                      (route) => route.isFirst,
                    );
                  },
                ),
              ),
            );

            // Navigate based on status change significance
            if (_selectedStatus != widget.order.status &&
                (_selectedStatus == OrderStatus.delivered ||
                    _selectedStatus == OrderStatus.shipped)) {
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/order-history',
                    (route) => route.isFirst,
                  );
                }
              });
            } else {
              Navigator.pop(context, true);
            }
          } else if (state is OrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'Dismiss',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is OrderUpdateInProgress;

          return Scaffold(
            appBar: MyAppBar(
              title: Text('#${widget.order.orderNumber}'),
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(
                ResponsiveUtil.spacing(mobile: 16, tablet: 20, desktop: 24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order status info
                  _buildOrderStatusInfo(context),

                  SizedBox(height: 24.h),

                  // Status Management Section (Admin/Employee only)
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      final isAdminOrEmployee =
                          authState is AuthAuthenticated &&
                              (authState.user.isAdmin ||
                                  authState.user.role == UserRole.staff);

                      if (!isAdminOrEmployee) {
                        return const SizedBox.shrink();
                      }

                      return OrderStatusManagementWidget(
                        order: widget.order,
                        onStatusUpdate: _onStatusChanged,
                      );
                    },
                  ),

                  // Order items editor
                  if (_canModifyOrder()) ...[
                    OrderItemsEditorWidget(
                      order: widget.order,
                      onQuantityUpdates: _onQuantityChanged,
                    ),
                    SizedBox(height: 24.h),
                  ],

                  // Notes section
                  OrderNotesWidget(
                    order: widget.order,
                    onNoteAdded: (String note) => _checkForChanges(),
                    isEditable: true,
                  ),

                  SizedBox(height: 32.h),

                  // Action buttons
                  _buildActionButtons(context, isLoading),

                  SizedBox(height: 16.h),

                  // Disclaimer
                  _buildDisclaimer(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderStatusInfo(BuildContext context) {
    final theme = Theme.of(context);
    final canModifyOrder = _canModifyOrder();

    return Container(
      padding: EdgeInsets.all(
        ResponsiveUtil.spacing(mobile: 16, tablet: 18, desktop: 20),
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(widget.order.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(
          color: _getStatusColor(widget.order.status),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(widget.order.status),
            color: _getStatusColor(widget.order.status),
            size: ResponsiveUtil.iconSize(mobile: 24, tablet: 28, desktop: 32),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Status: ${widget.order.status.name.toUpperCase()}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(widget.order.status),
                    fontSize: ResponsiveUtil.fontSize(
                        mobile: 16, tablet: 18, desktop: 20),
                  ),
                ),
                if (!canModifyOrder) ...[
                  SizedBox(height: 4.h),
                  Text(
                    'This order can no longer be modified',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppConstants.textSecondaryColor,
                      fontSize: ResponsiveUtil.fontSize(
                          mobile: 12, tablet: 13, desktop: 14),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isLoading) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: ResponsiveUtil.fontSize(
                    mobile: 14, tablet: 15, desktop: 16),
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: CustomButton(
            text: isLoading ? 'Updating...' : 'Update Order',
            onPressed: _hasChanges && !isLoading ? _submitUpdate : null,
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimer(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(
        ResponsiveUtil.spacing(mobile: 12, tablet: 14, desktop: 16),
      ),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.amber[700],
            size: ResponsiveUtil.iconSize(mobile: 20, tablet: 22, desktop: 24),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Note: Order modifications are only allowed for pending and confirmed orders. '
              'Changes may affect the total price and delivery time.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.amber[700],
                fontSize: ResponsiveUtil.fontSize(
                    mobile: 12, tablet: 13, desktop: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canModifyOrder() {
    return widget.order.status == OrderStatus.pending ||
        widget.order.status == OrderStatus.confirmed;
  }

  void _submitUpdate() {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticated) {
      final user = authState.user;
      final isAdminOrEmployee = user.isAdmin || user.role == UserRole.staff;

      if (isAdminOrEmployee) {
        // Validate tracking number if needed
        if (_selectedStatus == OrderStatus.shipped &&
            _trackingController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Tracking number is required when marking order as shipped'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        context.read<OrderBloc>().add(UpdateOrderWithAdminPermissionsEvent(
              orderId: widget.order.id,
              newStatus: _selectedStatus,
              adminNotes: _notesController.text.trim().isNotEmpty
                  ? _notesController.text.trim()
                  : null,
              quantityUpdates:
                  _quantityUpdates.isNotEmpty ? _quantityUpdates : null,
              userRole: user.role.name,
              trackingNumber: _trackingController.text.trim().isNotEmpty
                  ? _trackingController.text.trim()
                  : null,
            ));
      } else {
        context.read<OrderBloc>().add(UpdateOrderWithValidationEvent(
              orderId: widget.order.id,
              newStatus: widget.order.status, // Keep same status for customers
              customerNotes: _notesController.text.trim().isNotEmpty
                  ? _notesController.text.trim()
                  : null,
              quantityUpdates:
                  _quantityUpdates.isNotEmpty ? _quantityUpdates : null,
            ));
      }
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
        return Colors.teal;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.processing:
        return Icons.cached;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.done_all;
      case OrderStatus.cancelled:
        return Icons.cancel;
      case OrderStatus.returned:
        return Icons.keyboard_return;
      case OrderStatus.refunded:
        return Icons.refresh;
    }
  }
}
