import 'package:daily_water_tracker/features/achievements/data/achievements_registry.dart';
import 'package:daily_water_tracker/features/achievements/logic/achievements_calculator.dart';
import 'package:daily_water_tracker/features/achievements/models/rank_condition_type.dart';
import 'package:daily_water_tracker/firebase/models/drink_type.dart';
import 'package:daily_water_tracker/firebase/models/hydration_log_entry.dart';
import 'package:daily_water_tracker/firebase/models/water_record_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AchievementsCalculator', () {
    HydrationLogEntry entry({
      required DateTime day,
      required DateTime timestamp,
      int volumeMl = 500,
      DrinkType type = DrinkType.water,
    }) {
      return HydrationLogEntry(
        calendarDay: day,
        record: WaterRecordModel(
          recordKey: 'k',
          timestamp: timestamp,
          volumeMl: volumeMl,
          drinkType: type,
          coefficient: type.defaultCoefficient,
        ),
      );
    }

    test('beginner unlocks on any entry with earliest timestamp', () {
      final d1 = DateTime(2026, 6);
      final d2 = DateTime(2026, 6, 2);
      final badges = AchievementsCalculator.calculate(
        entries: [
          entry(day: d2, timestamp: DateTime(2026, 6, 2, 12)),
          entry(day: d1, timestamp: DateTime(2026, 6, 1, 9)),
        ],
        dailyGoalMl: 3000,
      );

      final beginner = badges.firstWhere(
        (b) => b.id == AchievementsRegistry.beginnerId,
      );
      expect(beginner.isUnlocked, isTrue);
      expect(beginner.conditions.single.currentValue, 1);
      expect(beginner.unlockDate, DateTime(2026, 6, 1, 9));
    });

    test('fan counts goal days without requiring consecutive streak', () {
      const goal = 1000;
      final badges = AchievementsCalculator.calculate(
        entries: [
          entry(
            day: DateTime(2026, 6),
            timestamp: DateTime(2026, 6, 1, 10),
            volumeMl: 1000,
          ),
          entry(
            day: DateTime(2026, 6, 2),
            timestamp: DateTime(2026, 6, 2, 10),
            volumeMl: 1000,
          ),
          entry(
            day: DateTime(2026, 6, 3),
            timestamp: DateTime(2026, 6, 3, 10),
            volumeMl: 1000,
          ),
          entry(
            day: DateTime(2026, 6, 5),
            timestamp: DateTime(2026, 6, 5, 10),
            volumeMl: 1000,
          ),
        ],
        dailyGoalMl: goal,
      );

      final fan = badges.firstWhere((b) => b.id == AchievementsRegistry.fanId);
      final goalDays = fan.conditions.singleWhere(
        (c) => c.type == RankConditionType.goalDays,
      );
      expect(goalDays.currentValue, 4);
      expect(fan.isUnlocked, isFalse);
    });

    test('fan unlocks after 7 non-consecutive goal days', () {
      const goal = 1000;
      final entries = <HydrationLogEntry>[
        for (var i = 0; i < 7; i++)
          entry(
            day: DateTime(2026, 6, 1 + i * 2),
            timestamp: DateTime(2026, 6, 1 + i * 2, 10),
            volumeMl: 1000,
          ),
      ];

      final badges = AchievementsCalculator.calculate(
        entries: entries,
        dailyGoalMl: goal,
      );

      final fan = badges.firstWhere((b) => b.id == AchievementsRegistry.fanId);
      expect(fan.isUnlocked, isTrue);
      expect(fan.unlockDate, DateTime(2026, 6, 13, 10));
    });

    test('master requires both goal days and total volume', () {
      final badgesPartialDays = AchievementsCalculator.calculate(
        entries: [
          for (var i = 0; i < 30; i++)
            entry(
              day: DateTime(2026, 1, 1 + i),
              timestamp: DateTime(2026, 1, 1 + i, 8),
              volumeMl: 100,
            ),
        ],
        dailyGoalMl: 1000,
      );

      final masterPartial = badgesPartialDays.firstWhere(
        (b) => b.id == AchievementsRegistry.masterId,
      );
      expect(masterPartial.isUnlocked, isFalse);

      final badges = AchievementsCalculator.calculate(
        entries: [
          entry(
            day: DateTime(2026, 6),
            timestamp: DateTime(2026, 6, 1, 8),
            volumeMl: 50000,
          ),
        ],
        dailyGoalMl: 1000,
      );

      final master = badges.firstWhere(
        (b) => b.id == AchievementsRegistry.masterId,
      );
      expect(master.isUnlocked, isFalse);

      final volume = master.conditions.singleWhere(
        (c) => c.type == RankConditionType.totalVolumeMl,
      );
      expect(volume.isComplete, isTrue);
    });

    test('master unlocks when both conditions are met', () {
      final entries = <HydrationLogEntry>[
        for (var i = 0; i < 30; i++)
          entry(
            day: DateTime(2026, 1, 1 + i),
            timestamp: DateTime(2026, 1, 1 + i, 8),
            volumeMl: 2000,
          ),
      ];

      final badges = AchievementsCalculator.calculate(
        entries: entries,
        dailyGoalMl: 1000,
      );

      final master = badges.firstWhere(
        (b) => b.id == AchievementsRegistry.masterId,
      );
      expect(master.isUnlocked, isTrue);
    });

    test('returns all registry ranks in stable order', () {
      final badges = AchievementsCalculator.calculate(
        entries: const [],
        dailyGoalMl: 3000,
      );

      expect(badges.length, AchievementsRegistry.all.length);
      expect(
        badges.map((b) => b.id).toList(),
        AchievementsRegistry.all.map((d) => d.id).toList(),
      );
    });
  });
}
