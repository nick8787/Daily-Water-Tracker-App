import 'package:daily_water_tracker/features/achievements/data/achievements_registry.dart';
import 'package:daily_water_tracker/features/achievements/logic/achievements_calculator.dart';
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

    test('first_drop unlocks on any entry with earliest timestamp', () {
      final d1 = DateTime(2026, 6, 1);
      final d2 = DateTime(2026, 6, 2);
      final badges = AchievementsCalculator.calculate(
        entries: [
          entry(day: d2, timestamp: DateTime(2026, 6, 2, 12)),
          entry(day: d1, timestamp: DateTime(2026, 6, 1, 9)),
        ],
        dailyGoalMl: 3000,
      );

      final first = badges.firstWhere(
        (b) => b.id == AchievementsRegistry.firstDropId,
      );
      expect(first.isUnlocked, isTrue);
      expect(first.currentProgress, 1);
      expect(first.unlockDate, DateTime(2026, 6, 1, 9));
    });

    test('marathon_3 counts max consecutive goal days with gaps breaking streak', () {
      final goal = 1000;
      final badges = AchievementsCalculator.calculate(
        entries: [
          entry(
            day: DateTime(2026, 6, 1),
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
          // Day 4 — gap breaks the 3-day streak
          entry(
            day: DateTime(2026, 6, 5),
            timestamp: DateTime(2026, 6, 5, 10),
            volumeMl: 1000,
          ),
        ],
        dailyGoalMl: goal,
      );

      final marathon = badges.firstWhere(
        (b) => b.id == AchievementsRegistry.marathon3Id,
      );
      expect(marathon.currentProgress, 3);
      expect(marathon.isUnlocked, isTrue);
      expect(marathon.unlockDate, DateTime(2026, 6, 3));
    });

    test('volume_10l sums effective hydration toward 10000 ml', () {
      final badges = AchievementsCalculator.calculate(
        entries: [
          entry(
            day: DateTime(2026, 6, 1),
            timestamp: DateTime(2026, 6, 1, 8),
            volumeMl: 6000,
          ),
          entry(
            day: DateTime(2026, 6, 2),
            timestamp: DateTime(2026, 6, 2, 8),
            volumeMl: 5000,
          ),
        ],
        dailyGoalMl: 3000,
      );

      final volume = badges.firstWhere(
        (b) => b.id == AchievementsRegistry.volume10lId,
      );
      expect(volume.currentProgress, 10000);
      expect(volume.isUnlocked, isTrue);
      expect(volume.unlockDate, DateTime(2026, 6, 2, 8));
    });

    test('returns all registry achievements in stable order', () {
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
