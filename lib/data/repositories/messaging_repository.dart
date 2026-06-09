import 'dart:async';
import 'dart:io';

import 'package:daily_water_tracker/common/services/logger.dart';
import 'package:daily_water_tracker/data/repositories/firestore_repository.dart';
import 'package:daily_water_tracker/firebase/fcm_topics.dart';
import 'package:daily_water_tracker/firebase/services/auth_service.dart';
import 'package:daily_water_tracker/firebase/services/local_notifications_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
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
  Timer? _deferredRegistrationTimer;
  bool _started = false;
  bool _platformConfigured = false;
  bool _broadcastTopicSubscribed = false;
  String? _pendingRoute;
  Future<void>? _coldStartHydration;

  static const String dataRouteKey = 'route';
  static const Duration _deferredRegistrationDelay = Duration(seconds: 15);
  static const Duration _tokenResolveTimeout = Duration(seconds: 30);

  /// One-time FCM platform setup (safe to call multiple times).
  Future<void> configurePlatformMessaging() async {
    if (_platformConfigured || kIsWeb) return;
    _platformConfigured = true;
    try {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e, st) {
      logCaughtWarning('MessagingRepository.configurePlatformMessaging', e, st);
    }
  }

  /// Reads the FCM message that launched the app from terminated state (if any).
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

  /// Full push registration for a signed-in user
  Future<void> setupPushNotificationsForSignedInUser() async {
    if (_authService.currentUser == null) return;
    try {
      await configurePlatformMessaging();
      await _requestPermissionsBestEffort();
      await startTokenSync();
      await ensureBroadcastRegistration();
      _scheduleDeferredRegistrationRetry();
    } catch (e, st) {
      logCaughtError('MessagingRepository.setupPushNotificationsForSignedInUser', e, st);
    }
  }

  /// Idempotent token persist + broadcast topic subscribe (safe on every resume)
  Future<void> ensureBroadcastRegistration() async {
    if (_authService.currentUser == null) return;
    try {
      await configurePlatformMessaging();
      if (!_started) {
        await startTokenSync();
      }
      await syncTokenNow();
      await _ensureBroadcastTopicSubscribed();
    } catch (e, st) {
      logCaughtError('MessagingRepository.ensureBroadcastRegistration', e, st);
    }
  }

  Future<void> teardownPushForSignedOutUser() async {
    _cancelDeferredRegistrationRetry();
    try {
      if (_broadcastTopicSubscribed) {
        await unsubscribeFromTopic(FcmTopics.broadcast);
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
      await _ensureBroadcastTopicSubscribed();
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
    if ((token ?? '').trim().isEmpty) {
      _scheduleDeferredRegistrationRetry();
    }
  }

  /// On iOS, FCM [getToken] returns null until APNs registration completes.
  Future<String?> _resolveFcmToken({
    Duration timeout = _tokenResolveTimeout,
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

  Future<void> _ensureBroadcastTopicSubscribed() async {
    if (_authService.currentUser == null) return;
    await subscribeToTopic(FcmTopics.broadcast);
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
    await _messaging.subscribeToTopic(topic);
    if (topic == FcmTopics.broadcast) {
      _broadcastTopicSubscribed = true;
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    if (topic == FcmTopics.broadcast) {
      _broadcastTopicSubscribed = false;
    }
  }

  bool get isReminderTopicSubscribed => _broadcastTopicSubscribed;

  User? get currentUser => _authService.currentUser;

  Future<void> _requestPermissionsBestEffort() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await Permission.notification.request();
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      await _localNotifications.requestOsNotificationPermissions();
    }
    await requestPermission();
  }

  void _scheduleDeferredRegistrationRetry() {
    if (_authService.currentUser == null) return;
    _deferredRegistrationTimer?.cancel();
    _deferredRegistrationTimer = Timer(_deferredRegistrationDelay, () {
      unawaited(_runDeferredRegistrationRetry());
    });
  }

  void _cancelDeferredRegistrationRetry() {
    _deferredRegistrationTimer?.cancel();
    _deferredRegistrationTimer = null;
  }

  Future<void> _runDeferredRegistrationRetry() async {
    if (_authService.currentUser == null) return;
    try {
      await ensureBroadcastRegistration();
    } catch (e, st) {
      logCaughtWarning('MessagingRepository._runDeferredRegistrationRetry', e, st);
    }
  }
}
