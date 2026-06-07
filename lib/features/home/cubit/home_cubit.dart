import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_water_tracker/common/services/analytics_service.dart';
import 'package:daily_water_tracker/common/utils/crashlytics.dart';
import 'package:daily_water_tracker/common/utils/drink_presets_utils.dart';
import 'package:daily_water_tracker/data/repositories/firestore_repository.dart';
import 'package:daily_water_tracker/features/achievements/logic/achievements_calculator.dart';
import 'package:daily_water_tracker/features/achievements/logic/rank_celebration_logic.dart';
import 'package:daily_water_tracker/firebase/services/reminder_scheduler_service.dart';

import '../../../firebase/models/drink_type.dart';
import '../../../firebase/models/user_model.dart';
import '../../../firebase/models/water_record_model.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required FirestoreRepository firestoreRepository,
    required AnalyticsService analytics,
    required ReminderSchedulerService reminderScheduler,
  })  : _firestoreRepository = firestoreRepository,
        _analytics = analytics,
        _reminderScheduler = reminderScheduler,
        super(HomeState.initial()) {
    _listenDayRecords(state.selectedDate);
    _dayRolloverTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => syncAnchoredTodayIfNeeded(),
    );

    _profileSub = _firestoreRepository.watchUserProfile().listen(
      (profile) {
        if (profile == null) return;
        unawaited(_firestoreRepository.reconcileAutoDailyGoalIfNeeded(profile));
        emit(
          state.copyWith(
            dailyLimitMl: profile.dailyWaterLimit,
            drinkPresetsMl: normalizeDrinkPresetsMl(profile.drinkPresets),
            errorCode: state.errorCode,
          ),
        );
      },
      onError: (Object error, StackTrace st) {
        recordCrashlyticsError(
          error,
          st,
          st,
          reason: 'HomeCubit: watchUserProfile error',
        );
        final code = (error is FirebaseException) ? error.code : 'unknown';
        emit(state.copyWith(isLoading: false, errorCode: code));
      },
    );
  }

  final FirestoreRepository _firestoreRepository;
  final AnalyticsService _analytics;
  final ReminderSchedulerService _reminderScheduler;
  StreamSubscription<List<WaterRecordModel>>? _recordsSub;
  StreamSubscription<UserModel?>? _profileSub;
  Timer? _dayRolloverTimer;

  static DateTime _calendarDay(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime get _todayCalendar => _calendarDay(DateTime.now());

  static ({int raw, int effective}) _totalsFromRecords(
    List<WaterRecordModel> records,
  ) {
    var raw = 0;
    var effectiveSum = 0.0;
    for (final r in records) {
      raw += r.volumeMl;
      effectiveSum += r.effectiveHydrationMl;
    }
    return (raw: raw, effective: effectiveSum.round());
  }

  void selectCalendarDay(DateTime day) {
    final next = _calendarDay(day);
    if (next.isAfter(_todayCalendar)) return;
    if (next == state.selectedDate) return;

    emit(
      state.copyWith(
        selectedDate: next,
        isLoading: true,
        records: const <WaterRecordModel>[],
        totalRawMl: 0,
        totalEffectiveMl: 0,
        anchoredToLiveToday: next == _todayCalendar,
        clearPendingRecords: true,
      ),
    );
    _listenDayRecords(next);
  }

  void goToPreviousCalendarDay() {
    selectCalendarDay(state.selectedDate.subtract(const Duration(days: 1)));
  }

  void goToNextCalendarDay() {
    final next = state.selectedDate.add(const Duration(days: 1));
    if (next.isAfter(_todayCalendar)) return;
    selectCalendarDay(next);
  }

  bool get canGoToNextCalendarDay {
    return state.selectedDate.isBefore(_todayCalendar);
  }

  Future<void> addWaterRecord({
    required int volumeMl,
    required DrinkType drinkType,
  }) async {
    try {
      await _firestoreRepository.addWaterRecord(
        volumeMl: volumeMl,
        drinkType: drinkType,
      );
      unawaited(
        _reminderScheduler.rescheduleReminders(
          lastIntakeAnchor: DateTime.now(),
        ),
      );
      unawaited(
        _analytics.logDrinkWater(
          volumeMl: volumeMl,
          drinkTypeWire: drinkType.wireName,
        ),
      );
      await _syncRankCelebrationAfterHydrationChange(allowCelebration: true);
    } catch (e, st) {
      recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'HomeCubit: addWaterRecord failed',
      );
      rethrow;
    }
  }

  Future<void> updateWaterRecord({
    required String recordKey,
    required int volumeMl,
    required DrinkType drinkType,
    required DateTime timestamp,
    DateTime? calendarDay,
  }) async {
    try {
      await _firestoreRepository.updateDayWaterEntry(
        calendarDay: calendarDay ?? state.selectedDate,
        recordKey: recordKey,
        volumeMl: volumeMl,
        drinkType: drinkType,
        timestamp: timestamp,
      );
      unawaited(
        _analytics.logWaterRecordUpdated(
          volumeMl: volumeMl,
          drinkTypeWire: drinkType.wireName,
        ),
      );
      unawaited(_syncRankCelebrationAfterHydrationChange());
    } catch (e, st) {
      recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'HomeCubit: updateWaterRecord failed',
      );
      rethrow;
    }
  }

  Future<void> deleteWaterRecord(
    String recordKey, {
    DateTime? calendarDay,
  }) async {
    try {
      await _firestoreRepository.deleteDayWaterEntry(
        calendarDay: calendarDay ?? state.selectedDate,
        recordKey: recordKey,
      );
      unawaited(_analytics.logWaterRecordDeleted());
      unawaited(_syncRankCelebrationAfterHydrationChange());
    } catch (e, st) {
      recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'HomeCubit: deleteWaterRecord failed',
      );
      rethrow;
    }
  }

  void syncAnchoredTodayIfNeeded() {
    if (!state.anchoredToLiveToday) return;
    final today = _todayCalendar;
    if (state.selectedDate == today) return;
    selectCalendarDay(today);
  }

  void _listenDayRecords(DateTime day) {
    _recordsSub?.cancel();
    _recordsSub = _firestoreRepository
        .watchDayRecords(day)
        .listen(
          (records) {
            if (state.deferProgressUpdates) {
              emit(state.copyWith(pendingRecords: records));
              return;
            }
            final totals = _totalsFromRecords(records);
            _emitRecords(records: records, totals: totals);
          },
          onError: (Object error, StackTrace st) {
            recordCrashlyticsError(
              error,
              st,
              st,
              reason: 'HomeCubit: watchDayRecords error',
            );
            final code = (error is FirebaseException) ? error.code : 'unknown';
            emit(state.copyWith(isLoading: false, errorCode: code));
          },
        );
  }

  void _emitRecords({
    required List<WaterRecordModel> records,
    required ({int raw, int effective}) totals,
  }) {
    emit(
      state.copyWith(
        records: records,
        isLoading: false,
        totalRawMl: totals.raw,
        totalEffectiveMl: totals.effective,
      ),
    );
  }

  void deferProgressUpdates(bool defer) {
    if (state.deferProgressUpdates == defer) return;

    if (!defer && state.pendingRecords != null) {
      final records = state.pendingRecords!;
      final totals = _totalsFromRecords(records);
      emit(
        state.copyWith(
          deferProgressUpdates: false,
          clearPendingRecords: true,
          records: records,
          isLoading: false,
          totalRawMl: totals.raw,
          totalEffectiveMl: totals.effective,
        ),
      );
      return;
    }

    emit(state.copyWith(deferProgressUpdates: defer));
  }

  void clearPendingRankCelebration() {
    if (state.pendingRankCelebration == null) return;
    emit(state.copyWith(clearPendingRankCelebration: true));
  }

  Future<void> _syncRankCelebrationAfterHydrationChange({
    bool allowCelebration = false,
  }) async {
    try {
      final profile = await _firestoreRepository.getUserProfile();
      if (profile == null) return;

      final entries = await _firestoreRepository.fetchHydrationLog();
      final badges = AchievementsCalculator.calculate(
        entries: entries,
        dailyGoalMl: profile.dailyGoalMl,
      );

      final reconciled = RankCelebrationLogic.reconcileLastCelebratedRankId(
        badges: badges,
        lastCelebratedRankId: profile.lastCelebratedRankId,
      );

      if (reconciled != profile.lastCelebratedRankId) {
        if (reconciled == null) {
          await _firestoreRepository.clearLastCelebratedRankId();
        } else {
          await _firestoreRepository.updateLastCelebratedRankId(reconciled);
        }
      }

      if (!allowCelebration) return;

      final rankToCelebrate = RankCelebrationLogic.rankToCelebrate(
        badges: badges,
        lastCelebratedRankId: reconciled,
      );
      if (rankToCelebrate == null) return;

      await _firestoreRepository.updateLastCelebratedRankId(rankToCelebrate.id);
      SchedulerBinding.instance.scheduleFrameCallback((_) {
        if (isClosed) return;
        emit(state.copyWith(pendingRankCelebration: rankToCelebrate));
      });
    } catch (e, st) {
      recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'HomeCubit: rank celebration sync failed',
      );
    }
  }

  @override
  Future<void> close() async {
    _dayRolloverTimer?.cancel();
    await _recordsSub?.cancel();
    await _profileSub?.cancel();
    return super.close();
  }
}
