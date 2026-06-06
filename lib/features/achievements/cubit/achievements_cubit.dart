import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:daily_water_tracker/common/constants/hydration_defaults.dart';
import 'package:daily_water_tracker/data/repositories/firestore_repository.dart';
import 'package:daily_water_tracker/features/achievements/logic/achievements_calculator.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

import 'achievements_state.dart';

class AchievementsCubit extends Cubit<AchievementsState> {
  AchievementsCubit({
    required FirestoreRepository firestoreRepository,
  }) : _firestoreRepository = firestoreRepository,
       super(AchievementsInitial());

  final FirestoreRepository _firestoreRepository;

  Future<void> loadAchievements() async {
    emit(AchievementsLoading());

    try {
      final entries = await _firestoreRepository.fetchHydrationLog();
      final profile = await _firestoreRepository.getUserProfile();
      final dailyGoalMl = profile?.dailyGoalMl ?? kDefaultDailyGoalMl;

      final badges = AchievementsCalculator.calculate(
        entries: entries,
        dailyGoalMl: dailyGoalMl,
      );

      emit(AchievementsLoaded(badges: badges));
    } catch (_) {
      emit(const AchievementsFailure(LocaleKeys.achievements_error_load_failed));
    }
  }
}
