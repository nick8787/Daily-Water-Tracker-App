import 'package:daily_water_tracker/common/constants/hydration_defaults.dart';
import 'package:daily_water_tracker/features/achievements/data/achievements_registry.dart';
import 'package:daily_water_tracker/features/achievements/models/achievement_day_summary.dart';
import 'package:daily_water_tracker/features/achievements/models/achievement_definition.dart';
import 'package:daily_water_tracker/features/achievements/models/badge_model.dart';
import 'package:daily_water_tracker/features/achievements/models/rank_condition.dart';
import 'package:daily_water_tracker/features/achievements/models/rank_condition_type.dart';
import 'package:daily_water_tracker/firebase/models/drink_type.dart';
import 'package:daily_water_tracker/firebase/models/hydration_log_entry.dart';

/// Pure rank rules — unit-testable without Firestore or Cubit.
abstract final class AchievementsCalculator {
  static List<BadgeModel> calculate({
    required List<HydrationLogEntry> entries,
    required int dailyGoalMl,
  }) {
    final goalMl = dailyGoalMl > 0 ? dailyGoalMl : kDefaultDailyGoalMl;
    final daySummaries = _groupEntriesByDay(entries);
    final entriesAsc = _sortedByTimestampAsc(entries);
    final goalMetDays = _goalMetDaysSorted(daySummaries, goalMl);
    final totalVolumeMl = _cumulativeEffectiveMl(entriesAsc);

    return [
      for (final definition in AchievementsRegistry.all)
        _buildRank(
          definition: definition,
          entriesAsc: entriesAsc,
          goalMetDays: goalMetDays,
          totalVolumeMl: totalVolumeMl,
        ),
    ];
  }

  static Map<DateTime, AchievementDaySummary> groupEntriesByDay(
    List<HydrationLogEntry> entries,
  ) => _groupEntriesByDay(entries);

  static BadgeModel _buildRank({
    required AchievementDefinition definition,
    required List<HydrationLogEntry> entriesAsc,
    required List<DateTime> goalMetDays,
    required double totalVolumeMl,
  }) {
    final conditions = <RankCondition>[];

    for (final template in definition.conditionDefinitions) {
      conditions.add(
        _resolveCondition(
          template: template,
          entriesAsc: entriesAsc,
          goalMetDays: goalMetDays,
          totalVolumeMl: totalVolumeMl,
        ),
      );
    }

    final unlockDate = conditions.every((c) => c.isComplete)
        ? _latestDate(
            conditions
                .map((c) => c.completedAt)
                .whereType<DateTime>()
                .toList(),
          )
        : null;

    return BadgeModel(
      id: definition.id,
      nameKey: definition.nameKey,
      descriptionKey: definition.descriptionKey,
      iconPath: definition.iconPath,
      placeholderIcon: definition.placeholderIcon,
      tierOrder: definition.tierOrder,
      conditions: conditions,
      unlockDate: unlockDate,
    );
  }

  static RankCondition _resolveCondition({
    required RankConditionDefinition template,
    required List<HydrationLogEntry> entriesAsc,
    required List<DateTime> goalMetDays,
    required double totalVolumeMl,
  }) {
    return switch (template.type) {
      RankConditionType.logEntries => RankCondition(
        type: template.type,
        labelKey: template.labelKey,
        currentValue: entriesAsc.isEmpty ? 0 : 1,
        targetValue: template.targetValue,
        completedAt: entriesAsc.isEmpty
            ? null
            : entriesAsc.first.record.timestamp,
      ),
      RankConditionType.goalDays => RankCondition(
        type: template.type,
        labelKey: template.labelKey,
        currentValue: goalMetDays.length.toDouble(),
        targetValue: template.targetValue,
        completedAt: _goalDaysCompletedAt(
          goalMetDays: goalMetDays,
          targetDays: template.targetValue.toInt(),
          entriesAsc: entriesAsc,
        ),
      ),
      RankConditionType.totalVolumeMl => RankCondition(
        type: template.type,
        labelKey: template.labelKey,
        currentValue: totalVolumeMl.clamp(0, template.targetValue),
        targetValue: template.targetValue,
        completedAt: _volumeCompletedAt(
          entriesAsc: entriesAsc,
          targetMl: template.targetValue,
        ),
      ),
    };
  }

  static DateTime? _goalDaysCompletedAt({
    required List<DateTime> goalMetDays,
    required int targetDays,
    required List<HydrationLogEntry> entriesAsc,
  }) {
    if (goalMetDays.length < targetDays) return null;

    final milestoneDay = goalMetDays[targetDays - 1];
    DateTime? latestOnDay;
    for (final entry in entriesAsc) {
      if (_normalizeDay(entry.calendarDay) == milestoneDay) {
        final ts = entry.record.timestamp;
        if (latestOnDay == null || ts.isAfter(latestOnDay)) {
          latestOnDay = ts;
        }
      }
    }
    return latestOnDay ?? milestoneDay;
  }

  static DateTime? _volumeCompletedAt({
    required List<HydrationLogEntry> entriesAsc,
    required double targetMl,
  }) {
    var running = 0.0;
    for (final entry in entriesAsc) {
      running += entry.record.effectiveHydrationMl;
      if (running >= targetMl) {
        return entry.record.timestamp;
      }
    }
    return null;
  }

  static List<DateTime> _goalMetDaysSorted(
    Map<DateTime, AchievementDaySummary> daySummaries,
    int dailyGoalMl,
  ) {
    final days = daySummaries.entries
        .where((e) => e.value.goalMet(dailyGoalMl))
        .map((e) => e.key)
        .toList()
      ..sort();
    return days;
  }

  static List<HydrationLogEntry> _sortedByTimestampAsc(
    List<HydrationLogEntry> entries,
  ) {
    final copy = List<HydrationLogEntry>.from(entries)
      ..sort((a, b) => a.record.timestamp.compareTo(b.record.timestamp));
    return copy;
  }

  static Map<DateTime, AchievementDaySummary> _groupEntriesByDay(
    List<HydrationLogEntry> entries,
  ) {
    final buckets = <DateTime, _DayBucket>{};

    for (final entry in entries) {
      final day = _normalizeDay(entry.calendarDay);
      final bucket = buckets.putIfAbsent(day, _DayBucket.new);
      bucket.effectiveMl += entry.record.effectiveHydrationMl;
      bucket.drinkTypes.add(entry.record.drinkType);
      bucket.entryCount++;
    }

    return {
      for (final e in buckets.entries)
        e.key: AchievementDaySummary(
          calendarDay: e.key,
          effectiveHydrationMl: e.value.effectiveMl,
          drinkTypes: Set<DrinkType>.from(e.value.drinkTypes),
          entryCount: e.value.entryCount,
        ),
    };
  }

  static double _cumulativeEffectiveMl(List<HydrationLogEntry> entriesAsc) {
    var total = 0.0;
    for (final entry in entriesAsc) {
      total += entry.record.effectiveHydrationMl;
    }
    return total;
  }

  static DateTime _normalizeDay(DateTime day) {
    return DateTime(day.year, day.month, day.day);
  }

  static DateTime? _latestDate(List<DateTime> dates) {
    if (dates.isEmpty) return null;
    return dates.reduce((a, b) => a.isAfter(b) ? a : b);
  }
}

final class _DayBucket {
  double effectiveMl = 0;
  final Set<DrinkType> drinkTypes = {};
  int entryCount = 0;
}
