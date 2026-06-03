import 'package:equatable/equatable.dart';
import 'package:daily_water_tracker/firebase/models/drink_type.dart';
import 'package:daily_water_tracker/firebase/models/statistics_week_data.dart';

final class IntakeBreakdownRowVm extends Equatable {
  const IntakeBreakdownRowVm({
    required this.drinkType,
    required this.percent,
    required this.share01,
  });

  final DrinkType drinkType;
  final int percent;

  final double share01;

  @override
  List<Object?> get props => [drinkType, percent, share01];
}

final class WeeklyInsightsVm extends Equatable {
  const WeeklyInsightsVm({
    required this.bestDayDate,
    required this.streakDays,
    required this.hasDailyGoal,
  });

  /// Calendar day with the highest intake in the window; `null` if none logged.
  final DateTime? bestDayDate;

  final int streakDays;

  final bool hasDailyGoal;

  @override
  List<Object?> get props => [bestDayDate, streakDays, hasDailyGoal];
}

List<IntakeBreakdownRowVm> buildIntakeBreakdown(StatisticsWeekData weekData) {
  final buckets = weekData.drinkEffectiveTotals;
  final total = buckets.fold<int>(0, (s, b) => s + b.effectiveMl);
  if (total <= 0) return const <IntakeBreakdownRowVm>[];

  var assigned = 0;
  final rows = <IntakeBreakdownRowVm>[];
  for (var i = 0; i < buckets.length; i++) {
    final b = buckets[i];
    final isLast = i == buckets.length - 1;
    final raw = (b.effectiveMl * 100) / total;
    final pct = isLast
        ? (100 - assigned).clamp(0, 100)
        : raw.floor().clamp(0, 100);
    if (!isLast) assigned += pct;
    rows.add(
      IntakeBreakdownRowVm(
        drinkType: b.drinkType,
        percent: pct,
        share01: (b.effectiveMl / total).clamp(0.0, 1.0),
      ),
    );
  }
  return rows;
}

WeeklyInsightsVm buildWeeklyInsights(StatisticsWeekData weekData) {
  final bars = weekData.dayBars;
  final goalMl = weekData.dailyGoalMl;
  final hasGoal = goalMl > 0;

  final bestDay = _bestDayDate(bars);
  final streak = hasGoal ? _goalStreakFromToday(bars) : 0;

  return WeeklyInsightsVm(
    bestDayDate: bestDay,
    streakDays: streak,
    hasDailyGoal: hasGoal,
  );
}

DateTime? _bestDayDate(List<StatisticsDayBar> bars) {
  if (bars.isEmpty) return null;
  var maxMl = 0;
  for (final b in bars) {
    if (b.totalMl > maxMl) maxMl = b.totalMl;
  }
  if (maxMl <= 0) return null;

  StatisticsDayBar? pick;
  for (var i = bars.length - 1; i >= 0; i--) {
    if (bars[i].totalMl == maxMl) {
      pick = bars[i];
      break;
    }
  }
  return pick?.date;
}

int _goalStreakFromToday(List<StatisticsDayBar> bars) {
  if (bars.isEmpty) return 0;
  var streak = 0;
  for (var i = bars.length - 1; i >= 0; i--) {
    if (bars[i].goalMetOrExceeded) {
      streak++;
    } else {
      break;
    }
  }
  return streak;
}
