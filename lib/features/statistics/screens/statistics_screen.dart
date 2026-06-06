import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_water_tracker/common/widgets/main_shell_tab_body.dart';
import 'package:daily_water_tracker/common/widgets/app_loader.dart';
import 'package:daily_water_tracker/common/widgets/app_screen_title.dart';
import 'package:daily_water_tracker/features/statistics/cubit/statistics_cubit.dart';
import 'package:daily_water_tracker/features/statistics/cubit/statistics_state.dart';
import 'package:daily_water_tracker/features/statistics/widgets/statistics_intake_breakdown_card.dart';
import 'package:daily_water_tracker/features/statistics/widgets/statistics_weekly_activity_card.dart';
import 'package:daily_water_tracker/features/statistics/widgets/statistics_weekly_insights_card.dart';

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
        final bottomClearance = embedInMainShell
            ? MainShellTabBody.resolveBottomClearance(context)
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
                          child: MainShellTabBody(
                            bottomClearance: bottomClearance,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: _StatisticsContent(state: state),
                            ),
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

  static const double _cardGap = 13;

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
      final rowCount = loaded.intakeBreakdown.length;
      final breakdownMode =
          StatisticsIntakeBreakdownCard.layoutModeFor(rowCount);

      final breakdownCard = StatisticsIntakeBreakdownCard(
        rows: loaded.intakeBreakdown,
        layoutMode: breakdownMode,
      );

      final activityCard = StatisticsWeeklyActivityCard(weekData: s);
      final insightsCard = StatisticsWeeklyInsightsCard(
        insights: loaded.weeklyInsights,
      );

      if (breakdownMode == StatisticsBreakdownLayoutMode.balanced) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 6,
              child: activityCard,
            ),
            const SizedBox(height: _cardGap),
            Expanded(
              flex: 4,
              child: breakdownCard,
            ),
            const SizedBox(height: _cardGap),
            insightsCard,
          ],
        );
      }

      // compact (0–1) or scrollable (3+)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: activityCard),
          const SizedBox(height: _cardGap),
          breakdownCard,
          const SizedBox(height: _cardGap),
          insightsCard,
        ],
      );
    }

    return const SizedBox(height: 200);
  }
}
