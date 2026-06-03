import 'package:equatable/equatable.dart';

class BadgeModel extends Equatable {
  final String id;
  final String nameKey;
  final String descriptionKey;
  final String iconPath;
  final bool isUnlocked;
  final DateTime? unlockDate;

  const BadgeModel({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.iconPath,
    this.isUnlocked = false,
    this.unlockDate,
  });

  BadgeModel unlock(DateTime date) {
    return BadgeModel(
      id: id,
      nameKey: nameKey,
      descriptionKey: descriptionKey,
      iconPath: iconPath,
      isUnlocked: true,
      unlockDate: date,
    );
  }

  @override
  List<Object?> get props => [id, isUnlocked, unlockDate];
}