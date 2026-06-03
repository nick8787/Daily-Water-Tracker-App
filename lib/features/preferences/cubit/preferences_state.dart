import 'package:equatable/equatable.dart';
import 'package:daily_water_tracker/common/services/app_bootstrapper.dart';
import 'package:daily_water_tracker/common/utils/auto_goal_ml.dart';
import 'package:daily_water_tracker/common/utils/drink_presets_utils.dart';
import 'package:daily_water_tracker/firebase/models/user_model.dart';

sealed class PreferencesState extends Equatable {
  const PreferencesState();

  @override
  List<Object?> get props => [];
}

class PreferencesLoading extends PreferencesState {
  const PreferencesLoading();
}

class PreferencesLoaded extends PreferencesState {
  const PreferencesLoaded({
    required this.profile,
    required this.dailyGoalMlDraft,
    required this.isAutoGoalDraft,
    required this.autoGoalDraftDirty,
    required this.goalDraftDirty,
    required this.drinkPresetsDraft,
    required this.presetsDraftDirty,
    required this.reminderIntervalDraft,
    required this.reminderIntervalMinutesDraft,
    required this.quietHoursStartDraft,
    required this.quietHoursEndDraft,
    required this.reminderDraftDirty,
    required this.isSaving,
    this.errorMessage,
    this.snackMessage,
  });

  static const Object _noChange = Object();

  final UserModel profile;
  final int dailyGoalMlDraft;
  final bool isAutoGoalDraft;
  final bool autoGoalDraftDirty;
  final bool goalDraftDirty;

  final List<int> drinkPresetsDraft;
  final bool presetsDraftDirty;

  final int? reminderIntervalDraft;

  final int? reminderIntervalMinutesDraft;

  final String? quietHoursStartDraft;
  final String? quietHoursEndDraft;
  final bool reminderDraftDirty;

  final bool isSaving;
  final String? errorMessage;
  final String? snackMessage;

  bool get hasUnsavedChanges {
    if (isAutoGoalDraft !=
        isAutoGoalEnabledForProfile(
          isAutoGoalEnabled: profile.isAutoGoalEnabled,
          weightKg: profile.weightKg,
        )) {
      return true;
    }
    if (dailyGoalMlDraft != profile.dailyGoalMl) return true;
    final a = normalizeDrinkPresetsMl(drinkPresetsDraft);
    final b = normalizeDrinkPresetsMl(profile.drinkPresets);
    if (a[0] != b[0] || a[1] != b[1] || a[2] != b[2]) return true;
    if (_reminderPrefsDifferFromProfile) return true;
    if (remindersOnInDraft) {
      if ((quietHoursStartDraft ?? '') != (profile.quietHoursStart ?? ''))
        return true;
      if ((quietHoursEndDraft ?? '') != (profile.quietHoursEnd ?? ''))
        return true;
    }
    return false;
  }

  bool get remindersOnInDraft {
    final h = reminderIntervalDraft;
    final m = reminderIntervalMinutesDraft;
    return (h != null && h > 0) || (m != null && m > 0);
  }

  bool get _reminderPrefsDifferFromProfile {
    final ph = _normHours(profile.reminderIntervalHours);
    final pm = _normMinutesForCompare(profile.reminderIntervalMinutes);
    final dh = _normHours(reminderIntervalDraft);
    final dm = _normMinutesForCompare(reminderIntervalMinutesDraft);
    return ph != dh || pm != dm;
  }

  static int? _normHours(int? h) {
    if (h == null || h <= 0) return null;
    return h;
  }

  static int? _normMinutesForCompare(int? m) {
    if (!flutterFlavor.isDev) return null;
    if (m == null || m <= 0) return null;
    return m;
  }

  @override
  List<Object?> get props => [
    profile,
    dailyGoalMlDraft,
    isAutoGoalDraft,
    autoGoalDraftDirty,
    goalDraftDirty,
    drinkPresetsDraft,
    presetsDraftDirty,
    reminderIntervalDraft,
    reminderIntervalMinutesDraft,
    quietHoursStartDraft,
    quietHoursEndDraft,
    reminderDraftDirty,
    isSaving,
    errorMessage,
    snackMessage,
  ];

  PreferencesLoaded copyWith({
    UserModel? profile,
    int? dailyGoalMlDraft,
    bool? isAutoGoalDraft,
    bool? autoGoalDraftDirty,
    bool? goalDraftDirty,
    List<int>? drinkPresetsDraft,
    bool? presetsDraftDirty,
    Object? reminderIntervalDraft = _noChange,
    Object? reminderIntervalMinutesDraft = _noChange,
    Object? quietHoursStartDraft = _noChange,
    Object? quietHoursEndDraft = _noChange,
    bool? reminderDraftDirty,
    bool? isSaving,
    Object? errorMessage = _noChange,
    Object? snackMessage = _noChange,
  }) {
    return PreferencesLoaded(
      profile: profile ?? this.profile,
      dailyGoalMlDraft: dailyGoalMlDraft ?? this.dailyGoalMlDraft,
      isAutoGoalDraft: isAutoGoalDraft ?? this.isAutoGoalDraft,
      autoGoalDraftDirty: autoGoalDraftDirty ?? this.autoGoalDraftDirty,
      goalDraftDirty: goalDraftDirty ?? this.goalDraftDirty,
      drinkPresetsDraft: drinkPresetsDraft ?? this.drinkPresetsDraft,
      presetsDraftDirty: presetsDraftDirty ?? this.presetsDraftDirty,
      reminderIntervalDraft: identical(reminderIntervalDraft, _noChange)
          ? this.reminderIntervalDraft
          : reminderIntervalDraft as int?,
      reminderIntervalMinutesDraft:
          identical(reminderIntervalMinutesDraft, _noChange)
          ? this.reminderIntervalMinutesDraft
          : reminderIntervalMinutesDraft as int?,
      quietHoursStartDraft: identical(quietHoursStartDraft, _noChange)
          ? this.quietHoursStartDraft
          : quietHoursStartDraft as String?,
      quietHoursEndDraft: identical(quietHoursEndDraft, _noChange)
          ? this.quietHoursEndDraft
          : quietHoursEndDraft as String?,
      reminderDraftDirty: reminderDraftDirty ?? this.reminderDraftDirty,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: identical(errorMessage, _noChange)
          ? this.errorMessage
          : errorMessage as String?,
      snackMessage: identical(snackMessage, _noChange)
          ? this.snackMessage
          : snackMessage as String?,
    );
  }
}
