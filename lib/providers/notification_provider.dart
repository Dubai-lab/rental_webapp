import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());

/// Provider to get user notifications
final userNotificationsProvider = StreamProvider.family<List<NotificationModel>, String>((ref, userId) {
  final service = ref.read(notificationServiceProvider);
  return service.getUserNotifications(userId);
});

/// Provider to get unread notification count
final unreadNotificationCountProvider = StreamProvider.family<int, String>((ref, userId) {
  final service = ref.read(notificationServiceProvider);
  return service.getUnreadCount(userId);
});

/// Provider for notification actions
final notificationActionsProvider = Provider<NotificationActions>((ref) {
  return NotificationActions(ref.read(notificationServiceProvider));
});

class NotificationActions {
  final NotificationService _service;

  NotificationActions(this._service);

  Future<void> markAsRead(String notificationId) async {
    await _service.markAsRead(notificationId);
  }

  Future<void> markAllAsRead(String userId) async {
    await _service.markAllAsRead(userId);
  }

  Future<void> deleteNotification(String notificationId) async {
    await _service.deleteNotification(notificationId);
  }
}