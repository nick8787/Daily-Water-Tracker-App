import 'package:daily_water_tracker/features/achievements/data/achievements_registry.dart';
import 'package:daily_water_tracker/features/achievements/logic/rank_celebration_logic.dart';
import 'package:daily_water_tracker/features/achievements/models/badge_model.dart';
import 'package:daily_water_tracker/features/achievements/models/rank_condition.dart';
import 'package:daily_water_tracker/features/achievements/models/rank_condition_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RankCelebrationLogic', () {
    BadgeModel rank({
      required String id,
      required int tierOrder,
      required bool unlocked,
    }) {
      return BadgeModel(
        id: id,
        nameKey: 'name',
        descriptionKey: 'desc',
        iconPath: 'assets/test.svg',
        placeholderIcon: Icons.water_drop_outlined,
        tierOrder: tierOrder,
        conditions: [
          RankCondition(
            type: RankConditionType.logEntries,
            labelKey: 'label',
            currentValue: unlocked ? 1 : 0,
            targetValue: 1,
          ),
        ],
        unlockDate: unlocked ? DateTime(2026, 6, 1) : null,
      );
    }

    test('returns highest unlocked rank by tier order', () {
      final badges = [
        rank(id: AchievementsRegistry.beginnerId, tierOrder: 0, unlocked: true),
        rank(id: AchievementsRegistry.fanId, tierOrder: 1, unlocked: true),
        rank(id: AchievementsRegistry.masterId, tierOrder: 2, unlocked: false),
      ];

      final highest = RankCelebrationLogic.highestUnlockedRank(badges);
      expect(highest?.id, AchievementsRegistry.fanId);
    });

    test('rankToCelebrate triggers when current rank differs from last celebrated', () {
      final badges = [
        rank(id: AchievementsRegistry.beginnerId, tierOrder: 0, unlocked: true),
      ];

      final celebrate = RankCelebrationLogic.rankToCelebrate(
        badges: badges,
        lastCelebratedRankId: null,
      );

      expect(celebrate?.id, AchievementsRegistry.beginnerId);
    });

    test('rankToCelebrate skips when rank already celebrated', () {
      final badges = [
        rank(id: AchievementsRegistry.beginnerId, tierOrder: 0, unlocked: true),
      ];

      final celebrate = RankCelebrationLogic.rankToCelebrate(
        badges: badges,
        lastCelebratedRankId: AchievementsRegistry.beginnerId,
      );

      expect(celebrate, isNull);
    });

    test('rankToCelebrate returns new highest rank after tier up', () {
      final badges = [
        rank(id: AchievementsRegistry.beginnerId, tierOrder: 0, unlocked: true),
        rank(id: AchievementsRegistry.fanId, tierOrder: 1, unlocked: true),
      ];

      final celebrate = RankCelebrationLogic.rankToCelebrate(
        badges: badges,
        lastCelebratedRankId: AchievementsRegistry.beginnerId,
      );

      expect(celebrate?.id, AchievementsRegistry.fanId);
    });

    test('reconcileLastCelebratedRankId resets when no ranks are unlocked', () {
      final badges = [
        rank(id: AchievementsRegistry.beginnerId, tierOrder: 0, unlocked: false),
      ];

      final reconciled = RankCelebrationLogic.reconcileLastCelebratedRankId(
        badges: badges,
        lastCelebratedRankId: AchievementsRegistry.beginnerId,
      );

      expect(reconciled, isNull);
    });

    test('reconcileLastCelebratedRankId resets when celebrated rank is locked again', () {
      final badges = [
        rank(id: AchievementsRegistry.beginnerId, tierOrder: 0, unlocked: true),
        rank(id: AchievementsRegistry.fanId, tierOrder: 1, unlocked: false),
      ];

      final reconciled = RankCelebrationLogic.reconcileLastCelebratedRankId(
        badges: badges,
        lastCelebratedRankId: AchievementsRegistry.fanId,
      );

      expect(reconciled, isNull);
    });

    test('reconcileLastCelebratedRankId keeps valid celebrated rank', () {
      final badges = [
        rank(id: AchievementsRegistry.beginnerId, tierOrder: 0, unlocked: true),
      ];

      final reconciled = RankCelebrationLogic.reconcileLastCelebratedRankId(
        badges: badges,
        lastCelebratedRankId: AchievementsRegistry.beginnerId,
      );

      expect(reconciled, AchievementsRegistry.beginnerId);
    });

    test('rankToCelebrate triggers again after history reset reconciliation', () {
      final clearedBadges = [
        rank(id: AchievementsRegistry.beginnerId, tierOrder: 0, unlocked: false),
      ];

      final reconciled = RankCelebrationLogic.reconcileLastCelebratedRankId(
        badges: clearedBadges,
        lastCelebratedRankId: AchievementsRegistry.beginnerId,
      );
      expect(reconciled, isNull);

      final afterFirstLog = [
        rank(id: AchievementsRegistry.beginnerId, tierOrder: 0, unlocked: true),
      ];
      final celebrate = RankCelebrationLogic.rankToCelebrate(
        badges: afterFirstLog,
        lastCelebratedRankId: reconciled,
      );

      expect(celebrate?.id, AchievementsRegistry.beginnerId);
    });
  });
}
