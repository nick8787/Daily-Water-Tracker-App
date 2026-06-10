import 'dart:convert';

import 'package:daily_water_tracker/common/services/logger.dart';
import 'package:daily_water_tracker/common/utils/crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

/// Local + scheduled notifications. Debug-only lines: `FINE LocalNotif:` / `ERR LocalNotif:`.
class LocalNotificationsService {
  LocalNotificationsService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const int debugScheduledTestNotificationId = 919999;

  static const String defaultChannelId = 'high_importance_channel';
  static const String defaultChannelName = 'High importance';
  static const String defaultChannelDescription = 'Hydration reminders and debug tests.';

  static const String _androidSmallIconName = 'ic_notification';
  static const String payloadRouteKey = 'route';

  bool _initialized = false;
  bool _didResetAndroidChannel = false;

  bool get isInitialized => _initialized;

  static void _fine(String msg) => log.fine('LocalNotif: $msg');

  static void _err(Object e, [StackTrace? s]) =>
      logCaughtError('LocalNotif', e, s);

  DarwinNotificationDetails _darwinDetails() {
    return const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );
  }

  Future<void> initialize({
    required Future<void> Function(String? route) onNotificationTap,
  }) async {
    if (_initialized) return;

    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        
      );
      await _plugin.initialize(
        const InitializationSettings(android: androidInit, iOS: iosInit),
        onDidReceiveNotificationResponse: (response) async {
          final route = _parseRouteFromPayload(response.payload);
          _fine('notification tap → ${route ?? '(no route)'}');
          try {
            await onNotificationTap(route);
          } catch (e, s) {
            _err(e, s);
          }
        },
        onDidReceiveBackgroundNotificationResponse: _backgroundTapHandler,
      );
      await _ensureAndroidChannel();
      _initialized = true;
      _fine('plugin ready (channel $defaultChannelId)');
    } catch (e, s) {
      _err(e, s);
      rethrow;
    }
  }

  @pragma('vm:entry-point')
  static void _backgroundTapHandler(NotificationResponse response) {}

  Future<String?> consumeLaunchNotificationRoute() async {
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details == null || !details.didNotificationLaunchApp) return null;
      return _parseRouteFromPayload(details.notificationResponse?.payload);
    } catch (e, s) {
      _err(e, s);
      return null;
    }
  }

  Future<void> _ensureAndroidChannel() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    if (!_didResetAndroidChannel) {
      try {
        await android.deleteNotificationChannel(defaultChannelId);
      } catch (e, s) {
        _err(e, s);
      }
      _didResetAndroidChannel = true;
    }

    await android.createNotificationChannel(
      AndroidNotificationChannel(
        defaultChannelId,
        defaultChannelName,
        description: defaultChannelDescription,
        importance: Importance.max,
        vibrationPattern: Int64List.fromList([0, 400, 200, 500]),
      ),
    );
  }

  /// Whether the OS allows showing notifications (Android POST_NOTIFICATIONS / iOS UN center).
  Future<bool> areOsNotificationsEnabled() async {
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        return (await Permission.notification.status).isGranted;
      } catch (e, s) {
        _err(e, s);
        return false;
      }
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _areIosNotificationsEnabled();
    }
    return false;
  }

  Future<bool> _areIosNotificationsEnabled() async {
    try {
      final ios =
          _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      final options = await ios?.checkPermissions();
      return options?.isEnabled ?? false;
    } catch (e, s) {
      _err(e, s);
      return false;
    }
  }

  /// Whether the OS prompt can still be shown (false → open system Settings)
  Future<bool> canRequestOsNotificationPermission() async {
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        return !(await Permission.notification.status).isPermanentlyDenied;
      } catch (e, s) {
        _err(e, s);
        return false;
      }
    }
    return true;
  }

  /// Requests OS notification permission. Returns whether alerts are allowed afterward.
  Future<bool> requestOsNotificationPermissions() async {
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        var status = await Permission.notification.status;
        if (!status.isGranted) {
          status = await Permission.notification.request();
        }
        return status.isGranted;
      } catch (e, s) {
        _err(e, s);
        return false;
      }
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return requestIosNotificationPermissions();
    }
    return false;
  }

  Future<bool> requestIosNotificationPermissions() async {
    try {
      final ios =
          _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (await _areIosNotificationsEnabled()) return true;
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      if (granted == true) return true;
      return _areIosNotificationsEnabled();
    } catch (e, s) {
      _err(e, s);
      return false;
    }
  }

  Future<void> ensureAndroidSchedulingPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final st = await Permission.notification.status;
        if (!st.isGranted) await Permission.notification.request();
        if (!(await Permission.notification.status).isGranted) {
          _err(StateError('POST_NOTIFICATIONS denied — enable in system App settings'));
        }
      }

      await android.requestNotificationsPermission();
      var canExact = await android.canScheduleExactNotifications();
      if (canExact == false) {
        await android.requestExactAlarmsPermission();
        canExact = await android.canScheduleExactNotifications();
      }
      final enabled = await android.areNotificationsEnabled();
      _fine('android perms ok (notifications=$enabled exact=$canExact)');
    } catch (e, s) {
      _err(e, s);
    }
  }

  AndroidNotificationDetails _androidDetails({String? ticker, String? bodyForBigText}) {
    return AndroidNotificationDetails(
      defaultChannelId,
      defaultChannelName,
      channelDescription: defaultChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      icon: _androidSmallIconName,
      category: AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public,
      vibrationPattern: Int64List.fromList([0, 380, 180, 380]),
      ticker: ticker,
      styleInformation: bodyForBigText != null && bodyForBigText.isNotEmpty
          ? BigTextStyleInformation(bodyForBigText, contentTitle: ticker)
          : null,
    );
  }

  Future<void> showForegroundNotification({
    required int id,
    required String? title,
    required String? body,
    Map<String, dynamic>? data,
  }) async {
    if (!_initialized) return;
    final payload = _encodePayload(data);
    try {
      await _ensureAndroidChannel();
      await _plugin.show(
        id,
        title,
        body,
        NotificationDetails(
          android: _androidDetails(ticker: title ?? body ?? 'push', bodyForBigText: body ?? ''),
          iOS: _darwinDetails(),
        ),
        payload: payload,
      );
      _fine('FCM foreground banner id=$id "${title ?? body ?? ''}"');
    } catch (e, s) {
      _err(e, s);
    }
  }

  Future<void> showDebugImmediateNotification({
    required int id,
    required String title,
    required String body,
    required String routePayload,
  }) async {
    if (!_initialized) return;
    try {
      await _ensureAndroidChannel();
      await _plugin.show(
        id,
        title,
        body,
        NotificationDetails(
          android: _androidDetails(ticker: title, bodyForBigText: body),
          iOS: _darwinDetails(),
        ),
        payload: jsonEncode(<String, dynamic>{payloadRouteKey: routePayload}),
      );
      _fine('debug instant push id=$id');
    } catch (e, s) {
      _err(e, s);
    }
  }

  Future<void> scheduleZonedOneShot({
    required int id,
    required DateTime when,
    required String title,
    required String body,
    required String routePayload,
  }) async {
    if (!_initialized) {
      throw StateError('LocalNotificationsService.initialize before scheduleZonedOneShot');
    }

    final nowWall = DateTime.now();
    if (!when.isAfter(nowWall.subtract(const Duration(milliseconds: 400)))) return;

    final scheduled = tz.TZDateTime.from(when, tz.local);
    final details = NotificationDetails(
      android: _androidDetails(ticker: title, bodyForBigText: body),
      iOS: _darwinDetails(),
    );

    Future<void> doSchedule(AndroidScheduleMode androidMode) => _plugin.zonedSchedule(
          id,
          title,
          body,
          scheduled,
          details,
          androidScheduleMode: androidMode,
          payload: jsonEncode(<String, dynamic>{payloadRouteKey: routePayload}),
        );

    try {
      await _ensureAndroidChannel();
      if (defaultTargetPlatform == TargetPlatform.android) {
        try {
          await doSchedule(AndroidScheduleMode.exactAllowWhileIdle);
        } catch (e, s) {
          await basicRecordCrashlyticsError(e, s, reason: 'scheduleZonedOneShot.exactFallback');
          await doSchedule(AndroidScheduleMode.inexactAllowWhileIdle);
        }
      } else {
        await doSchedule(AndroidScheduleMode.inexactAllowWhileIdle);
      }
    } catch (e, s) {
      _err(e, s);
    }
  }

  Future<void> logPendingScheduledSummary({required int startId, required int endId}) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      final list = await _plugin.pendingNotificationRequests();
      final n = list.where((p) => p.id >= startId && p.id <= endId).length;
      _fine('hydration alarms scheduled: $n (slot range $startId–$endId)');
    } catch (e, s) {
      _err(e, s);
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      await _plugin.cancel(id);
    } catch (e, s) {
      _err(e, s);
    }
  }

  Future<void> cancelNotificationIdsInclusive(int startId, int endId) async {
    try {
      for (var id = startId; id <= endId; id++) {
        await _plugin.cancel(id);
      }
      _fine('cleared notification ids $startId–$endId');
    } catch (e, s) {
      _err(e, s);
    }
  }

  static String? _encodePayload(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return null;
    try {
      return jsonEncode(data);
    } catch (e) {
      _err(e);
      return null;
    }
  }

  static String? _parseRouteFromPayload(String? payload) {
    if (payload == null || payload.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map && decoded[payloadRouteKey] is String) {
        return (decoded[payloadRouteKey] as String).trim();
      }
    } catch (e) {
      _err(e);
    }
    return null;
  }
}
