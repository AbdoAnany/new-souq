import 'package:souq/models/order.dart';

class TrackingEvent {
  final String status;
  final String description;
  final DateTime timestamp;
  final bool isCompleted;
  final String? trackingNumber;

  TrackingEvent({
    required this.status,
    required this.description,
    required this.timestamp,
    required this.isCompleted,
    this.trackingNumber,
  });
}

class TrackingService {
  static final TrackingService _instance = TrackingService._internal();
  factory TrackingService() => _instance;
  TrackingService._internal();

  List<TrackingEvent> generateTrackingEvents(Order? order) {
    if(order==null) return  <TrackingEvent>[];

    final events = <TrackingEvent>[];

    // Order placed
    events.add(TrackingEvent(
      status: 'Order Placed',
      description: 'Your order has been placed successfully',
      timestamp: order.createdAt,
      isCompleted: true,
    ));

    // Order confirmed
    if (order.status.index >= OrderStatus.confirmed.index) {
      events.add(TrackingEvent(
        status: 'Order Confirmed',
        description: 'Your order has been confirmed and is being prepared',
        timestamp: order.updatedAt,
        isCompleted: true,
      ));
    }
    
    // Order processing
    if (order.status.index >= OrderStatus.processing.index) {
      events.add(TrackingEvent(
        status: 'Processing',
        description: 'Your order is being processed',
        timestamp: order.updatedAt,
        isCompleted: true,
      ));
    }

    // Order shipped
    if (order.status.index >= OrderStatus.shipped.index && order.shippedAt != null) {
      events.add(TrackingEvent(
        status: 'Order Shipped',
        description: 'Your order has been shipped',
        timestamp: order.shippedAt!,
        isCompleted: true,
        trackingNumber: order.trackingNumber,
      ));
    }

    // Order delivered
    if (order.status.index >= OrderStatus.delivered.index && order.deliveredAt != null) {
      events.add(TrackingEvent(
        status: 'Order Delivered',
        description: 'Your order has been delivered successfully',
        timestamp: order.deliveredAt!,
        isCompleted: true,
      ));
    }

    return events;
  }
}

class OrderTrackingInfo {
  final Order order;
  final List<TrackingEvent> trackingEvents;

  OrderTrackingInfo({
    required this.order,
    required this.trackingEvents,
  });
}
