import 'package:daily_water_tracker/features/achievements/models/badge_model.dart';

/// Detects when a newly unlocked rank should trigger the ascension ceremony.
abstract final class RankCelebrationLogic {
  static BadgeModel? highestUnlockedRank(List<BadgeModel> badges) {
    BadgeModel? highest;
    for (final badge in badges) {
      if (!badge.isUnlocked) continue;
      if (highest == null || badge.tierOrder > highest.tierOrder) {
        highest = badge;
      }
    }
    return highest;
  }

  /// Returns the rank to celebrate when it differs from [lastCelebratedRankId].
  static BadgeModel? rankToCelebrate({
    required List<BadgeModel> badges,
    required String? lastCelebratedRankId,
  }) {
    final currentRank = highestUnlockedRank(badges);
    if (currentRank == null || !currentRank.isUnlocked) return null;
    if (currentRank.id == lastCelebratedRankId) return null;
    return currentRank;
  }

  /// Keeps [lastCelebratedRankId] aligned with current hydration data.
  ///
  /// Resets to `null` when no ranks are unlocked, the stored rank is locked
  /// again, or the user no longer qualifies for the celebrated tier.
  static String? reconcileLastCelebratedRankId({
    required List<BadgeModel> badges,
    required String? lastCelebratedRankId,
  }) {
    if (lastCelebratedRankId == null) return null;

    final highest = highestUnlockedRank(badges);
    if (highest == null) return null;

    BadgeModel? celebrated;
    for (final badge in badges) {
      if (badge.id == lastCelebratedRankId) {
        celebrated = badge;
        break;
      }
    }

    if (celebrated == null || !celebrated.isUnlocked) return null;
    if (celebrated.tierOrder > highest.tierOrder) return null;

    return lastCelebratedRankId;
  }
}
