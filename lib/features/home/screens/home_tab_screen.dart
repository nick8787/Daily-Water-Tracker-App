import 'dart:math' as math;

import 'package:daily_water_tracker/common/l10n/date_format_l10n.dart';
import 'package:daily_water_tracker/common/widgets/app_bottom_nav_bar.dart';
import 'package:daily_water_tracker/common/widgets/app_snackbar.dart';
import 'package:daily_water_tracker/common/widgets/main_shell_tab_body.dart';
import 'package:daily_water_tracker/features/achievements/models/achievement_definition.dart';
import 'package:daily_water_tracker/features/achievements/widgets/rank_celebration_dialog.dart';
import 'package:daily_water_tracker/features/home/cubit/home_cubit.dart';
import 'package:daily_water_tracker/features/home/cubit/home_state.dart';
import 'package:daily_water_tracker/features/home/widgets/home_date_bar.dart';
import 'package:daily_water_tracker/features/home/widgets/home_water_card_empty.dart';
import 'package:daily_water_tracker/features/home/widgets/home_water_card_flip.dart';
import 'package:daily_water_tracker/features/theme/app_theme_extensions.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeTabScreen extends StatelessWidget {
  const HomeTabScreen({super.key});

  static void _showRankRetentionTeaser(
    BuildContext context, {
    required AchievementDefinition? nextRank,
  }) {
    if (nextRank != null) {
      AppSnackBar.showRankRetentionTeaser(
        context,
        title: LocaleKeys.achievements_celebration_teaser_next_rank_title.tr(),
        message: LocaleKeys.achievements_celebration_teaser_next_rank_message.tr(
          namedArgs: {'rank': nextRank.nameKey.tr()},
        ),
      );
      return;
    }

    AppSnackBar.showRankRetentionTeaser(
      context,
      title: LocaleKeys.achievements_celebration_teaser_max_rank_title.tr(),
      message: LocaleKeys.achievements_celebration_teaser_max_rank_message.tr(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;
    final cardMaxH = math.max(450.0, screenH * 0.69);
    const topBarHeight = HomeDateBar.preferredHeight;
    const minCardH = 300.0;
    const minTopGap = AppBottomNavBar.mainShellContentBottomGap;

    return _HomeAnchoredTodayLifecycle(
      child: BlocListener<HomeCubit, HomeState>(
        listenWhen: (previous, current) =>
            previous.pendingRankCelebration != current.pendingRankCelebration &&
            current.pendingRankCelebration != null,
        listener: (context, state) async {
          final rank = state.pendingRankCelebration;
          if (rank == null) return;

          final nextRank = await RankCelebrationDialog.show(
            context,
            rank: rank,
            todayMl: state.totalRawMl,
          );
          if (!context.mounted) return;
          context.read<HomeCubit>().clearPendingRankCelebration();
          _showRankRetentionTeaser(context, nextRank: nextRank);
        },
        child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: topBarHeight,
                      child: Center(child: _TopDateBar()),
                    ),
                    Expanded(
                      child: MainShellTabBody(
                        child: LayoutBuilder(
                          builder: (context, contentConstraints) {
                            final slot = contentConstraints.maxHeight;
                            final safeSlot = math.max(0.0, slot);

                            final rawCardH = safeSlot - minTopGap;
                            var cardH = math.min(
                              cardMaxH,
                              math.max(minCardH, rawCardH),
                            );
                            var topGap = math.max(minTopGap, safeSlot - cardH);
                            if (topGap < 0) {
                              cardH = safeSlot.clamp(0.0, cardMaxH);
                              topGap = math.max(0.0, safeSlot - cardH);
                            }

                            return Column(
                              children: [
                                SizedBox(height: topGap),
                                SizedBox(
                                  height: cardH,
                                  child: Container(
                                    width: double.infinity,
                                    decoration: appCardDecoration(context),
                                    child: BlocBuilder<HomeCubit, HomeState>(
                                      builder: (context, state) {
                                        if (state.isLoading) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }

                                        if (state.records.isEmpty) {
                                          final today = DateTime(
                                            DateTime.now().year,
                                            DateTime.now().month,
                                            DateTime.now().day,
                                          );
                                          final isViewingToday =
                                              state.selectedDate == today;
                                          final emptyTitle = isViewingToday
                                              ? LocaleKeys
                                                  .home_empty_today
                                                  .tr()
                                              : LocaleKeys
                                                  .home_empty_other_day
                                                  .tr();
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 18,
                                              vertical: 10,
                                            ),
                                            child: HomeWaterCardEmpty(
                                              title: emptyTitle,
                                            ),
                                          );
                                        }

                                        return HomeWaterCardFlip(state: state);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}

class _HomeAnchoredTodayLifecycle extends StatefulWidget {
  const _HomeAnchoredTodayLifecycle({required this.child});

  final Widget child;

  @override
  State<_HomeAnchoredTodayLifecycle> createState() =>
      _HomeAnchoredTodayLifecycleState();
}

class _HomeAnchoredTodayLifecycleState
    extends State<_HomeAnchoredTodayLifecycle>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<HomeCubit>().syncAnchoredTodayIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _TopDateBar extends StatelessWidget {
  const _TopDateBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.selectedDate != current.selectedDate,
      builder: (context, state) {
        final locale = Localizations.localeOf(context).toString();
        final weekdayLine = DateFormat(
          'EEEE',
          locale,
        ).format(state.selectedDate);
        final dateLine = formatCalendarDateLine(state.selectedDate, locale);
        final cubit = context.read<HomeCubit>();

        return HomeDateBar(
          weekdayLine: weekdayLine,
          dateLine: dateLine,
          onOpenCalendar: () => _openDayPicker(context),
          onPreviousDay: cubit.goToPreviousCalendarDay,
          onNextDay: cubit.goToNextCalendarDay,
          canGoNext: cubit.canGoToNextCalendarDay,
        );
      },
    );
  }

  static Future<void> _openDayPicker(BuildContext context) async {
    final cubit = context.read<HomeCubit>();
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: cubit.state.selectedDate,
      firstDate: DateTime(2000),
      lastDate: today,
    );
    if (picked == null || !context.mounted) return;
    cubit.selectCalendarDay(picked);
  }
}
