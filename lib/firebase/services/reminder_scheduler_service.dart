import 'dart:async';

import 'package:daily_water_tracker/common/services/logger.dart';
import 'package:daily_water_tracker/common/utils/crashlytics.dart';
import 'package:daily_water_tracker/data/repositories/firestore_repository.dart';
import 'package:daily_water_tracker/features/preferences/reminder_messages.dart';
import 'package:daily_water_tracker/features/preferences/services/reminder_quiet_hours.dart';
import 'package:daily_water_tracker/firebase/models/user_model.dart';
import 'package:daily_water_tracker/firebase/services/auth_service.dart';
import 'package:daily_water_tracker/firebase/services/local_notifications_service.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Firestore-driven hydration reminders (interval + quiet hours); tap reschedules chain.
class ReminderSchedulerService {
  ReminderSchedulerService({
    required AuthService authService,
    required FirestoreRepository firestoreRepository,
    required LocalNotificationsService localNotifications,
    required bool Function() isDevBuild,
    Future<void> Function()? onAfterReminderPipeline,
  })  : _auth = authService,
        _firestore = firestoreRepository,
        _local = localNotifications,
        _isDevBuild = isDevBuild,
        _onAfterReminderPipeline = onAfterReminderPipeline;

  final AuthService _auth;
  final FirestoreRepository _firestore;
  final LocalNotificationsService _local;
  final bool Function() _isDevBuild;
  final Future<void> Function()? _onAfterReminderPipeline;

  static const String hydrationReminderRoute = 'hydration_reminder';

  static const int _scheduleStartId = 910001;
  static const int _scheduleEndId = 910024;
  static const int _futureSlotCount = 24;

  static bool _timeZonesReady = false;

  static const Map<String, String> _ianaTimezoneAliases = {
    'Europe/Kiev': 'Europe/Kyiv',
    'Atlantic/Faeroe': 'Atlantic/Faroe',
  };

  static tz.Location resolveLocalLocation(String ianaFromDevice) {
    final raw = ianaFromDevice.trim();
    if (raw.isEmpty) {
      return _locationFromDeviceOffsetOrUtc();
    }
    final tried = <String>{};
    for (final id in <String>[
      raw,
      if (_ianaTimezoneAliases[raw] != null) _ianaTimezoneAliases[raw]!,
    ]) {
      if (id.isEmpty || tried.contains(id)) continue;
      tried.add(id);
      try {
        return tz.getLocation(id);
      } catch (e, st) {
        logCaughtWarning('ReminderScheduler.resolveLocalLocation: $id', e, st);
      }
    }
    return _locationFromDeviceOffsetOrUtc();
  }

  static tz.Location _locationFromDeviceOffsetOrUtc() {
    final offset = DateTime.now().timeZoneOffset;
    final etc = _etcIanaNameForOffset(offset);
    if (etc != null) {
      try {
        log.fine('ReminderScheduler: tz fallback $etc (offset $offset)');
        return tz.getLocation(etc);
      } catch (e, st) {
        logCaughtWarning('ReminderScheduler._locationFromDeviceOffsetOrUtc: $etc', e, st);
      }
    }
    log.fine('ReminderScheduler: tz fallback UTC (fractional offset)');
    return tz.UTC;
  }

  static String? _etcIanaNameForOffset(Duration offset) {
    final mins = offset.inMinutes;
    if (mins == 0) return 'UTC';
    if (mins % 60 != 0) return null;
    final h = mins ~/ 60;
    if (h > 0) return 'Etc/GMT-$h';
    if (h < 0) return 'Etc/GMT+${-h}';
    return 'UTC';
  }

  static void logTimezoneDiagnostic() {
    if (_timeZonesReady) {
      log.fine('ReminderScheduler: tz ready → ${tz.local.name}');
    } else {
      log.fine('ReminderScheduler: tz not ready');
    }
  }

  DateTime? _debugNextScheduledReminderLocal;

  DateTime? get debugNextScheduledReminderLocal => _debugNextScheduledReminderLocal;

  static Future<void> ensureTimeZonesInitialized() async {
    if (_timeZonesReady) return;
    try {
      tzdata.initializeTimeZones();
      final name = await FlutterTimezone.getLocalTimezone();
      final loc = resolveLocalLocation(name);
      tz.setLocalLocation(loc);
      _timeZonesReady = true;
      log.fine('ReminderScheduler: timezone $name → ${loc.name}');
    } catch (e, st) {
      logCaughtError('ReminderSchedulerService.ensureTimeZonesInitialized', e, st);
      await basicRecordCrashlyticsError(e, st, reason: 'ReminderSchedulerService.ensureTimeZonesInitialized');
      try {
        tzdata.initializeTimeZones();
        tz.setLocalLocation(_locationFromDeviceOffsetOrUtc());
        _timeZonesReady = true;
        log.fine('ReminderScheduler: timezone recovery → ${tz.local.name}');
      } catch (e2, s2) {
        logCaughtError('ReminderSchedulerService.ensureTimeZonesInitialized recovery', e2, s2);
      }
    }
  }

  Future<void> cancelAllScheduled() async {
    _debugNextScheduledReminderLocal = null;
    await _local.cancelNotificationIdsInclusive(_scheduleStartId, _scheduleEndId);
  }

  /// Clears scheduled local reminders (user disabled in app).
  Future<void> cancelAllReminders() async {
    await cancelAllScheduled();
  }

  Duration? _reminderStep(UserModel profile) {
    if (_isDevBuild()) {
      final m = profile.reminderIntervalMinutes;
      if (m != null && m > 0) {
        return Duration(minutes: m);
      }
    }
    final h = profile.reminderIntervalHours;
    if (h != null && h > 0) return Duration(hours: h);
    return null;
  }

  Future<void> rescheduleReminders({DateTime? lastIntakeAnchor}) async {
    try {
      await ensureTimeZonesInitialized();
      if (!_timeZonesReady) {
        await cancelAllScheduled();
        return;
      }

      final user = _auth.currentUser;
      if (user == null) {
        await cancelAllScheduled();
        return;
      }

      UserModel? profile;
      try {
        profile = await _firestore.getUserProfile();
      } catch (e, st) {
        await recordCrashlyticsError(e, StackTrace.current, st, reason: 'ReminderSchedulerService.getUserProfile');
        return;
      }
      if (profile == null) {
        await cancelAllScheduled();
        return;
      }

      if (!profile.notificationsEnabled) {
        await cancelAllScheduled();
        return;
      }

      if (!await _local.areOsNotificationsEnabled()) {
        await cancelAllScheduled();
        return;
      }

      final step = _reminderStep(profile);
      if (step == null || step.inSeconds <= 0) {
        await cancelAllScheduled();
        return;
      }

      await cancelAllScheduled();

      await _local.ensureAndroidSchedulingPermissions();
      await _local.requestOsNotificationPermissions();

      final anchor = lastIntakeAnchor ?? DateTime.now();
      final qs = ReminderQuietHours.parseMinutes(profile.quietHoursStart);
      final qe = ReminderQuietHours.parseMinutes(profile.quietHoursEnd);

      final now = DateTime.now();
      var slot = 0;
      var k = 0;
      const maxK = 200;
      DateTime? prevAccepted;
      DateTime? firstSlot;

      while (slot < _futureSlotCount && k < maxK) {
        k++;
        final raw = anchor.add(step * k);
        final adjusted = ReminderQuietHours.adjustIfInQuiet(
          raw,
          quietStartMin: qs,
          quietEndMin: qe,
        );
        if (!adjusted.isAfter(now.add(const Duration(seconds: 2)))) {
          continue;
        }
        if (prevAccepted != null && !adjusted.isAfter(prevAccepted)) {
          continue;
        }
        prevAccepted = adjusted;
        firstSlot ??= adjusted;

        final copy = ReminderMessages.pick();
        final id = _scheduleStartId + slot;
        slot++;

        try {
          await _local.scheduleZonedOneShot(
            id: id,
            when: adjusted,
            title: copy.title,
            body: copy.body,
            routePayload: hydrationReminderRoute,
          );
        } catch (e, st) {
          logCaughtError(
            'ReminderSchedulerService.schedule slot id=$id at $adjusted',
            e,
            st,
          );
          await recordCrashlyticsError(
            e,
            StackTrace.current,
            st,
            reason: 'ReminderSchedulerService.schedule slot',
          );
        }
      }

      await _local.logPendingScheduledSummary(startId: _scheduleStartId, endId: _scheduleEndId);

      _debugNextScheduledReminderLocal = firstSlot;
      log.fine(
        'ReminderScheduler: reminder chain refreshed ($slot slots, next=${firstSlot?.toIso8601String() ?? "none"})',
      );
    } finally {
      try {
        await _onAfterReminderPipeline?.call();
      } catch (e, st) {
        logCaughtError('ReminderScheduler.onAfterReminderPipeline', e, st);
      }
    }
  }

  Future<void> syncDebugNextSlotIfStale() async {
    await ensureTimeZonesInitialized();
    if (!_timeZonesReady) return;

    final next = _debugNextScheduledReminderLocal;
    final now = DateTime.now();
    if (next == null || !next.isAfter(now.subtract(const Duration(seconds: 2)))) {
      await rescheduleReminders(lastIntakeAnchor: DateTime.now());
    }
  }
}
