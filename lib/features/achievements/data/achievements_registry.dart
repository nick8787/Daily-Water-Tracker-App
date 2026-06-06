import 'package:daily_water_tracker/features/achievements/models/achievement_category.dart';
import 'package:daily_water_tracker/features/achievements/models/achievement_definition.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

/// Central catalog of all achievements (metadata only)
abstract final class AchievementsRegistry {
  static const String firstDropId = 'first_drop';
  static const String marathon3Id = 'marathon_3';
  static const String volume10lId = 'volume_10l';

  static const double marathon3MaxProgress = 3;
  static const double volume10lMaxProgressMl = 10000;

  static const List<AchievementDefinition> all = [
    AchievementDefinition(
      id: firstDropId,
      nameKey: LocaleKeys.achievements_first_drop_title,
      descriptionKey: LocaleKeys.achievements_first_drop_desc,
      iconPath: 'assets/images/badges/first_drop.svg',
      maxProgress: 1,
      category: AchievementCategory.milestone,
    ),
    AchievementDefinition(
      id: marathon3Id,
      nameKey: LocaleKeys.achievements_marathon_3_title,
      descriptionKey: LocaleKeys.achievements_marathon_3_desc,
      iconPath: 'assets/images/badges/marathon_3.svg',
      maxProgress: marathon3MaxProgress,
      category: AchievementCategory.streak,
    ),
    AchievementDefinition(
      id: volume10lId,
      nameKey: LocaleKeys.achievements_volume_10l_title,
      descriptionKey: LocaleKeys.achievements_volume_10l_desc,
      iconPath: 'assets/images/badges/volume_10l.svg',
      maxProgress: volume10lMaxProgressMl,
      category: AchievementCategory.milestone,
    ),
  ];

  static AchievementDefinition? byId(String id) {
    for (final definition in all) {
      if (definition.id == id) return definition;
    }
    return null;
  }
}
