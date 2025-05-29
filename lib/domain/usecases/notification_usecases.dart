import '../../core/result.dart';
import '../../core/failure.dart';
import '../../core/usecase/usecase.dart';
import '../repositories/repositories.dart';
import '../entities/notification.dart';

/// Parameters for getting notifications
class GetNotificationsParams {
  final String userId;
  final int? limit;

  const GetNotificationsParams({
    required this.userId,
    this.limit,
  });
}

/// Use case for getting user notifications
class GetNotificationsUseCase implements UseCase<List<AppNotification>, GetNotificationsParams> {
  final NotificationRepository _repository;

  GetNotificationsUseCase(this._repository);

  @override
  Future<Result<List<AppNotification>, Failure>> call(GetNotificationsParams params) async {
    return await _repository.getNotifications(params.userId, limit: params.limit);
  }
}

/// Parameters for marking notification as read
class MarkAsReadParams {
  final String notificationId;

  const MarkAsReadParams({required this.notificationId});
}

/// Use case for marking notification as read
class MarkAsReadUseCase implements UseCase<void, MarkAsReadParams> {
  final NotificationRepository _repository;

  MarkAsReadUseCase(this._repository);

  @override
  Future<Result<void, Failure>> call(MarkAsReadParams params) async {
    return await _repository.markAsRead(params.notificationId);
  }
}

/// Use case for marking all notifications as read
class MarkAllNotificationsAsReadUseCase implements UseCase<void, String> {
  final NotificationRepository _repository;

  MarkAllNotificationsAsReadUseCase(this._repository);

  @override
  Future<Result<void>> call(String userId) async {
    return await _repository.markAllAsRead(userId);
  }
}

/// Use case for deleting notification
class DeleteNotificationUseCase implements UseCase<void, String> {
  final NotificationRepository _repository;

  DeleteNotificationUseCase(this._repository);

  @override
  Future<Result<void>> call(String notificationId) async {
    return await _repository.deleteNotification(notificationId);
  }
}

/// Use case for getting unread notification count
class GetUnreadCountUseCase implements UseCase<int, String> {
  final NotificationRepository _repository;

  GetUnreadCountUseCase(this._repository);

  @override
  Future<Result<int, Failure>> call(String userId) async {
    return await _repository.getUnreadCount(userId);
  }
}

/// Parameters for watching notifications
class WatchNotificationsParams {
  final String userId;

  const WatchNotificationsParams({required this.userId});
}

/// Use case for watching notifications
class WatchNotificationsUseCase implements StreamUseCase<List<AppNotification>, WatchNotificationsParams> {
  final NotificationRepository _repository;

  WatchNotificationsUseCase(this._repository);

  @override
  Stream<Result<List<AppNotification>, Failure>> call(WatchNotificationsParams params) {
    return _repository.watchNotifications(params.userId);
  }
}

/// Use case for checking if user has unread notifications
class HasUnreadNotificationsUseCase implements UseCase<bool, String> {
  final NotificationRepository _repository;

  HasUnreadNotificationsUseCase(this._repository);

  @override
  Future<Result<bool>> call(String userId) async {
    final countResult = await _repository.getUnreadCount(userId);
    if (countResult.isFailure) {
      return Result.failure(countResult.error!);
    }
    
    return Result.success(countResult.data! > 0);
  }
}
