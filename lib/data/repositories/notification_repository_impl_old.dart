import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/result.dart';
import '../../core/error/app_error.dart';
import '../../domain/repositories/repositories.dart';
import '../../constants/app_constants.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Result<List<AppNotification>>> getNotifications(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.notificationsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50) // Limit to recent 50 notifications
          .get();

      final notifications = querySnapshot.docs
          .map((doc) => AppNotification(
                id: doc.id,
                title: doc.data()['title'] ?? '',
                body: doc.data()['body'] ?? '',
                createdAt: DateTime.parse(
                  doc.data()['createdAt'] ?? DateTime.now().toIso8601String(),
                ),
                isRead: doc.data()['isRead'] ?? false,
              ))
          .toList();

      return Result.success(notifications);
    } catch (e) {
      return Result.failure(
        NetworkError('Failed to fetch notifications: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void>> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection(AppConstants.notificationsCollection)
          .doc(notificationId)
          .update({
        'isRead': true,
        'readAt': DateTime.now().toIso8601String(),
      });

      return Result.success(null);
    } catch (e) {
      return Result.failure(
        NetworkError('Failed to mark notification as read: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void>> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      
      final querySnapshot = await _firestore
          .collection(AppConstants.notificationsCollection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': DateTime.now().toIso8601String(),
        });
      }

      await batch.commit();
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        NetworkError('Failed to mark all notifications as read: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void>> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection(AppConstants.notificationsCollection)
          .doc(notificationId)
          .delete();

      return Result.success(null);
    } catch (e) {
      return Result.failure(
        NetworkError('Failed to delete notification: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<int>> getUnreadCount(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.notificationsCollection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return Result.success(querySnapshot.docs.length);
    } catch (e) {
      return Result.failure(
        NetworkError('Failed to get unread count: ${e.toString()}'),
      );
    }
  }

  @override
  Stream<List<AppNotification>> watchNotifications(String userId) {
    return _firestore
        .collection(AppConstants.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((querySnapshot) {
          return querySnapshot.docs
              .map((doc) => AppNotification(
                    id: doc.id,
                    title: doc.data()['title'] ?? '',
                    body: doc.data()['body'] ?? '',
                    createdAt: DateTime.parse(
                      doc.data()['createdAt'] ?? DateTime.now().toIso8601String(),
                    ),
                    isRead: doc.data()['isRead'] ?? false,
                  ))
              .toList();
        });
  }
}
