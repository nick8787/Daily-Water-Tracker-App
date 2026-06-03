import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:daily_water_tracker/common/widgets/app_bottom_nav_bar.dart';
import 'package:daily_water_tracker/features/home/cubit/home_cubit.dart';
import 'package:daily_water_tracker/features/home/cubit/home_state.dart';
import 'package:daily_water_tracker/features/home/widgets/home_date_bar.dart';
import 'package:daily_water_tracker/features/home/widgets/home_water_card_empty.dart';
import 'package:daily_water_tracker/features/home/widgets/home_water_card_flip.dart';
import 'package:daily_water_tracker/features/theme/app_theme_extensions.dart';
import 'package:intl/intl.dart';

class HomeTabScreen extends StatelessWidget {
  const HomeTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bottomLayoutFudgePx = 25.0;
    final pillTopOffset =
        AppBottomNavBar.pillTopOffsetFromOverlayBottom(
          context,
        ) +
        bottomLayoutFudgePx;
    final screenH = MediaQuery.sizeOf(context).height;
    final cardMaxH = math.max(450.0, screenH * 0.69);
    const topBarHeight = HomeDateBar.preferredHeight;
    const minCardH = 300.0;
    const minSymmetricGap = 28.0;

    return _HomeAnchoredTodayLifecycle(
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final slot =
                        constraints.maxHeight - topBarHeight - pillTopOffset;
                    final safeSlot = math.max(0.0, slot);

                    final rawCardH = safeSlot - 2 * minSymmetricGap;
                    var cardH = math.min(
                      cardMaxH,
                      math.max(minCardH, rawCardH),
                    );
                    var gap = (safeSlot - cardH) / 2;
                    if (gap < 0) {
                      cardH = safeSlot.clamp(0.0, cardMaxH);
                      gap = (safeSlot - cardH) / 2;
                    }

                    return SizedBox(
                      height: constraints.maxHeight,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: topBarHeight,
                            child: Center(child: _TopDateBar()),
                          ),
                          SizedBox(height: gap),
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
                                        ? LocaleKeys.home_empty_today.tr()
                                        : LocaleKeys.home_empty_other_day.tr();
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
                          SizedBox(height: gap),
                          SizedBox(height: pillTopOffset),
                        ],
                      ),
                    );
                  },
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
        final dateLine = DateFormat(
          'd MMMM, y',
          locale,
        ).format(state.selectedDate);
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
