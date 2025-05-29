enum NotificationType {
  order,
  promotion,
  system,
  reminder,
  announcement,
  other
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent
}

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final Map<String, dynamic>? data;
  final String? imageUrl;
  final String? actionUrl;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.priority = NotificationPriority.normal,
    this.isRead = false,
    required this.createdAt,
    this.readAt,
    this.data,
    this.imageUrl,
    this.actionUrl,
  });

  String get typeDisplayName {
    switch (type) {
      case NotificationType.order:
        return 'Order';
      case NotificationType.promotion:
        return 'Promotion';
      case NotificationType.system:
        return 'System';
      case NotificationType.reminder:
        return 'Reminder';
      case NotificationType.announcement:
        return 'Announcement';
      case NotificationType.other:
        return 'Other';
    }
  }

  String get priorityDisplayName {
    switch (priority) {
      case NotificationPriority.low:
        return 'Low';
      case NotificationPriority.normal:
        return 'Normal';
      case NotificationPriority.high:
        return 'High';
      case NotificationPriority.urgent:
        return 'Urgent';
    }
  }

  bool get isImportant => priority == NotificationPriority.high || priority == NotificationPriority.urgent;

  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    NotificationPriority? priority,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? actionUrl,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      data: data ?? this.data,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  AppNotification markAsRead() {
    return copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is AppNotification &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.message == message &&
        other.type == type &&
        other.priority == priority &&
        other.isRead == isRead &&
        other.createdAt == createdAt &&
        other.readAt == readAt &&
        other.data == data &&
        other.imageUrl == imageUrl &&
        other.actionUrl == actionUrl;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      userId,
      title,
      message,
      type,
      priority,
      isRead,
      createdAt,
      readAt,
      data,
      imageUrl,
      actionUrl,
    ]);
  }

  @override
  String toString() {
    return 'AppNotification(id: $id, title: $title, type: $type, isRead: $isRead)';
  }
}
