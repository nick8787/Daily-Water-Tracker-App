import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_water_tracker/common/widgets/app_bottom_nav_bar.dart';
import 'package:daily_water_tracker/common/widgets/app_loader.dart';
import 'package:daily_water_tracker/common/widgets/app_screen_title.dart';
import 'package:daily_water_tracker/features/statistics/cubit/statistics_cubit.dart';
import 'package:daily_water_tracker/features/statistics/cubit/statistics_state.dart';
import 'package:daily_water_tracker/features/statistics/widgets/statistics_intake_breakdown_card.dart';
import 'package:daily_water_tracker/features/statistics/widgets/statistics_weekly_activity_card.dart';
import 'package:daily_water_tracker/features/statistics/widgets/statistics_weekly_insights_card.dart';
import 'package:daily_water_tracker/features/theme/theme_info.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key, this.embedInMainShell = false});

  final bool embedInMainShell;

  @override
  Widget build(BuildContext context) {
    return _StatisticsBody(embedInMainShell: embedInMainShell);
  }
}

class _StatisticsBody extends StatelessWidget {
  const _StatisticsBody({required this.embedInMainShell});

  final bool embedInMainShell;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StatisticsCubit, StatisticsState>(
      listenWhen: (prev, next) =>
          next is StatisticsLoading ||
          next is StatisticsLoaded ||
          next is StatisticsFailure,
      listener: (context, state) {
        if (state is StatisticsLoading) {
          AppLoader.show(context, message: LocaleKeys.loader_loading_statistics.tr());
        } else if (AppLoader.isShowing) {
          AppLoader.hide();
        }
      },
      builder: (context, state) {
        final bottomPad = embedInMainShell
            ? AppBottomNavBar.reservedHeight(context) + 12
            : MediaQuery.paddingOf(context).bottom + 20;

        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 2, 20, 10),
                          child: SizedBox(
                            height: 44,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AppScreenTitle.localized(
                                  localeKey: LocaleKeys.statistics_title,
                                  centered: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return RefreshIndicator(
                                color: brandBlue,
                                onRefresh: () =>
                                    context.read<StatisticsCubit>().refresh(),
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics(),
                                  ),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: constraints.maxHeight,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(
                                        20,
                                        0,
                                        20,
                                        bottomPad,
                                      ),
                                      child: _StatisticsContent(state: state),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatisticsContent extends StatelessWidget {
  const _StatisticsContent({required this.state});

  final StatisticsState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (state is StatisticsFailure) {
      final msg = (state as StatisticsFailure).localizedMessage();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            msg,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.read<StatisticsCubit>().refresh(),
            child: Text(LocaleKeys.common_retry.tr()),
          ),
        ],
      );
    }

    if (state is StatisticsLoaded) {
      final loaded = state as StatisticsLoaded;
      final s = loaded.weekData;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StatisticsWeeklyActivityCard(weekData: s),
          const SizedBox(height: 14),
          StatisticsIntakeBreakdownCard(rows: loaded.intakeBreakdown),
          const SizedBox(height: 12),
          StatisticsWeeklyInsightsCard(insights: loaded.weeklyInsights),
        ],
      );
    }

    return const SizedBox(height: 200);
  }
}
