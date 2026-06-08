import 'package:daily_water_tracker/features/achievements/models/achievement_category.dart';
import 'package:daily_water_tracker/features/achievements/models/rank_condition.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Static rank metadata — no user progress.
class AchievementDefinition extends Equatable {
  const AchievementDefinition({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.iconPath,
    required this.placeholderIcon,
    required this.tierOrder,
    required this.category,
    required this.conditionDefinitions,
  });

  final String id;
  final String nameKey;
  final String descriptionKey;
  final String iconPath;
  final IconData placeholderIcon;
  final int tierOrder;
  final AchievementCategory category;
  final List<RankConditionDefinition> conditionDefinitions;

  @override
  List<Object?> get props => [
    id,
    nameKey,
    descriptionKey,
    iconPath,
    placeholderIcon,
    tierOrder,
    category,
    conditionDefinitions,
  ];
}
