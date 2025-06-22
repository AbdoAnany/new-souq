import '../../domain/entities/tracking_entity.dart';

class TrackingEventModel extends TrackingEventEntity {
  const TrackingEventModel({
    required super.status,
    required super.description,
    required super.timestamp,
    required super.isCompleted,
    super.trackingNumber,
  });

  factory TrackingEventModel.fromJson(Map<String, dynamic> json) {
    return TrackingEventModel(
      status: json['status'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isCompleted: json['isCompleted'] as bool,
      trackingNumber: json['trackingNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'isCompleted': isCompleted,
      'trackingNumber': trackingNumber,
    };
  }

  factory TrackingEventModel.fromEntity(TrackingEventEntity entity) {
    return TrackingEventModel(
      status: entity.status,
      description: entity.description,
      timestamp: entity.timestamp,
      isCompleted: entity.isCompleted,
      trackingNumber: entity.trackingNumber,
    );
  }
}

class OrderTrackingModel extends OrderTrackingEntity {
  const OrderTrackingModel({
    required super.orderId,
    required super.orderNumber,
    required super.events,
    required super.lastUpdated,
  });

  factory OrderTrackingModel.fromJson(Map<String, dynamic> json) {
    return OrderTrackingModel(
      orderId: json['orderId'] as String,
      orderNumber: json['orderNumber'] as String,
      events: (json['events'] as List<dynamic>)
          .map((event) =>
              TrackingEventModel.fromJson(event as Map<String, dynamic>))
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'orderNumber': orderNumber,
      'events': events
          .map((event) => TrackingEventModel.fromEntity(event).toJson())
          .toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory OrderTrackingModel.fromEntity(OrderTrackingEntity entity) {
    return OrderTrackingModel(
      orderId: entity.orderId,
      orderNumber: entity.orderNumber,
      events: entity.events,
      lastUpdated: entity.lastUpdated,
    );
  }
}
