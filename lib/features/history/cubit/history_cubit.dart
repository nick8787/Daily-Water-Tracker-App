import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:daily_water_tracker/common/utils/crashlytics.dart';
import 'package:daily_water_tracker/data/repositories/firestore_repository.dart';
import 'package:daily_water_tracker/features/history/cubit/history_state.dart';
import 'package:daily_water_tracker/firebase/models/hydration_log_entry.dart';
import 'package:daily_water_tracker/firebase/models/user_model.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit({required FirestoreRepository firestoreRepository})
      : _firestore = firestoreRepository,
        super(const HistoryState()) {
    _logSub = _firestore.watchHydrationLog().listen(
          _onLog,
          onError: _onLogError,
        );
    _profileSub = _firestore.watchUserProfile().listen(
          _onProfile,
          onError: _onProfileError,
        );
  }

  final FirestoreRepository _firestore;

  StreamSubscription<List<HydrationLogEntry>>? _logSub;
  StreamSubscription<UserModel?>? _profileSub;

  void _onLog(List<HydrationLogEntry> list) {
    emit(
      state.copyWith(
        entries: list,
        hasLogSnapshot: true,
        status: HistoryStatus.ready,
        clearError: true,
      ),
    );
  }

  void _onProfile(UserModel? profile) {
    if (profile == null) return;
    emit(state.copyWith(profile: profile));
  }

  void _onLogError(Object e, StackTrace st) {
    unawaited(
      recordCrashlyticsError(
        e,
        StackTrace.current,
        st,
        reason: 'HistoryCubit.watchHydrationLog',
      ),
    );
    emit(
      state.copyWith(
        status: HistoryStatus.failed,
        errorMessageKey: LocaleKeys.history_error_load_failed,
      ),
    );
  }

  void _onProfileError(Object e, StackTrace st) {
    unawaited(
      recordCrashlyticsError(
        e,
        StackTrace.current,
        st,
        reason: 'HistoryCubit.watchUserProfile',
      ),
    );
  }

  @override
  Future<void> close() async {
    await _logSub?.cancel();
    await _profileSub?.cancel();
    return super.close();
  }
}
