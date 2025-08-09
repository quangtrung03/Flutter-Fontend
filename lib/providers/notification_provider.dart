import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  List<NotificationModel> _notifications = [];
  Map<String, bool> _notificationSettings = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  Map<String, bool> get notificationSettings => _notificationSettings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Fetch notification settings
  Future<void> fetchNotificationSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final settings = await _notificationService.getNotificationSettings();
      if (settings != null) {
        _notificationSettings = settings;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update notification setting
  Future<bool> updateNotificationSetting(String key, bool value) async {
    try {
      await _notificationService.updateNotificationSetting(key, value);
      _notificationSettings[key] = value;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Send test notification with email and type
  Future<bool> sendTestNotification(String email, String type) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _notificationService.sendTestNotification(email, type);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send notification to user
  Future<bool> sendNotificationToUser({
    required String userId,
    required String type,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _notificationService.sendNotificationToUser(
        userId: userId,
        type: type,
        title: title,
        message: message,
        data: data,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Send bulk notification
  Future<bool> sendBulkNotification({
    required String type,
    required String title,
    required String message,
    List<String>? userIds,
    Map<String, dynamic>? data,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _notificationService.sendBulkNotification(
        type: type,
        title: title,
        message: message,
        userIds: userIds,
        data: data,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark notification as read
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(
        isRead: true,
        readAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // Mark all notifications as read
  void markAllAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(
      isRead: true,
      readAt: DateTime.now(),
    )).toList();
    notifyListeners();
  }

  // Add new notification (for real-time updates)
  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  // Remove notification
  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  // Clear all notifications
  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  // Get notifications by type
  List<NotificationModel> getNotificationsByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  // Check if notification type is enabled
  bool isNotificationTypeEnabled(String type) {
    return _notificationSettings[type] ?? false;
  }
}
