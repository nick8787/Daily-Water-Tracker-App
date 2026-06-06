import 'package:equatable/equatable.dart';

import 'package:daily_water_tracker/firebase/models/drink_type.dart';

/// Aggregated hydration for one calendar day (for streak / habit rules)
class AchievementDaySummary extends Equatable {
  const AchievementDaySummary({
    required this.calendarDay,
    required this.effectiveHydrationMl,
    required this.drinkTypes,
    required this.entryCount,
  });

  final DateTime calendarDay;
  final double effectiveHydrationMl;
  final Set<DrinkType> drinkTypes;
  final int entryCount;

  bool goalMet(int dailyGoalMl) =>
      dailyGoalMl > 0 && effectiveHydrationMl >= dailyGoalMl;

  @override
  List<Object?> get props => [
    calendarDay,
    effectiveHydrationMl,
    drinkTypes,
    entryCount,
  ];
}
