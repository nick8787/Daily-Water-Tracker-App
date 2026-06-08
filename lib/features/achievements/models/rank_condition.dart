import 'package:daily_water_tracker/features/achievements/models/rank_condition_type.dart';
import 'package:equatable/equatable.dart';

/// One measurable requirement for a hydration rank.
class RankCondition extends Equatable {
  const RankCondition({
    required this.type,
    required this.labelKey,
    required this.currentValue,
    required this.targetValue,
    this.completedAt,
  });

  final RankConditionType type;
  final String labelKey;
  final double currentValue;
  final double targetValue;
  final DateTime? completedAt;

  bool get isComplete =>
      targetValue > 0 && currentValue >= targetValue;

  double get progressFraction {
    if (targetValue <= 0) return 0;
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  RankCondition copyWith({
    RankConditionType? type,
    String? labelKey,
    double? currentValue,
    double? targetValue,
    DateTime? completedAt,
  }) {
    return RankCondition(
      type: type ?? this.type,
      labelKey: labelKey ?? this.labelKey,
      currentValue: currentValue ?? this.currentValue,
      targetValue: targetValue ?? this.targetValue,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
    type,
    labelKey,
    currentValue,
    targetValue,
    completedAt,
  ];
}

/// Static target definition attached to a rank in [AchievementsRegistry].
class RankConditionDefinition extends Equatable {
  const RankConditionDefinition({
    required this.type,
    required this.labelKey,
    required this.targetValue,
  });

  final RankConditionType type;
  final String labelKey;
  final double targetValue;

  @override
  List<Object?> get props => [type, labelKey, targetValue];
}
