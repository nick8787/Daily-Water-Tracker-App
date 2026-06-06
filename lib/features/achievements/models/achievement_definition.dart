import 'package:equatable/equatable.dart';

import 'package:daily_water_tracker/features/achievements/models/achievement_category.dart';

/// Static achievement metadata — no user progress.
class AchievementDefinition extends Equatable {
  const AchievementDefinition({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.iconPath,
    required this.maxProgress,
    required this.category,
  });

  final String id;
  final String nameKey;
  final String descriptionKey;
  final String iconPath;
  final double maxProgress;
  final AchievementCategory category;

  @override
  List<Object?> get props => [
    id,
    nameKey,
    descriptionKey,
    iconPath,
    maxProgress,
    category,
  ];
}
