import 'dart:async';
import 'package:flutter/foundation.dart';
import 'api_service.dart';


final unreadCountNotifier = ValueNotifier<int>(0);

class NotificationService {
  static bool _initialized = false;
  static Timer? _pollTimer;
  static String? _personId;

  static Future<void> init(String personId) async {
    if (_initialized && _personId == personId) return;

    if (_personId != null && _personId != personId) {
      reset();
    }

    _initialized = true;
    _personId = personId;

    await _refreshNotifications();

    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _refreshNotifications();
    });
  }

  static Future<void> _refreshNotifications() async {
    if (_personId == null) return;

    try {
      final notifications = await ApiService.getNotifications(_personId!);

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

  static void clearBadge() {
    unreadCountNotifier.value = 0;
  }

  static void reset() {
    _initialized = false;
    _personId = null;
    _pollTimer?.cancel();
    _pollTimer = null;
    unreadCountNotifier.value = 0;
  }

  static void dispose() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }
}
