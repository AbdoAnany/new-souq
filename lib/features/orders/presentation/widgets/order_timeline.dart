import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/formatter_util.dart';
import '../../domain/entities/order_entity.dart';

class OrderTimeline extends StatelessWidget {
  final OrderEntity order;

  const OrderTimeline({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final events = _generateTimelineEvents();

    return Column(
      children: events.asMap().entries.map((entry) {
        final index = entry.key;
        final event = entry.value;
        final isLast = index == events.length - 1;

        return _buildTimelineItem(
          context,
          event,
          isLast,
        );
      }).toList(),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    TimelineEvent event,
    bool isLast,
  ) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: event.isCompleted ? Colors.green : Colors.grey[300],
                border: Border.all(
                  color: event.isCompleted ? Colors.green : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: event.isCompleted
                  ? Icon(
                      Icons.check,
                      size: 12.sp,
                      color: Colors.white,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2.w,
                height: 40.h,
                color: Colors.grey[300],
              ),
          ],
        ),
        SizedBox(width: 12.w),

        // Event content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: event.isCompleted ? Colors.black : Colors.grey[600],
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  event.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                if (event.timestamp != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    FormatterUtil.formatDateTime(event.timestamp!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<TimelineEvent> _generateTimelineEvents() {
    final events = <TimelineEvent>[];

    // Order placed
    events.add(TimelineEvent(
      title: 'Order Placed',
      description: 'Your order has been placed successfully',
      timestamp: order.orderDate,
      isCompleted: true,
    ));

    // Order confirmed
    events.add(TimelineEvent(
      title: 'Order Confirmed',
      description: 'Your order has been confirmed and is being prepared',
      timestamp: order.status.index >= OrderStatus.confirmed.index
          ? order.orderDate
          : null,
      isCompleted: order.status.index >= OrderStatus.confirmed.index,
    ));

    // Order processing
    events.add(TimelineEvent(
      title: 'Processing',
      description: 'Your order is being processed',
      timestamp: order.status.index >= OrderStatus.processing.index
          ? order.orderDate
          : null,
      isCompleted: order.status.index >= OrderStatus.processing.index,
    ));

    // Order shipped
    events.add(TimelineEvent(
      title: 'Shipped',
      description: order.trackingNumber != null
          ? 'Your order has been shipped (${order.trackingNumber})'
          : 'Your order has been shipped',
      timestamp: order.shippedDate,
      isCompleted: order.status.index >= OrderStatus.shipped.index,
    ));

    // Order delivered
    events.add(TimelineEvent(
      title: 'Delivered',
      description: 'Your order has been delivered successfully',
      timestamp: order.deliveredDate,
      isCompleted: order.status.index >= OrderStatus.delivered.index,
    ));

    return events;
  }
}

class TimelineEvent {
  final String title;
  final String description;
  final DateTime? timestamp;
  final bool isCompleted;

  TimelineEvent({
    required this.title,
    required this.description,
    this.timestamp,
    required this.isCompleted,
  });
}
