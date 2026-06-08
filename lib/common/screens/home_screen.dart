import 'package:daily_water_tracker/common/di/injector_module.dart';
import 'package:daily_water_tracker/common/services/analytics_service.dart';
import 'package:daily_water_tracker/common/widgets/account_signing_out_overlay.dart';
import 'package:daily_water_tracker/common/widgets/app_bottom_nav_bar.dart';
import 'package:daily_water_tracker/data/repositories/firestore_repository.dart';
import 'package:daily_water_tracker/features/account/screens/account_screen.dart';
import 'package:daily_water_tracker/features/home/cubit/home_cubit.dart';
import 'package:daily_water_tracker/features/home/screens/home_tab_screen.dart';
import 'package:daily_water_tracker/features/home/widgets/add_water_bottom_sheet.dart'
    show showAddWaterBottomSheet;
import 'package:daily_water_tracker/features/locale/widgets/locale_rebuild.dart';
import 'package:daily_water_tracker/features/main_nav/cubit/main_nav_cubit.dart';
import 'package:daily_water_tracker/features/statistics/cubit/statistics_cubit.dart';
import 'package:daily_water_tracker/features/statistics/screens/statistics_screen.dart';
import 'package:daily_water_tracker/firebase/services/reminder_scheduler_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class _AnimatedMainTabs extends StatelessWidget {
  const _AnimatedMainTabs({required this.selectedTab});

  final MainTab selectedTab;

  static const Duration _fadeDuration = Duration(milliseconds: 220);
  static const Curve _fadeCurve = Curves.easeInOutCubic;

  static const List<Widget> _tabs = [
    StatisticsScreen(embedInMainShell: true),
    HomeTabScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < _tabs.length; i++)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: selectedTab.index != i,
              child: AnimatedOpacity(
                opacity: selectedTab.index == i ? 1 : 0,
                duration: _fadeDuration,
                curve: _fadeCurve,
                child: _tabs[i],
              ),
            ),
          ),
      ],
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.initialTab = MainTab.home,
  });

  final MainTab initialTab;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MainNavCubit(initialTab: initialTab)),
        BlocProvider(
          create: (context) => HomeCubit(
            firestoreRepository: context.read<FirestoreRepository>(),
            analytics: InjectorModule.locator<AnalyticsService>(),
            reminderScheduler: context.read<ReminderSchedulerService>(),
          ),
        ),
        BlocProvider(
          create: (context) => StatisticsCubit(
            firestoreRepository: context.read<FirestoreRepository>(),
          ),
        ),
      ],
      child: BlocBuilder<MainNavCubit, MainNavState>(
        builder: (context, state) {
          return LocaleRebuild(
            builder: (context) => Scaffold(
              body: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: SafeArea(
                      bottom: false,
                      child: Stack(
                        children: [
                          _AnimatedMainTabs(selectedTab: state.tab),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: AppBottomNavBar(
                              currentTab: state.tab,
                              onSelectTab: (tab) =>
                                  context.read<MainNavCubit>().select(tab),
                              onTapAdd: () {
                                final navCubit = context.read<MainNavCubit>();
                                if (navCubit.state.tab != MainTab.home) {
                                  navCubit.select(MainTab.home);
                                  return;
                                }

                                showAddWaterBottomSheet(context);
                              },
                              onLongPressAdd: () => context
                                  .read<MainNavCubit>()
                                  .showAddComingSoon(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (state.accountSigningOutMask)
                    const AccountSigningOutOverlay(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
