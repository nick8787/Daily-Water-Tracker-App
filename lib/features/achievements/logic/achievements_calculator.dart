import 'package:daily_water_tracker/common/constants/hydration_defaults.dart';
import 'package:daily_water_tracker/features/achievements/data/achievements_registry.dart';
import 'package:daily_water_tracker/features/achievements/models/achievement_day_summary.dart';
import 'package:daily_water_tracker/features/achievements/models/achievement_definition.dart';
import 'package:daily_water_tracker/features/achievements/models/badge_model.dart';
import 'package:daily_water_tracker/firebase/models/drink_type.dart';
import 'package:daily_water_tracker/firebase/models/hydration_log_entry.dart';

abstract final class AchievementsCalculator {
  static List<BadgeModel> calculate({
    required List<HydrationLogEntry> entries,
    required int dailyGoalMl,
  }) {
    final goalMl = dailyGoalMl > 0 ? dailyGoalMl : kDefaultDailyGoalMl;
    final daySummaries = _groupEntriesByDay(entries);
    final sortedEntries = _sortedByTimestampAsc(entries);

    return [
      for (final definition in AchievementsRegistry.all)
        _buildBadge(
          definition: definition,
          entries: sortedEntries,
          daySummaries: daySummaries,
          dailyGoalMl: goalMl,
        ),
    ];
  }

  static Map<DateTime, AchievementDaySummary> groupEntriesByDay(
    List<HydrationLogEntry> entries,
  ) => _groupEntriesByDay(entries);

  static BadgeModel _buildBadge({
    required AchievementDefinition definition,
    required List<HydrationLogEntry> entries,
    required Map<DateTime, AchievementDaySummary> daySummaries,
    required int dailyGoalMl,
  }) {
    return switch (definition.id) {
      AchievementsRegistry.firstDropId => _firstDrop(
        definition,
        entries,
      ),
      AchievementsRegistry.marathon3Id => _marathon3(
        definition,
        daySummaries,
        dailyGoalMl,
      ),
      AchievementsRegistry.volume10lId => _volume10l(
        definition,
        entries,
      ),
      _ => _emptyBadge(definition),
    };
  }

  static BadgeModel _firstDrop(
    AchievementDefinition definition,
    List<HydrationLogEntry> entriesAsc,
  ) {
    if (entriesAsc.isEmpty) {
      return _badgeFrom(definition, currentProgress: 0);
    }

    return _badgeFrom(
      definition,
      currentProgress: 1,
      unlockDate: entriesAsc.first.record.timestamp,
    );
  }

  static BadgeModel _marathon3(
    AchievementDefinition definition,
    Map<DateTime, AchievementDaySummary> daySummaries,
    int dailyGoalMl,
  ) {
    final streak = _maxConsecutiveGoalDays(
      daySummaries: daySummaries,
      dailyGoalMl: dailyGoalMl,
    );

    final unlockDate = streak.current >= definition.maxProgress
        ? streak.unlockDay
        : null;

    return _badgeFrom(
      definition,
      currentProgress: streak.current.toDouble(),
      unlockDate: unlockDate,
    );
  }

  static BadgeModel _volume10l(
    AchievementDefinition definition,
    List<HydrationLogEntry> entriesAsc,
  ) {
    final result = _cumulativeEffectiveMl(entriesAsc);
    final progress = result.totalMl.clamp(0.0, definition.maxProgress);

    final unlockDate = result.totalMl >= definition.maxProgress
        ? result.thresholdReachedAt
        : null;

    return _badgeFrom(
      definition,
      currentProgress: progress,
      unlockDate: unlockDate,
    );
  }

  static BadgeModel _emptyBadge(AchievementDefinition definition) {
    return _badgeFrom(definition, currentProgress: 0);
  }

  static BadgeModel _badgeFrom(
    AchievementDefinition definition, {
    required double currentProgress,
    DateTime? unlockDate,
  }) {
    return BadgeModel(
      id: definition.id,
      nameKey: definition.nameKey,
      descriptionKey: definition.descriptionKey,
      iconPath: definition.iconPath,
      currentProgress: currentProgress,
      maxProgress: definition.maxProgress,
      unlockDate: unlockDate,
    );
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

  static DateTime _normalizeDay(DateTime day) {
    return DateTime(day.year, day.month, day.day);
  }

  /// Walks every calendar day from first log → last log; gaps break the streak.
  static _GoalStreakResult _maxConsecutiveGoalDays({
    required Map<DateTime, AchievementDaySummary> daySummaries,
    required int dailyGoalMl,
  }) {
    if (daySummaries.isEmpty || dailyGoalMl <= 0) {
      return const _GoalStreakResult(current: 0);
    }

    final sortedDays = daySummaries.keys.toList()..sort();
    final firstDay = sortedDays.first;
    final lastDay = sortedDays.last;

    var maxStreak = 0;
    var running = 0;
    DateTime? maxStreakEndDay;
    DateTime? runningEndDay;

    for (
      var day = firstDay;
      !day.isAfter(lastDay);
      day = day.add(const Duration(days: 1))
    ) {
      final normalized = _normalizeDay(day);
      final summary = daySummaries[normalized];
      final metGoal = summary?.goalMet(dailyGoalMl) ?? false;

      if (metGoal) {
        running++;
        runningEndDay = normalized;
        if (running > maxStreak) {
          maxStreak = running;
          maxStreakEndDay = runningEndDay;
        }
      } else {
        running = 0;
        runningEndDay = null;
      }
    }

    return _GoalStreakResult(
      current: maxStreak,
      unlockDay: maxStreakEndDay,
    );
  }

  static _VolumeProgressResult _cumulativeEffectiveMl(
    List<HydrationLogEntry> entriesAsc,
  ) {
    var total = 0.0;
    DateTime? thresholdReachedAt;

    for (final entry in entriesAsc) {
      total += entry.record.effectiveHydrationMl;
      if (thresholdReachedAt == null &&
          total >= AchievementsRegistry.volume10lMaxProgressMl) {
        thresholdReachedAt = entry.record.timestamp;
      }
    }

    return _VolumeProgressResult(
      totalMl: total,
      thresholdReachedAt: thresholdReachedAt,
    );
  }
}

final class _DayBucket {
  double effectiveMl = 0;
  final Set<DrinkType> drinkTypes = {};
  int entryCount = 0;
}

final class _GoalStreakResult {
  const _GoalStreakResult({
    required this.current,
    this.unlockDay,
  });

  final int current;
  final DateTime? unlockDay;
}

final class _VolumeProgressResult {
  const _VolumeProgressResult({
    required this.totalMl,
    this.thresholdReachedAt,
  });

  final double totalMl;
  final DateTime? thresholdReachedAt;
}
