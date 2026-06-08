import 'package:daily_water_tracker/features/home/cubit/home_state.dart';
import 'package:daily_water_tracker/features/home/widgets/home_date_bar.dart';
import 'package:daily_water_tracker/features/home/widgets/home_today_drinks_panel.dart';
import 'package:daily_water_tracker/features/home/widgets/water_progress_indicator.dart';
import 'package:daily_water_tracker/features/remote_config/cubit/remote_config_cubit.dart';
import 'package:daily_water_tracker/features/remote_config/models/issue_disclaimer.dart';
import 'package:daily_water_tracker/features/remote_config/widgets/issue_disclaimer_widget.dart';
import 'package:daily_water_tracker/features/theme/app_theme_extensions.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeWaterCardFlip extends StatefulWidget {
  const HomeWaterCardFlip({
    super.key,
    required this.state,
  });

  final HomeState state;

  @override
  State<HomeWaterCardFlip> createState() => _HomeWaterCardFlipState();
}

class _HomeWaterCardFlipState extends State<HomeWaterCardFlip> {
  bool _drinksPanelOpen = false;

  @override
  void didUpdateWidget(covariant HomeWaterCardFlip oldWidget) {
    super.didUpdateWidget(oldWidget);
    final dateChanged =
        oldWidget.state.selectedDate != widget.state.selectedDate;
    final becameEmpty = widget.state.records.isEmpty;
    if (dateChanged || becameEmpty) {
      if (_drinksPanelOpen) {
        setState(() => _drinksPanelOpen = false);
      }
    }
  }

  static const double _kToggleRowHeight = 22;
  static const double _kToggleLabelDy = -2.2;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final accent = context.appColors.dateBarIcon;

    final toggleLabel = _drinksPanelOpen ? LocaleKeys.home_toggle_overall_volume.tr() : LocaleKeys.home_toggle_todays_drinks.tr();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: _drinksPanelOpen
                          ? KeyedSubtree(
                              key: const ValueKey<String>('drinks_list'),
                              child: HomeTodayDrinksPanel(
                                records: state.records,
                              ),
                            )
                          : KeyedSubtree(
                              key: const ValueKey<String>('progress_ring'),
                              child: _HomeProgressWithDisclaimer(state: state),
                            ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () =>
                          setState(() => _drinksPanelOpen = !_drinksPanelOpen),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: _kToggleRowHeight,
                            child: Align(
                              child: Transform.translate(
                                offset: const Offset(0, _kToggleLabelDy),
                                child: Text(
                                  toggleLabel,
                                  textHeightBehavior: const TextHeightBehavior(
                                    applyHeightToFirstAscent: false,
                                    applyHeightToLastDescent: false,
                                  ),
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: accent,
                                        fontWeight: FontWeight.w700,
                                        height: 1.0,
                                      ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const SizedBox(
                            height: _kToggleRowHeight,
                            child: Align(
                              child: HomeDateBarChevronRight(),
                            ),
                          ),
                        ],
                      ),
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

class _HomeProgressWithDisclaimer extends StatelessWidget {
  const _HomeProgressWithDisclaimer({
    required this.state,
  });

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final issue = context.select(
      (RemoteConfigCubit cubit) =>
          cubit.state.firstForScreen(IssueDisclaimerType.home),
    );
    final progressType = context.select(
      (RemoteConfigCubit cubit) => cubit.state.progressIndicatorType,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (issue != null) IssueDisclaimerWidget(disclaimer: issue),
        Expanded(
          child: Center(
            child: WaterProgressIndicator(
              currentAmount: state.totalEffectiveMl,
              goalAmount: state.dailyLimitMl,
              type: progressType,
            ),
          ),
        ),
      ],
    );
  }
}
