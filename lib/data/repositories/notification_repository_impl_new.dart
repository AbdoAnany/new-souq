import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/result.dart';
import '../../core/failure.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/entities/notification.dart';
import '../../constants/app_constants.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Result<List<AppNotification>, Failure>> getNotifications(
    String userId, {
    int? limit,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConstants.notificationsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      } else {
        query = query.limit(50); // Default limit
      }

      final querySnapshot = await query.get();

      final notifications = querySnapshot.docs
          .map((doc) => _mapDocumentToNotification(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      return Result.success(notifications);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to get notifications: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void, Failure>> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection(AppConstants.notificationsCollection)
          .doc(notificationId)
          .update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });

      return Result.success(null);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to mark notification as read: ${e.toString()}'));
    }
  }

  @override
  Future<Result<int, Failure>> getUnreadCount(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.notificationsCollection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return Result.success(querySnapshot.docs.length);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to get unread count: ${e.toString()}'));
    }
  }

  @override
  Future<Result<AppNotification, Failure>> createNotification(AppNotification notification) async {
    try {
      final docRef = _firestore
          .collection(AppConstants.notificationsCollection)
          .doc();

      final notificationWithId = notification.copyWith(id: docRef.id);
      
      await docRef.set(_mapNotificationToDocument(notificationWithId));

      return Result.success(notificationWithId);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to create notification: ${e.toString()}'));
    }
  }

  @override
  Stream<Result<List<AppNotification>, Failure>> watchNotifications(String userId) {
    return _firestore
        .collection(AppConstants.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      try {
        final notifications = snapshot.docs
            .map((doc) => _mapDocumentToNotification(doc.data(), doc.id))
            .toList();

        return Result.success(notifications);
      } catch (e) {
        return Result.failure(NetworkFailure('Failed to watch notifications: ${e.toString()}'));
      }
    });
  }

  // Helper methods
  AppNotification _mapDocumentToNotification(Map<String, dynamic> data, String id) {
    return AppNotification(
      id: id,
      userId: data['userId'] as String,
      title: data['title'] as String,
      message: data['message'] as String,
      type: NotificationType.values.firstWhere(
        (type) => type.toString() == data['type'],
        orElse: () => NotificationType.other,
      ),
      priority: NotificationPriority.values.firstWhere(
        (priority) => priority.toString() == data['priority'],
        orElse: () => NotificationPriority.normal,
      ),
      isRead: data['isRead'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      readAt: data['readAt'] != null ? (data['readAt'] as Timestamp).toDate() : null,
      data: data['data'] != null ? Map<String, dynamic>.from(data['data']) : null,
      imageUrl: data['imageUrl'] as String?,
      actionUrl: data['actionUrl'] as String?,
    );
  }

  Map<String, dynamic> _mapNotificationToDocument(AppNotification notification) {
    return {
      'userId': notification.userId,
      'title': notification.title,
      'message': notification.message,
      'type': notification.type.toString(),
      'priority': notification.priority.toString(),
      'isRead': notification.isRead,
      'createdAt': Timestamp.fromDate(notification.createdAt),
      'readAt': notification.readAt != null ? Timestamp.fromDate(notification.readAt!) : null,
      'data': notification.data,
      'imageUrl': notification.imageUrl,
      'actionUrl': notification.actionUrl,
    };
  }
}
