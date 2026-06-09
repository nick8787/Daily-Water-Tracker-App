import 'dart:async';

import 'package:daily_water_tracker/data/repositories/messaging_repository.dart';
import 'package:daily_water_tracker/firebase/services/auth_service.dart';
import 'package:daily_water_tracker/firebase/services/local_notifications_service.dart';
import 'package:daily_water_tracker/firebase/services/reminder_scheduler_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'push_session_state.dart';

/// Auth session side effects for FCM, local notifications and reminder scheduling
class PushSessionCubit extends Cubit<PushSessionState> {
  PushSessionCubit({
    required AuthService authService,
    required MessagingRepository messagingRepository,
    required LocalNotificationsService localNotifications,
    required ReminderSchedulerService reminderScheduler,
  })  : _auth = authService,
        _messaging = messagingRepository,
        _localNotifications = localNotifications,
        _reminderScheduler = reminderScheduler,
        super(
          PushSessionState(isSignedIn: authService.currentUser != null),
        );

  final AuthService _auth;
  final MessagingRepository _messaging;
  final LocalNotificationsService _localNotifications;
  final ReminderSchedulerService _reminderScheduler;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<RemoteMessage>? _openedSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  bool _started = false;
  bool _coldStartInitialized = false;

  static const Duration _signInSetupDelay = Duration(milliseconds: 600);
  static const Duration _coldStartDelay = Duration(milliseconds: 400);

  /// Wire FCM and auth streams. Call once after construction.
  void start() {
    if (_started) return;
    _started = true;

    _openedSub = _messaging.onMessageOpenedApp.listen(handleMessageOpened);
    _foregroundSub =
        _messaging.onForegroundMessage.listen(handleForegroundMessage);

    _authSub = _auth.authStateChanges().listen(_onAuthUserChanged);
  }

  /// Timezone, OS permissions, reminders, and notification cold-start route.
  Future<void> initializeColdStart() async {
    if (_coldStartInitialized) return;
    _coldStartInitialized = true;

    await Future<void>.delayed(_coldStartDelay);
    await ReminderSchedulerService.ensureTimeZonesInitialized();
    await _localNotifications.ensureAndroidSchedulingPermissions();

    if (_auth.currentUser != null) {
      await _messaging.setupPushNotificationsForSignedInUser();
      await _reminderScheduler.rescheduleReminders();
    }

    final coldRoute = await _localNotifications.consumeLaunchNotificationRoute();
    if (coldRoute == null) return;

    emit(
      state.copyWith(
        pendingNavigation: PushSessionNavigateRoute(coldRoute),
      ),
    );
  }

  void clearNavigation() {
    if (state.pendingNavigation == null) return;
    emit(state.copyWith(clearNavigation: true));
  }

  void handleMessageOpened(RemoteMessage message) {
    final route = MessagingRepository.routeFromMessage(message);
    if (_messaging.currentUser == null) {
      _messaging.setPendingRoute(route);
      emit(
        state.copyWith(
          pendingNavigation: const PushSessionNavigateLogin(),
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        pendingNavigation: PushSessionNavigateRoute(route),
      ),
    );
  }

  Future<void> handleForegroundMessage(RemoteMessage message) async {
    if (!await _messaging.remoteReminderNotificationsAllowed()) return;

    final title = message.notification?.title;
    final body = message.notification?.body;
    if ((title ?? '').trim().isEmpty &&
        (body ?? '').trim().isEmpty &&
        message.data.isEmpty) {
      return;
    }

    final id = DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);
    await _localNotifications.showForegroundNotification(
      id: id,
      title: title,
      body: body,
      data: message.data,
    );
  }

  void _onAuthUserChanged(User? user) {
    if (user == null) {
      emit(state.copyWith(isSignedIn: false));
      unawaited(_onSignedOut());
      return;
    }
    emit(state.copyWith(isSignedIn: true));
    unawaited(_onSignedIn());
  }

  Future<void> _onSignedOut() async {
    await _messaging.teardownPushForSignedOutUser();
    await _reminderScheduler.cancelAllScheduled();
  }

  Future<void> _onSignedIn() async {
    await Future<void>.delayed(_signInSetupDelay);
    await _messaging.setupPushNotificationsForSignedInUser();
    await _reminderScheduler.rescheduleReminders();
  }

  /// Re-sync permissions, FCM token and broadcast topic when returning from background
  Future<void> onAppResumed() async {
    if (_auth.currentUser == null) return;
    await _messaging.setupPushNotificationsForSignedInUser();
  }

  @override
  Future<void> close() {
    _authSub?.cancel();
    _openedSub?.cancel();
    _foregroundSub?.cancel();
    return super.close();
  }
}
