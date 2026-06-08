import 'package:daily_water_tracker/features/statistics/models/statistics_presentation.dart';
import 'package:daily_water_tracker/firebase/models/statistics_week_data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';

sealed class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object?> get props => [];
}

final class StatisticsInitial extends StatisticsState {
  const StatisticsInitial();
}

final class StatisticsLoading extends StatisticsState {
  const StatisticsLoading();
}

final class StatisticsLoaded extends StatisticsState {
  const StatisticsLoaded({
    required this.weekData,
    required this.intakeBreakdown,
    required this.weeklyInsights,
  });

  final StatisticsWeekData weekData;

  final List<IntakeBreakdownRowVm> intakeBreakdown;

  final WeeklyInsightsVm weeklyInsights;

  @override
  List<Object?> get props => [weekData, intakeBreakdown, weeklyInsights];
}

final class StatisticsFailure extends StatisticsState {
  const StatisticsFailure({required this.messageKey});

  final String messageKey;

  String localizedMessage() => messageKey.tr();

  @override
  List<Object?> get props => [messageKey];
}
