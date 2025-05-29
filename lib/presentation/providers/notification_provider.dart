import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/notification.dart';
import '../../domain/usecases/notification_usecases.dart';
import '../../data/providers/repository_providers.dart';
import '../../core/result.dart';

// Notification state
class NotificationState {
  final List<AppNotification> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? error;

  const NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
  });

  NotificationState copyWith({
    List<AppNotification>? notifications,
    int? unreadCount,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notification provider
class NotificationNotifier extends StateNotifier<NotificationState> {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkAsReadUseCase _markAsReadUseCase;
  final GetUnreadCountUseCase _getUnreadCountUseCase;
  final WatchNotificationsUseCase _watchNotificationsUseCase;

  NotificationNotifier({
    required GetNotificationsUseCase getNotificationsUseCase,
    required MarkAsReadUseCase markAsReadUseCase,
    required GetUnreadCountUseCase getUnreadCountUseCase,
    required WatchNotificationsUseCase watchNotificationsUseCase,
  })  : _getNotificationsUseCase = getNotificationsUseCase,
        _markAsReadUseCase = markAsReadUseCase,
        _getUnreadCountUseCase = getUnreadCountUseCase,
        _watchNotificationsUseCase = watchNotificationsUseCase,
        super(const NotificationState());

  // Get notifications
  Future<void> getNotifications(String userId, {int? limit}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getNotificationsUseCase(GetNotificationsParams(
      userId: userId,
      limit: limit,
    ));

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (notifications) => state = state.copyWith(
        isLoading: false,
        notifications: notifications,
        error: null,
      ),
    );
  }

  // Watch notifications (real-time)
  void watchNotifications(String userId) {
    _watchNotificationsUseCase(WatchNotificationsParams(userId: userId)).listen(
      (result) {
        result.fold(
          (failure) => state = state.copyWith(error: failure.message),
          (notifications) => state = state.copyWith(
            notifications: notifications,
            error: null,
          ),
        );
      },
      onError: (error) {
        state = state.copyWith(error: error.toString());
      },
    );
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final result = await _markAsReadUseCase(MarkAsReadParams(
      notificationId: notificationId,
    ));

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        final updatedNotifications = state.notifications.map((notification) {
          if (notification.id == notificationId) {
            return notification.copyWith(isRead: true);
          }
          return notification;
        }).toList();

        final newUnreadCount = updatedNotifications
            .where((notification) => !notification.isRead)
            .length;

        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: newUnreadCount,
          error: null,
        );
      },
    );
  }

  // Mark all as read
  Future<void> markAllAsRead(String userId) async {
    final unreadNotifications = state.notifications
        .where((notification) => !notification.isRead)
        .toList();

    for (final notification in unreadNotifications) {
      await markAsRead(notification.id);
    }
  }

  // Get unread count
  Future<void> getUnreadCount(String userId) async {
    final result = await _getUnreadCountUseCase(GetUnreadCountParams(
      userId: userId,
    ));

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (count) => state = state.copyWith(
        unreadCount: count,
        error: null,
      ),
    );
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Clear notifications
  void clearNotifications() {
    state = state.copyWith(
      notifications: [],
      unreadCount: 0,
    );
  }

  // Add notification (for real-time updates from FCM)
  void addNotification(AppNotification notification) {
    final updatedNotifications = [notification, ...state.notifications];
    final newUnreadCount = updatedNotifications
        .where((notification) => !notification.isRead)
        .length;

    state = state.copyWith(
      notifications: updatedNotifications,
      unreadCount: newUnreadCount,
    );
  }

  // Remove notification
  void removeNotification(String notificationId) {
    final updatedNotifications = state.notifications
        .where((notification) => notification.id != notificationId)
        .toList();

    final newUnreadCount = updatedNotifications
        .where((notification) => !notification.isRead)
        .length;

    state = state.copyWith(
      notifications: updatedNotifications,
      unreadCount: newUnreadCount,
    );
  }
}

// Provider definitions
final notificationNotifierProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final notificationRepository = ref.watch(notificationRepositoryProvider);
  
  return NotificationNotifier(
    getNotificationsUseCase: GetNotificationsUseCase(notificationRepository),
    markAsReadUseCase: MarkAsReadUseCase(notificationRepository),
    getUnreadCountUseCase: GetUnreadCountUseCase(notificationRepository),
    watchNotificationsUseCase: WatchNotificationsUseCase(notificationRepository),
  );
});

// Convenience providers
final notificationsProvider = Provider<List<AppNotification>>((ref) {
  return ref.watch(notificationNotifierProvider).notifications;
});

final unreadNotificationsProvider = Provider<List<AppNotification>>((ref) {
  final notifications = ref.watch(notificationNotifierProvider).notifications;
  return notifications.where((notification) => !notification.isRead).toList();
});

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationNotifierProvider).unreadCount;
});

final isNotificationLoadingProvider = Provider<bool>((ref) {
  return ref.watch(notificationNotifierProvider).isLoading;
});

final notificationErrorProvider = Provider<String?>((ref) {
  return ref.watch(notificationNotifierProvider).error;
});

// Provider for notification badge
final hasUnreadNotificationsProvider = Provider<bool>((ref) {
  return ref.watch(unreadCountProvider) > 0;
});
