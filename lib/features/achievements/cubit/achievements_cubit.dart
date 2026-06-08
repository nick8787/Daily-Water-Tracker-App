import 'package:daily_water_tracker/common/constants/hydration_defaults.dart';
import 'package:daily_water_tracker/data/repositories/firestore_repository.dart';
import 'package:daily_water_tracker/features/achievements/data/achievements_registry.dart';
import 'package:daily_water_tracker/features/achievements/logic/achievements_calculator.dart';
import 'package:daily_water_tracker/features/achievements/logic/rank_celebration_logic.dart';
import 'package:daily_water_tracker/features/achievements/models/achievement_definition.dart';
import 'package:daily_water_tracker/features/achievements/models/badge_model.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'achievements_state.dart';

class AchievementsCubit extends Cubit<AchievementsState> {
  AchievementsCubit({
    required FirestoreRepository firestoreRepository,
  }) : _firestoreRepository = firestoreRepository,
       super(AchievementsInitial());

  final FirestoreRepository _firestoreRepository;

  /// Returns the next rank metadata after [currentRankId], or `null` at max tier.
  static AchievementDefinition? getNextRank(String currentRankId) =>
      AchievementsRegistry.getNextRank(currentRankId);

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

      await _reconcileCelebrationState(
        badges: badges,
        lastCelebratedRankId: profile?.lastCelebratedRankId,
      );

      emit(AchievementsLoaded(badges: badges));
    } catch (_) {
      emit(const AchievementsFailure(LocaleKeys.achievements_error_load_failed));
    }
  }

  Future<void> _reconcileCelebrationState({
    required List<BadgeModel> badges,
    required String? lastCelebratedRankId,
  }) async {
    final reconciled = RankCelebrationLogic.reconcileLastCelebratedRankId(
      badges: badges,
      lastCelebratedRankId: lastCelebratedRankId,
    );
    if (reconciled == lastCelebratedRankId) return;

    if (reconciled == null) {
      await _firestoreRepository.clearLastCelebratedRankId();
    } else {
      await _firestoreRepository.updateLastCelebratedRankId(reconciled);
    }
  }
}
