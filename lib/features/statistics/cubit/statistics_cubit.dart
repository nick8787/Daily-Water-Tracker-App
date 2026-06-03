import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_water_tracker/common/utils/crashlytics.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:daily_water_tracker/features/statistics/cubit/statistics_state.dart';
import 'package:daily_water_tracker/features/statistics/models/statistics_presentation.dart';
import 'package:daily_water_tracker/firebase/models/statistics_week_data.dart';
import 'package:daily_water_tracker/data/repositories/firestore_repository.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  StatisticsCubit({required FirestoreRepository firestoreRepository})
    : _firestore = firestoreRepository,
      super(const StatisticsLoading()) {
    _subscription = _firestore.watchStatisticsWeekData().listen(
      (weekData) => emit(_loaded(weekData)),
      onError: _onStreamError,
    );
  }

  final FirestoreRepository _firestore;
  StreamSubscription<dynamic>? _subscription;

  StatisticsLoaded _loaded(StatisticsWeekData weekData) {
    return StatisticsLoaded(
      weekData: weekData,
      intakeBreakdown: buildIntakeBreakdown(weekData),
      weeklyInsights: buildWeeklyInsights(weekData),
    );
  }

  void _onStreamError(Object e, StackTrace st) {
    unawaited(
      recordCrashlyticsError(
        e,
        StackTrace.current,
        st,
        reason: 'StatisticsCubit.watchStatisticsWeekData',
      ),
    );
    emit(
      const StatisticsFailure(
        messageKey: LocaleKeys.statistics_error_load_failed,
      ),
    );
  }

  Future<void> refresh() async {
    try {
      final weekData = await _firestore.fetchStatisticsWeekData();
      emit(_loaded(weekData));
    } catch (e, st) {
      await recordCrashlyticsError(
        e,
        StackTrace.current,
        st,
        reason: 'StatisticsCubit.refresh',
      );
      emit(
        const StatisticsFailure(
          messageKey: LocaleKeys.statistics_error_load_failed,
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
