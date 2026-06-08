import 'package:daily_water_tracker/features/achievements/models/rank_condition.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// User-facing hydration rank (tier) with composite progress.
class BadgeModel extends Equatable {
  const BadgeModel({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.iconPath,
    required this.placeholderIcon,
    required this.tierOrder,
    required this.conditions,
    this.unlockDate,
  });

  final String id;
  final String nameKey;
  final String descriptionKey;
  final String iconPath;
  final IconData placeholderIcon;
  final int tierOrder;
  final List<RankCondition> conditions;
  final DateTime? unlockDate;

  bool get isUnlocked => conditions.every((c) => c.isComplete);

  BadgeModel copyWith({
    String? id,
    String? nameKey,
    String? descriptionKey,
    String? iconPath,
    IconData? placeholderIcon,
    int? tierOrder,
    List<RankCondition>? conditions,
    DateTime? unlockDate,
  }) {
    return BadgeModel(
      id: id ?? this.id,
      nameKey: nameKey ?? this.nameKey,
      descriptionKey: descriptionKey ?? this.descriptionKey,
      iconPath: iconPath ?? this.iconPath,
      placeholderIcon: placeholderIcon ?? this.placeholderIcon,
      tierOrder: tierOrder ?? this.tierOrder,
      conditions: conditions ?? this.conditions,
      unlockDate: unlockDate ?? this.unlockDate,
    );
  }

  @override
  List<Object?> get props => [
    id,
    nameKey,
    descriptionKey,
    iconPath,
    placeholderIcon,
    tierOrder,
    conditions,
    unlockDate,
  ];
}
