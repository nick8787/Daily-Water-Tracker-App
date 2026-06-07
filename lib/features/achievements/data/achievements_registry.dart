import 'package:flutter/material.dart';

import 'package:daily_water_tracker/features/achievements/models/achievement_category.dart';
import 'package:daily_water_tracker/features/achievements/models/achievement_definition.dart';
import 'package:daily_water_tracker/features/achievements/models/rank_condition.dart';
import 'package:daily_water_tracker/features/achievements/models/rank_condition_type.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

/// Central catalog of hydration evolution ranks (metadata only).
abstract final class AchievementsRegistry {
  static const String beginnerId = 'rank_beginner';
  static const String fanId = 'rank_fan';
  static const String masterId = 'rank_master';
  static const String oceanLordId = 'rank_ocean_lord';
  static const String poseidonId = 'rank_poseidon';

  static const List<AchievementDefinition> all = [
    AchievementDefinition(
      id: beginnerId,
      nameKey: LocaleKeys.achievements_ranks_beginner_title,
      descriptionKey: LocaleKeys.achievements_ranks_beginner_desc,
      iconPath: 'assets/images/ranks/beginner.svg',
      placeholderIcon: Icons.water_drop_outlined,
      tierOrder: 0,
      category: AchievementCategory.milestone,
      conditionDefinitions: [
        RankConditionDefinition(
          type: RankConditionType.logEntries,
          labelKey: LocaleKeys.achievements_conditions_first_log,
          targetValue: 1,
        ),
      ],
    ),
    AchievementDefinition(
      id: fanId,
      nameKey: LocaleKeys.achievements_ranks_fan_title,
      descriptionKey: LocaleKeys.achievements_ranks_fan_desc,
      iconPath: 'assets/images/ranks/fan.svg',
      placeholderIcon: Icons.local_drink_outlined,
      tierOrder: 1,
      category: AchievementCategory.streak,
      conditionDefinitions: [
        RankConditionDefinition(
          type: RankConditionType.goalDays,
          labelKey: LocaleKeys.achievements_conditions_goal_days,
          targetValue: 7,
        ),
      ],
    ),
    AchievementDefinition(
      id: masterId,
      nameKey: LocaleKeys.achievements_ranks_master_title,
      descriptionKey: LocaleKeys.achievements_ranks_master_desc,
      iconPath: 'assets/images/ranks/master.svg',
      placeholderIcon: Icons.water_outlined,
      tierOrder: 2,
      category: AchievementCategory.milestone,
      conditionDefinitions: [
        RankConditionDefinition(
          type: RankConditionType.goalDays,
          labelKey: LocaleKeys.achievements_conditions_goal_days,
          targetValue: 30,
        ),
        RankConditionDefinition(
          type: RankConditionType.totalVolumeMl,
          labelKey: LocaleKeys.achievements_conditions_total_volume,
          targetValue: 50000,
        ),
      ],
    ),
    AchievementDefinition(
      id: oceanLordId,
      nameKey: LocaleKeys.achievements_ranks_ocean_lord_title,
      descriptionKey: LocaleKeys.achievements_ranks_ocean_lord_desc,
      iconPath: 'assets/images/ranks/ocean_lord.svg',
      placeholderIcon: Icons.waves_outlined,
      tierOrder: 3,
      category: AchievementCategory.milestone,
      conditionDefinitions: [
        RankConditionDefinition(
          type: RankConditionType.goalDays,
          labelKey: LocaleKeys.achievements_conditions_goal_days,
          targetValue: 100,
        ),
        RankConditionDefinition(
          type: RankConditionType.totalVolumeMl,
          labelKey: LocaleKeys.achievements_conditions_total_volume,
          targetValue: 200000,
        ),
      ],
    ),
    AchievementDefinition(
      id: poseidonId,
      nameKey: LocaleKeys.achievements_ranks_poseidon_title,
      descriptionKey: LocaleKeys.achievements_ranks_poseidon_desc,
      iconPath: 'assets/images/ranks/poseidon.svg',
      placeholderIcon: Icons.workspace_premium_outlined,
      tierOrder: 4,
      category: AchievementCategory.milestone,
      conditionDefinitions: [
        RankConditionDefinition(
          type: RankConditionType.goalDays,
          labelKey: LocaleKeys.achievements_conditions_goal_days,
          targetValue: 365,
        ),
        RankConditionDefinition(
          type: RankConditionType.totalVolumeMl,
          labelKey: LocaleKeys.achievements_conditions_total_volume,
          targetValue: 700000,
        ),
      ],
    ),
  ];

  static AchievementDefinition? byId(String id) {
    for (final definition in all) {
      if (definition.id == id) return definition;
    }
    return null;
  }
}
