import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

import 'package:daily_water_tracker/common/di/injector_module.dart';
import 'package:daily_water_tracker/common/services/app_bootstrapper.dart';
import 'package:daily_water_tracker/common/widgets/app_primary_button.dart';
import 'package:daily_water_tracker/common/widgets/app_snackbar.dart';
import 'package:daily_water_tracker/features/preferences/reminder_messages.dart';
import 'package:daily_water_tracker/features/theme/theme_info.dart';
import 'package:daily_water_tracker/firebase/models/user_model.dart';
import 'package:daily_water_tracker/firebase/services/auth_service.dart';
import 'package:daily_water_tracker/data/repositories/firestore_repository.dart';
import 'package:daily_water_tracker/firebase/services/local_notifications_service.dart';
import 'package:daily_water_tracker/firebase/services/reminder_scheduler_service.dart';
import 'package:intl/intl.dart';
import 'package:daily_water_tracker/common/services/logger.dart';

class RemindersDebugPanel extends StatefulWidget {
  const RemindersDebugPanel({super.key});

  @override
  State<RemindersDebugPanel> createState() => _RemindersDebugPanelState();
}

class _RemindersDebugPanelState extends State<RemindersDebugPanel> {
  late final ReminderSchedulerService _scheduler;
  late final LocalNotificationsService _local;
  late final FirestoreRepository _firestore;
  final AuthService _auth = InjectorModule.locator<AuthService>();

  static final _dateFmt = DateFormat('yyyy-MM-dd HH:mm:ss');

  UserModel? _profile;
  bool _busy = false;
  DateTime? _lastProfileFetch;
  Timer? _uiTimer;
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    _scheduler = context.read<ReminderSchedulerService>();
    _local = InjectorModule.locator<LocalNotificationsService>();
    _firestore = context.read<FirestoreRepository>();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => unawaited(_initialLoad()),
    );
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    _syncTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      unawaited(_pullNextSlot(silent: true));
    });
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    _syncTimer?.cancel();
    super.dispose();
  }

  Future<void> _initialLoad() async {
    setState(() => _busy = true);
    try {
      await _pullNextSlot(silent: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pullNextSlot({required bool silent}) async {
    if (!mounted) return;
    if (!silent) setState(() => _busy = true);
    try {
      await ReminderSchedulerService.ensureTimeZonesInitialized();
      await _scheduler.syncDebugNextSlotIfStale();
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        _profile = null;
      } else {
        final now = DateTime.now();
        if (_profile == null ||
            _lastProfileFetch == null ||
            now.difference(_lastProfileFetch!) > const Duration(seconds: 45)) {
          _profile = await _firestore.getUserProfile();
          _lastProfileFetch = now;
        }
      }
      if (mounted) setState(() {});
    } finally {
      if (!silent && mounted) setState(() => _busy = false);
    }
  }

  bool get _remindersEnabled {
    final p = _profile;
    if (p == null) return false;
    if (flutterFlavor.isDev && (p.reminderIntervalMinutes ?? 0) > 0)
      return true;
    return (p.reminderIntervalHours ?? 0) > 0;
  }

  String? _countdownToNext() {
    final next = _scheduler.debugNextScheduledReminderLocal;
    if (next == null) return null;
    final d = next.difference(DateTime.now());
    if (d.isNegative) return LocaleKeys.debug_reminders_updating.tr();
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60);
    return LocaleKeys.debug_reminders_countdown.tr(
      namedArgs: {
        'minutes': '$m',
        'seconds': s.toString().padLeft(2, '0'),
      },
    );
  }

  Future<void> _resetScheduler() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await _scheduler.rescheduleReminders(lastIntakeAnchor: DateTime.now());
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        _profile = await _firestore.getUserProfile();
        _lastProfileFetch = DateTime.now();
      }
      if (mounted) setState(() {});
      if (mounted) {
        AppSnackBar.showSuccess(
          context,
          title: LocaleKeys.preferences_section_reminders.tr(),
          message: LocaleKeys.debug_reminders_refreshed.tr(),
          dismissAfter: const Duration(seconds: 3),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _testInstantLocalPush() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ReminderSchedulerService.ensureTimeZonesInitialized();
      await _local.ensureAndroidSchedulingPermissions();
      await _local.requestIosNotificationPermissions();

      final copy = ReminderMessages.pick();
      await _local.showDebugImmediateNotification(
        id: LocalNotificationsService.debugScheduledTestNotificationId,
        title: copy.title,
        body: copy.body,
        routePayload: ReminderSchedulerService.hydrationReminderRoute,
      );
      if (mounted) {
        AppSnackBar.showSuccess(
          context,
          title: 'debug.reminders.test_title'.tr(),
          message: LocaleKeys.debug_reminders_test_sent.tr(),
          dismissAfter: const Duration(seconds: 2),
        );
      }
    } catch (e, st) {
      logCaughtError('RemindersDebugPanel', e, st);
      if (mounted) {
        AppSnackBar.showError(
          context,
          LocaleKeys.debug_reminders_test_failed.tr(namedArgs: {'error': '$e'}),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final next = _scheduler.debugNextScheduledReminderLocal;
    final nextLabel =
        next == null ? LocaleKeys.debug_reminders_none.tr() : _dateFmt.format(next);
    final countdown = _countdownToNext();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 4, right: 10),
                decoration: BoxDecoration(
                  color: _remindersEnabled
                      ? successGreen
                      : redLight,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.debug_reminders_next.tr(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.55,
                        ),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      nextLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (countdown != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        countdown,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AppGradientButton(
            label: LocaleKeys.debug_reminders_reset.tr(),
            icon: Icons.restore_rounded,
            busy: _busy,
            enabled: !_busy,
            onTap: () => unawaited(_resetScheduler()),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _busy ? null : () => unawaited(_testInstantLocalPush()),
            icon: const Icon(Icons.notifications_active_outlined, size: 20),
            label: Text(LocaleKeys.debug_reminders_test_button.tr()),
            style: OutlinedButton.styleFrom(
              foregroundColor: brandBlue,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              side: BorderSide(color: brandBlue.withValues(alpha: 0.45)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
