import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_water_tracker/data/repositories/firestore_repository.dart';
import '../../../firebase/models/hydration_log_entry.dart';
import '../../../generated/locale_keys.g.dart';
import '../models/badge_model.dart';
import 'achievements_state.dart';

class AchievementsCubit extends Cubit<AchievementsState> {
  final FirestoreRepository _firestoreRepository;

  AchievementsCubit({
    required FirestoreRepository firestoreRepository,
  })  : _firestoreRepository = firestoreRepository,
        super(AchievementsInitial());

  Future<void> loadAchievements() async {
    emit(AchievementsLoading());

    try {
      final history = await _firestoreRepository.fetchHydrationLog();

      final badges = _calculateBadges(history);

      emit(AchievementsLoaded(badges: badges));
    } catch (e) {
      emit(const AchievementsFailure('Failed to load achievements'));
    }
  }

  List<BadgeModel> _calculateBadges(List<HydrationLogEntry> history) {

    // The icon is visible if there is at least one entry in the history
    final bool hasAnyDrink = history.isNotEmpty;

    final bool isMarathoner = history.length >= 50;

    return [
      BadgeModel(
        id: 'first_drop',
        nameKey: LocaleKeys.achievements_first_drop_title,
        descriptionKey: LocaleKeys.achievements_first_drop_desc,
        iconPath: 'assets/images/badges/first_drop.svg',
        isUnlocked: hasAnyDrink,
        unlockDate: hasAnyDrink ? history.last.record.timestamp : null,
      ),
      BadgeModel(
        id: 'marathon',
        nameKey: LocaleKeys.achievements_marathon_title,
        descriptionKey: LocaleKeys.achievements_marathon_desc,
        iconPath: 'assets/images/badges/marathon.svg',
        isUnlocked: isMarathoner,
      ),
    ];
  }
}