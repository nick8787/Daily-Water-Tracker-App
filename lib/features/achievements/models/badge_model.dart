import 'package:equatable/equatable.dart';

/// User-facing achievement state derived from [AchievementDefinition] + progress.
class BadgeModel extends Equatable {
  const BadgeModel({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.iconPath,
    required this.currentProgress,
    required this.maxProgress,
    this.unlockDate,
  });

  final String id;
  final String nameKey;
  final String descriptionKey;
  final String iconPath;
  final double currentProgress;
  final double maxProgress;
  final DateTime? unlockDate;

  bool get isUnlocked =>
      maxProgress > 0 && currentProgress >= maxProgress;

  double get progressFraction {
    if (maxProgress <= 0) return 0;
    return (currentProgress / maxProgress).clamp(0.0, 1.0);
  }

  BadgeModel copyWith({
    String? id,
    String? nameKey,
    String? descriptionKey,
    String? iconPath,
    double? currentProgress,
    double? maxProgress,
    DateTime? unlockDate,
  }) {
    return BadgeModel(
      id: id ?? this.id,
      nameKey: nameKey ?? this.nameKey,
      descriptionKey: descriptionKey ?? this.descriptionKey,
      iconPath: iconPath ?? this.iconPath,
      currentProgress: currentProgress ?? this.currentProgress,
      maxProgress: maxProgress ?? this.maxProgress,
      unlockDate: unlockDate ?? this.unlockDate,
    );
  }

  @override
  List<Object?> get props => [
    id,
    nameKey,
    descriptionKey,
    iconPath,
    currentProgress,
    maxProgress,
    unlockDate,
  ];
}
