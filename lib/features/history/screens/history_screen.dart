import 'package:daily_water_tracker/common/widgets/app_screen_title.dart';
import 'package:daily_water_tracker/features/history/cubit/history_cubit.dart';
import 'package:daily_water_tracker/features/history/cubit/history_state.dart';
import 'package:daily_water_tracker/features/history/widgets/history_day_header.dart';
import 'package:daily_water_tracker/features/history/widgets/history_empty_state.dart';
import 'package:daily_water_tracker/features/home/coefficient_format.dart';
import 'package:daily_water_tracker/features/home/cubit/home_cubit.dart';
import 'package:daily_water_tracker/features/home/widgets/edit_water_record_sheet.dart';
import 'package:daily_water_tracker/features/home/widgets/home_today_drinks_panel.dart';
import 'package:daily_water_tracker/features/home/widgets/hydration_drink_row.dart';
import 'package:daily_water_tracker/features/home/widgets/water_progress_indicator.dart';
import 'package:daily_water_tracker/features/statistics/widgets/statistics_summary_metric_card.dart';
import 'package:daily_water_tracker/features/theme/theme_info.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, this.homeCubit});

  final HomeCubit? homeCubit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          LocaleKeys.history_title.tr(),
          style: AppScreenTitle.headerStyle(context),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<HistoryCubit, HistoryState>(
          builder: (context, state) {
            if (state.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.localizedErrorMessage(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(LocaleKeys.history_button_go_back.tr()),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: brandBlue),
              );
            }
            if (state.isEmpty) {
              return const HistoryEmptyState();
            }
            return _HistoryLogBody(
              sections: state.sections,
              dailyGoalMl: state.dailyGoalMl,
              homeCubit: homeCubit,
            );
          },
        ),
      ),
    );
  }
}

class _HistoryLogBody extends StatelessWidget {
  const _HistoryLogBody({
    required this.sections,
    required this.dailyGoalMl,
    required this.homeCubit,
  });

  final List<HistoryDaySection> sections;
  final int dailyGoalMl;
  final HomeCubit? homeCubit;

  static Color _muted(BuildContext context) =>
      WaterProgressIndicator.labelMuted.withValues(alpha: 0.95);

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final timeFormat = DateFormat('HH:mm', locale);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20, 8, 20, 24 + bottomInset),
          itemCount: sections.length,
          itemBuilder: (context, sectionIndex) {
            final section = sections[sectionIndex];
            return Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HistoryDayHeader(
                    title: _historyDayTitle(section.calendarDay),
                    totalEffectiveMl: section.totalEffectiveMl.round(),
                    dailyGoalMl: dailyGoalMl,
                  ),
                  Container(
                    width: double.infinity,
                    decoration: StatisticsSummaryMetricCard.tileDecoration(context),
                    padding: StatisticsSummaryMetricCard.tilePadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < section.entries.length; i++) ...[
                          if (i > 0)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 3),
                              child: HomeDrinksListDivider(),
                            ),
                          HydrationDrinkRow(
                            record: section.entries[i].record,
                            timeLabel: timeFormat.format(
                              section.entries[i].record.timestamp,
                            ),
                            coeffLabel: formatCoefficientUi(
                              section.entries[i].record.coefficient,
                            ),
                            mutedColor: _muted(context),
                            rowPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 8,
                            ),
                            gapAfterIcon: 12,
                            onTap: () => showEditWaterRecordSheet(
                              context,
                              record: section.entries[i].record,
                              homeCubit: homeCubit,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

String _historyDayTitle(DateTime calendarDay) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(calendarDay.year, calendarDay.month, calendarDay.day);
  if (day == today) return LocaleKeys.history_day_today.tr();
  if (day == today.subtract(const Duration(days: 1))) return LocaleKeys.history_day_yesterday.tr();
  return DateFormat('d MMM, y', Intl.getCurrentLocale()).format(day);
}
