import 'dart:async';

import 'package:daily_water_tracker/common/services/app_bootstrapper.dart';
import 'package:daily_water_tracker/common/utils/auto_goal_ml.dart';
import 'package:daily_water_tracker/common/utils/crashlytics.dart';
import 'package:daily_water_tracker/common/utils/drink_presets_utils.dart';
import 'package:daily_water_tracker/data/repositories/firestore_repository.dart';
import 'package:daily_water_tracker/features/preferences/preferences_constants.dart';
import 'package:daily_water_tracker/firebase/models/user_model.dart';
import 'package:daily_water_tracker/firebase/services/auth_service.dart';
import 'package:daily_water_tracker/firebase/services/reminder_scheduler_service.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'preferences_state.dart';

class PreferencesCubit extends Cubit<PreferencesState> {
  PreferencesCubit({
    required AuthService authService,
    required FirestoreRepository firestoreRepository,
    required ReminderSchedulerService reminderScheduler,
  }) : _authService = authService,
       _firestoreRepository = firestoreRepository,
       _reminderScheduler = reminderScheduler,
       super(const PreferencesLoading());

  final AuthService _authService;
  final FirestoreRepository _firestoreRepository;
  final ReminderSchedulerService _reminderScheduler;

  StreamSubscription<UserModel?>? _profileSub;

  Future<void> initialize() async {
    await _profileSub?.cancel();
    _profileSub = _firestoreRepository.watchUserProfile().listen((profile) {
      if (_authService.currentUser == null || profile == null) return;

      final prev = state;
      if (prev is PreferencesLoaded) {
        var autoDraft = prev.isAutoGoalDraft;
        final autoDirty = prev.autoGoalDraftDirty;
        if (!autoDirty && !prev.isSaving) {
          autoDraft = isAutoGoalEnabledForProfile(
            isAutoGoalEnabled: profile.isAutoGoalEnabled,
            weightKg: profile.weightKg,
          );
        }

        var draft = prev.dailyGoalMlDraft;
        final goalDirty = prev.goalDraftDirty;

        if (autoDraft) {
          draft = goalMlFromWeightKg(profile.weightKg!);
        } else if (!goalDirty && !prev.isSaving) {
          draft = profile.dailyGoalMl;
        }

        final presets = !prev.presetsDraftDirty && !prev.isSaving
            ? normalizeDrinkPresetsMl(profile.drinkPresets)
            : prev.drinkPresetsDraft;

        final reminderBlock = !prev.reminderDraftDirty && !prev.isSaving
            ? (
                _hoursDraftFromProfile(profile),
                _minutesDraftFromProfile(profile),
                profile.quietHoursStart,
                profile.quietHoursEnd,
              )
            : (
                prev.reminderIntervalDraft,
                prev.reminderIntervalMinutesDraft,
                prev.quietHoursStartDraft,
                prev.quietHoursEndDraft,
              );
        final reminderH = reminderBlock.$1;
        final reminderMin = reminderBlock.$2;
        final quietS = reminderBlock.$3;
        final quietE = reminderBlock.$4;

        emit(
          prev.copyWith(
            profile: profile,
            dailyGoalMlDraft: draft,
            isAutoGoalDraft: autoDraft,
            autoGoalDraftDirty: autoDirty,
            goalDraftDirty: goalDirty,
            drinkPresetsDraft: presets,
            presetsDraftDirty: prev.presetsDraftDirty,
            reminderIntervalDraft: reminderH,
            reminderIntervalMinutesDraft: reminderMin,
            quietHoursStartDraft: quietS,
            quietHoursEndDraft: quietE,
            reminderDraftDirty: prev.reminderDraftDirty,
            errorMessage: null,
          ),
        );
      } else {
        emit(
          PreferencesLoaded(
            profile: profile,
            dailyGoalMlDraft: profile.dailyGoalMl,
            isAutoGoalDraft: isAutoGoalEnabledForProfile(
              isAutoGoalEnabled: profile.isAutoGoalEnabled,
              weightKg: profile.weightKg,
            ),
            autoGoalDraftDirty: false,
            goalDraftDirty: false,
            drinkPresetsDraft: normalizeDrinkPresetsMl(profile.drinkPresets),
            presetsDraftDirty: false,
            reminderIntervalDraft: _hoursDraftFromProfile(profile),
            reminderIntervalMinutesDraft: _minutesDraftFromProfile(profile),
            quietHoursStartDraft: profile.quietHoursStart,
            quietHoursEndDraft: profile.quietHoursEnd,
            reminderDraftDirty: false,
            isSaving: false,
          ),
        );
      }
    });
  }

  static int? _hoursDraftFromProfile(UserModel p) {
    if (flutterFlavor.isDev && (p.reminderIntervalMinutes ?? 0) > 0) {
      return null;
    }
    return _reminderUiHours(p.reminderIntervalHours);
  }

  static int? _minutesDraftFromProfile(UserModel p) {
    if (!flutterFlavor.isDev) return null;
    final m = p.reminderIntervalMinutes;
    if (m != null && m > 0) return m;
    return null;
  }

  static int? _reminderUiHours(int? h) {
    if (h == null || h <= 0) return null;
    return h;
  }

  void clearSnackMessage() {
    final s = state;
    if (s is PreferencesLoaded && s.snackMessage != null) {
      emit(s.copyWith(snackMessage: null));
    }
  }

  void setDailyGoalMl(int rawMl) {
    final s = state;
    if (s is! PreferencesLoaded || s.isAutoGoalDraft) return;
    emit(
      s.copyWith(
        dailyGoalMlDraft: snapDailyGoalMl(rawMl),
        goalDraftDirty: true,
      ),
    );
  }

  void setAutoGoalEnabled(bool enabled) {
    final s = state;
    if (s is! PreferencesLoaded) return;

    if (!enabled) {
      emit(
        s.copyWith(
          isAutoGoalDraft: false,
          autoGoalDraftDirty: true,
        ),
      );
      return;
    }

    if (!hasWeightForAutoGoal(s.profile.weightKg)) {
      emit(
        s.copyWith(
          snackMessage: 'Please set your weight in My Profile first.',
        ),
      );
      return;
    }

    emit(
      s.copyWith(
        isAutoGoalDraft: true,
        autoGoalDraftDirty: true,
        dailyGoalMlDraft: goalMlFromWeightKg(s.profile.weightKg!),
        goalDraftDirty: false,
      ),
    );
  }

  void setDrinkPreset(int index, String raw) {
    final s = state;
    if (s is! PreferencesLoaded || index < 0 || index > 2) return;
    final parsed = int.tryParse(raw.trim());
    final next = List<int>.from(s.drinkPresetsDraft);
    next[index] = parsed ?? 0;
    emit(s.copyWith(drinkPresetsDraft: next, presetsDraftDirty: true));
  }

  void setReminderInterval(int? v) {
    final s = state;
    if (s is! PreferencesLoaded) return;

    if (v == kReminderDropdownDebugThreeMinutes) {
      if (!flutterFlavor.isDev) return;
      final quietStart =
          s.quietHoursStartDraft ?? s.profile.quietHoursStart ?? '22:00';
      final quietEnd =
          s.quietHoursEndDraft ?? s.profile.quietHoursEnd ?? '08:00';
      emit(
        s.copyWith(
          reminderIntervalDraft: null,
          reminderIntervalMinutesDraft: kDebugReminderIntervalMinutes,
          quietHoursStartDraft: quietStart,
          quietHoursEndDraft: quietEnd,
          reminderDraftDirty: true,
        ),
      );
      return;
    }

    final h = (v == null || v <= 0) ? null : v;
    final quietStart = h != null
        ? (s.quietHoursStartDraft ?? s.profile.quietHoursStart ?? '22:00')
        : s.quietHoursStartDraft;
    final quietEnd = h != null
        ? (s.quietHoursEndDraft ?? s.profile.quietHoursEnd ?? '08:00')
        : s.quietHoursEndDraft;
    emit(
      s.copyWith(
        reminderIntervalDraft: h,
        reminderIntervalMinutesDraft: null,
        quietHoursStartDraft: quietStart,
        quietHoursEndDraft: quietEnd,
        reminderDraftDirty: true,
      ),
    );
  }

  void setQuietHoursStart(String value) {
    final s = state;
    if (s is! PreferencesLoaded) return;
    emit(s.copyWith(quietHoursStartDraft: value, reminderDraftDirty: true));
  }

  void setQuietHoursEnd(String value) {
    final s = state;
    if (s is! PreferencesLoaded) return;
    emit(s.copyWith(quietHoursEndDraft: value, reminderDraftDirty: true));
  }

  Future<void> save() async {
    final current = state;
    if (current is! PreferencesLoaded) return;
    if (_authService.currentUser == null) return;

    emit(current.copyWith(isSaving: true, errorMessage: null));
    try {
      final resolvedPresets = normalizeDrinkPresetsMl(
        current.drinkPresetsDraft,
      );
      final off = !current.remindersOnInDraft;
      final start =
          current.quietHoursStartDraft ??
          current.profile.quietHoursStart ??
          '22:00';
      final end =
          current.quietHoursEndDraft ??
          current.profile.quietHoursEnd ??
          '08:00';

      final baseProfile = current.profile.copyWith(
        dailyGoalMl: current.dailyGoalMlDraft,
        isAutoGoalEnabled: current.isAutoGoalDraft,
        drinkPresets: resolvedPresets,
      );

      if (off) {
        await _firestoreRepository.updateUserProfile(
          dailyGoalMl: current.dailyGoalMlDraft,
          isAutoGoalEnabled: current.isAutoGoalDraft,
          drinkPresets: resolvedPresets,
          clearReminderIntervalHours: true,
          clearReminderIntervalMinutes: true,
          clearQuietHoursStart: true,
          clearQuietHoursEnd: true,
        );
        unawaited(
          _reminderScheduler.rescheduleReminders(
            lastIntakeAnchor: DateTime.now(),
          ),
        );
        emit(
          current.copyWith(
            isSaving: false,
            goalDraftDirty: false,
            autoGoalDraftDirty: false,
            presetsDraftDirty: false,
            reminderDraftDirty: false,
            profile: baseProfile.copyWith(
              reminderIntervalHours: null,
              reminderIntervalMinutes: null,
              quietHoursStart: null,
              quietHoursEnd: null,
            ),
            errorMessage: null,
          ),
        );
      } else {
        final debugMinutes =
            flutterFlavor.isDev &&
            (current.reminderIntervalMinutesDraft ==
                kDebugReminderIntervalMinutes) &&
            (current.reminderIntervalDraft == null);

        if (debugMinutes) {
          await _firestoreRepository.updateUserProfile(
            dailyGoalMl: current.dailyGoalMlDraft,
            isAutoGoalEnabled: current.isAutoGoalDraft,
            drinkPresets: resolvedPresets,
            clearReminderIntervalHours: true,
            reminderIntervalMinutes: kDebugReminderIntervalMinutes,
            quietHoursStart: start,
            quietHoursEnd: end,
          );
        } else {
          await _firestoreRepository.updateUserProfile(
            dailyGoalMl: current.dailyGoalMlDraft,
            isAutoGoalEnabled: current.isAutoGoalDraft,
            drinkPresets: resolvedPresets,
            reminderIntervalHours: current.reminderIntervalDraft,
            clearReminderIntervalMinutes: true,
            quietHoursStart: start,
            quietHoursEnd: end,
          );
        }

        unawaited(
          _reminderScheduler.rescheduleReminders(
            lastIntakeAnchor: DateTime.now(),
          ),
        );
        emit(
          current.copyWith(
            isSaving: false,
            goalDraftDirty: false,
            autoGoalDraftDirty: false,
            presetsDraftDirty: false,
            reminderDraftDirty: false,
            profile: baseProfile.copyWith(
              reminderIntervalHours: debugMinutes
                  ? null
                  : current.reminderIntervalDraft,
              reminderIntervalMinutes: debugMinutes
                  ? kDebugReminderIntervalMinutes
                  : null,
              quietHoursStart: start,
              quietHoursEnd: end,
            ),
            errorMessage: null,
          ),
        );
      }
    } catch (e, st) {
      await recordCrashlyticsError(
        e,
        StackTrace.current,
        st,
        reason: 'PreferencesCubit.save',
      );
      emit(
        current.copyWith(
          isSaving: false,
          errorMessage: LocaleKeys.preferences_error_save_failed,
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _profileSub?.cancel();
    return super.close();
  }
}
