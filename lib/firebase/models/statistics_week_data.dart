import 'package:equatable/equatable.dart';
import 'package:daily_water_tracker/firebase/models/drink_type.dart';

/// Per–drink-type effective hydration total for the statistics window (ml, rounded).
class DrinkEffectiveMlBucket extends Equatable {
  const DrinkEffectiveMlBucket({
    required this.drinkType,
    required this.effectiveMl,
  });

  final DrinkType drinkType;
  final int effectiveMl;

  @override
  List<Object?> get props => [drinkType, effectiveMl];
}

/// One calendar day in the rolling statistics window (for charts / breakdown).
class StatisticsDayBar extends Equatable {
  const StatisticsDayBar({
    required this.date,
    required this.totalMl,
    required this.goalMl,
  });

  final DateTime date;

  /// Effective hydration total (ml), same rules as the home ring.
  final int totalMl;

  /// Daily goal (ml) at load time; applied for each day in the window.
  final int goalMl;

  bool get goalMetOrExceeded => goalMl > 0 && totalMl >= goalMl;

  @override
  List<Object?> get props => [date, totalMl, goalMl];
}

/// Per-day chart series + drink mix for the statistics screen.
class StatisticsWeekData extends Equatable {
  const StatisticsWeekData({
    required this.dailyGoalMl,
    required this.dayBars,
    required this.drinkEffectiveTotals,
  });

  /// User daily goal at query time (ml); duplicated on each [StatisticsDayBar.goalMl] for charts.
  final int dailyGoalMl;

  /// Oldest → newest (left → right on the bar chart).
  final List<StatisticsDayBar> dayBars;

  /// Effective hydration (Σ volume × coefficient) by drink type, non-zero only, highest first.
  final List<DrinkEffectiveMlBucket> drinkEffectiveTotals;

  @override
  List<Object?> get props => [dailyGoalMl, dayBars, drinkEffectiveTotals];
}
