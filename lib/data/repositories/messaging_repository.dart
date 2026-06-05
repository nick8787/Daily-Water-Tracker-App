import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:daily_water_tracker/common/services/logger.dart';
import 'package:daily_water_tracker/data/repositories/firestore_repository.dart';
import 'package:daily_water_tracker/firebase/services/auth_service.dart';
import 'package:daily_water_tracker/firebase/services/local_notifications_service.dart';
import 'package:permission_handler/permission_handler.dart';

/// FCM token, topic subscription and deep-link route coordination for push
class MessagingRepository {
  MessagingRepository({
    required FirebaseMessaging messaging,
    required AuthService authService,
    required FirestoreRepository firestoreRepository,
    required LocalNotificationsService localNotifications,
  })  : _messaging = messaging,
        _authService = authService,
        _firestoreRepository = firestoreRepository,
        _localNotifications = localNotifications;

  final FirebaseMessaging _messaging;
  final AuthService _authService;
  final FirestoreRepository _firestoreRepository;
  final LocalNotificationsService _localNotifications;

  StreamSubscription<String>? _tokenRefreshSub;
  bool _started = false;
  bool _reminderTopicSubscribed = false;
  String? _pendingRoute;
  bool? _lastSyncedReminderTopicSubscribed;
  Future<void>? _coldStartHydration;

  static const String dataRouteKey = 'route';

  /// Reads the FCM message that launched the app from terminated state (if any)
  Future<void> hydratePendingRouteFromColdStart() {
    return _coldStartHydration ??= () async {
      try {
        final initial = await _messaging.getInitialMessage();
        if (initial == null) return;
        setPendingRoute(routeFromMessage(initial));
      } catch (e, st) {
        logCaughtError('MessagingRepository.hydratePendingRouteFromColdStart', e, st);
      }
    }();
  }

  Future<NotificationSettings> requestPermission() {
    return _messaging.requestPermission();
  }

  /// Runtime POST_NOTIFICATIONS (Android 13+) + FCM/APNs prompt. Call only when user is signed in.
  Future<void> setupPushNotificationsForSignedInUser() async {
    if (_authService.currentUser == null) return;
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        await Permission.notification.request();
      }
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        await _localNotifications.requestOsNotificationPermissions();
      }
      await requestPermission();
      await startTokenSync();
      await syncTokenNow();
      await syncReminderTopicWithPreferences();
    } catch (e, st) {
      logCaughtError('MessagingRepository.setupPushNotificationsForSignedInUser', e, st);
    }
  }

  Future<void> teardownPushForSignedOutUser() async {
    try {
      _lastSyncedReminderTopicSubscribed = null;
      if (_reminderTopicSubscribed) {
        await unsubscribeFromTopic('reminder');
      }
    } catch (e, st) {
      logCaughtWarning('MessagingRepository.teardownPushForSignedOutUser: unsubscribe', e, st);
    }
    await stop();
  }

  Future<String?> getToken() => _messaging.getToken();

  /// Starts token refresh sync. Safe to call multiple times.
  Future<void> startTokenSync() async {
    if (_started) return;
    _started = true;

    await syncTokenNow();

    _tokenRefreshSub = _messaging.onTokenRefresh.listen((token) async {
      await _persistToken(token);
    });
  }

  Future<void> stop() async {
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;
    _started = false;
  }

  /// Persists the current token to Firestore if a user is signed in.
  Future<void> syncTokenNow() async {
    final user = _authService.currentUser;
    if (user == null) return;
    final token = await _resolveFcmToken();
    await _persistToken(token);
  }

  /// On iOS, FCM [getToken] returns null until APNs registration completes.
  /// Auth provider (Apple / email / Google) does not matter — only timing does.
  Future<String?> _resolveFcmToken({
    Duration timeout = const Duration(seconds: 15),
    Duration pollInterval = const Duration(milliseconds: 500),
  }) async {
    final deadline = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(deadline)) {
      if (!kIsWeb && Platform.isIOS) {
        final apns = await _messaging.getAPNSToken();
        if (apns == null) {
          await Future<void>.delayed(pollInterval);
          continue;
        }
      }

      final token = await _messaging.getToken();
      if ((token ?? '').trim().isNotEmpty) {
        return token;
      }

      await Future<void>.delayed(pollInterval);
    }

    return _messaging.getToken();
  }

  Future<void> _persistToken(String? token) async {
    final user = _authService.currentUser;
    if (user == null) return;
    final trimmed = (token ?? '').trim();
    if (trimmed.isEmpty) return;

    try {
      await _firestoreRepository.updateUserProfile(fcmToken: trimmed);
    } catch (e, st) {
      logCaughtError('MessagingRepository._persistToken', e, st);
    }
  }

  /// Subscribes to `reminder` when Firestore allows reminders and OS permission is granted.
  Future<void> syncReminderTopicWithPreferences() async {
    if (_authService.currentUser == null) {
      _lastSyncedReminderTopicSubscribed = null;
      return;
    }
    try {
      final profile = await _firestoreRepository.getUserProfile();
      final os = await _localNotifications.areOsNotificationsEnabled();
      final pref = profile?.notificationsEnabled ?? true;
      final shouldSubscribe = pref && os;

      if (!shouldSubscribe) {
        await unsubscribeFromTopic('reminder');
        _lastSyncedReminderTopicSubscribed = false;
        return;
      }
      if (_lastSyncedReminderTopicSubscribed == true) return;
      await subscribeToTopic('reminder');
      _lastSyncedReminderTopicSubscribed = true;
    } catch (e, st) {
      logCaughtError('MessagingRepository.syncReminderTopicWithPreferences', e, st);
    }
  }

  /// Whether FCM reminder pushes should be surfaced (foreground mirror / UI).
  Future<bool> remoteReminderNotificationsAllowed() async {
    if (_authService.currentUser == null) return false;
    final profile = await _firestoreRepository.getUserProfile();
    if (profile != null && !profile.notificationsEnabled) return false;
    return _localNotifications.areOsNotificationsEnabled();
  }

  Stream<RemoteMessage> get onForegroundMessage => FirebaseMessaging.onMessage;

  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  Future<RemoteMessage?> getInitialMessage() => _messaging.getInitialMessage();

  void setPendingRoute(String? route) {
    final trimmed = (route ?? '').trim();
    _pendingRoute = trimmed.isEmpty ? null : trimmed;
  }

  String? consumePendingRoute() {
    final v = _pendingRoute;
    _pendingRoute = null;
    return v;
  }

  String? peekPendingRoute() => _pendingRoute;

  static String? routeFromMessage(RemoteMessage message) {
    final raw = message.data[dataRouteKey];
    if (raw is String) return raw.trim();
    return raw?.toString().trim();
  }

  static bool isNotificationTap(RemoteMessage message) {
    return message.notification != null || message.data.isNotEmpty;
  }

  Future<void> subscribeToTopic(String topic) async {
    if (topic == 'reminder') {
      _lastSyncedReminderTopicSubscribed = null;
    }
    await _messaging.subscribeToTopic(topic);
    if (topic == 'reminder') {
      _reminderTopicSubscribed = true;
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    if (topic == 'reminder') {
      _lastSyncedReminderTopicSubscribed = null;
    }
    await _messaging.unsubscribeFromTopic(topic);
    if (topic == 'reminder') {
      _reminderTopicSubscribed = false;
    }
  }

  bool get isReminderTopicSubscribed => _reminderTopicSubscribed;

  User? get currentUser => _authService.currentUser;
}
