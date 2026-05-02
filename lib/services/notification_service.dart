import 'dart:async';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

/// Holds the current unread notification count.
/// Any widget can listen: ValueListenableBuilder<int>(valueListenable: unreadCountNotifier, ...)
final unreadCountNotifier = ValueNotifier<int>(0);

class NotificationService {
  static bool _initialized = false;
  static Timer? _pollTimer;
  static String? _personId;

  /// Call this once after the user logs in and we know their [personId].
  /// Starts periodic polling for new notifications from MySQL database.
  static Future<void> init(String personId) async {
    if (_initialized && _personId == personId) return;

    // Reset if switching users
    if (_personId != null && _personId != personId) {
      reset();
    }

    _initialized = true;
    _personId = personId;

    // Initial load of notifications
    await _refreshNotifications();

    // Start polling every 5 seconds for new notifications
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _refreshNotifications();
    });
  }

  /// Fetch notifications from the MySQL backend and update badge count
  static Future<void> _refreshNotifications() async {
    if (_personId == null) return;

    try {
      final notifications = await ApiService.getNotifications(_personId!);

      // Count unread notifications
      final unreadCount = notifications.where((n) => !n.isRead).length;
      unreadCountNotifier.value = unreadCount;

      if (kDebugMode) {
        print('[NotificationService] Fetched ${notifications.length} notifications, unread: $unreadCount');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[NotificationService] ERROR: $e');
      }
    }
  }

  /// Call this when the intern opens the notifications page to reset the badge.
  static void clearBadge() {
    unreadCountNotifier.value = 0;
  }

  /// Re-enables initialisation (e.g. after logout -> login as different user).
  static void reset() {
    _initialized = false;
    _personId = null;
    _pollTimer?.cancel();
    _pollTimer = null;
    unreadCountNotifier.value = 0;
  }

  /// Stop polling (call on app termination)
  static void dispose() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }
}
