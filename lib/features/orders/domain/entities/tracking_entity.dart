import 'package:equatable/equatable.dart';

// Tracking event entity
class TrackingEventEntity extends Equatable {
  final String status;
  final String description;
  final DateTime timestamp;
  final bool isCompleted;
  final String? trackingNumber;

  const TrackingEventEntity({
    required this.status,
    required this.description,
    required this.timestamp,
    required this.isCompleted,
    this.trackingNumber,
  });

  @override
  List<Object?> get props => [
        status,
        description,
        timestamp,
        isCompleted,
        trackingNumber,
      ];
}

// Order tracking entity
class OrderTrackingEntity extends Equatable {
  final String orderId;
  final String orderNumber;
  final List<TrackingEventEntity> events;
  final DateTime lastUpdated;

  const OrderTrackingEntity({
    required this.orderId,
    required this.orderNumber,
    required this.events,
    required this.lastUpdated,
  });

  // Get current status
  String get currentStatus {
    if (events.isEmpty) return 'Order Placed';
    final completedEvents = events.where((event) => event.isCompleted);
    if (completedEvents.isEmpty) return 'Order Placed';
    return completedEvents.last.status;
  }

  // Check if order is delivered
  bool get isDelivered => events.any(
        (event) => event.status == 'Delivered' && event.isCompleted,
      );

  @override
  List<Object?> get props => [
        orderId,
        orderNumber,
        events,
        lastUpdated,
      ];
}
