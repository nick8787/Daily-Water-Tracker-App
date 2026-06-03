import 'package:equatable/equatable.dart';
import '../models/badge_model.dart';

sealed class AchievementsState extends Equatable {
  const AchievementsState();

  @override
  List<Object?> get props => [];
}

final class AchievementsInitial extends AchievementsState {}

final class AchievementsLoading extends AchievementsState {}

final class AchievementsLoaded extends AchievementsState {
  final List<BadgeModel> badges;

  const AchievementsLoaded({required this.badges});

  @override
  List<Object?> get props => [badges];
}

final class AchievementsFailure extends AchievementsState {
  final String message;
  const AchievementsFailure(this.message);

  @override
  List<Object?> get props => [message];
}