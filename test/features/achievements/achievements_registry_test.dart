import 'package:daily_water_tracker/features/achievements/data/achievements_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AchievementsRegistry.getNextRank', () {
    test('returns fan after beginner', () {
      final next = AchievementsRegistry.getNextRank(
        AchievementsRegistry.beginnerId,
      );
      expect(next?.id, AchievementsRegistry.fanId);
    });

    test('returns null after maximum rank', () {
      final next = AchievementsRegistry.getNextRank(
        AchievementsRegistry.poseidonId,
      );
      expect(next, isNull);
    });

    test('returns null for unknown rank id', () {
      expect(AchievementsRegistry.getNextRank('unknown'), isNull);
    });
  });
}
