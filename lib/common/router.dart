import 'package:daily_water_tracker/features/achievements/screens/achievements_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_water_tracker/common/screens/open_source_licenses_screen.dart';
import 'package:daily_water_tracker/common/screens/splash_screen.dart';
import 'package:daily_water_tracker/common/services/analytics_service.dart';
import 'package:daily_water_tracker/features/app_update/screens/app_update_required_screen.dart';
import 'package:daily_water_tracker/features/auth/screens/auth_gateway_screen.dart';
import 'package:daily_water_tracker/features/auth/screens/forgot_password_screen.dart';
import 'package:daily_water_tracker/features/debug/screens/debug_screen.dart';
import 'package:daily_water_tracker/features/history/cubit/history_cubit.dart';
import 'package:daily_water_tracker/features/history/screens/history_screen.dart';
import 'package:daily_water_tracker/features/home/cubit/home_cubit.dart';
import 'package:daily_water_tracker/features/main_nav/cubit/main_nav_cubit.dart';
import 'package:daily_water_tracker/features/account/screens/settings_more_screen.dart';
import 'package:daily_water_tracker/features/login_security/screens/change_password_screen.dart';
import 'package:daily_water_tracker/features/login_security/screens/login_security_screen.dart';
import 'package:daily_water_tracker/features/account/cubit/account_cubit.dart';
import 'package:daily_water_tracker/features/preferences/screens/preferences_screen.dart';
import 'package:daily_water_tracker/features/profile/screens/profile_screen.dart';
import 'package:daily_water_tracker/features/statistics/cubit/statistics_cubit.dart';
import 'package:daily_water_tracker/features/statistics/screens/statistics_screen.dart';
import 'package:daily_water_tracker/data/repositories/firestore_repository.dart';
import 'package:go_router/go_router.dart';

import '../features/achievements/cubit/achievements_cubit.dart';
import 'screens/screens.dart';
import 'widgets/page_widget.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/* * * * * * * * * * * *
*
* /home
* /pages
*     /pages/1
*     /pages/2
*     ...
*     /pages/test
*
* * * * * * * * * * * */
const String homeRoute = '/';
const String accountRoute = '/account';
const String splashRoute = '/splash';
const String loginRoute = '/login';
const String forgotPasswordRoute = '/login/forgot-password';
const String signUpRoute = '/signup';
const String debugRoute = '/debug';
const String profileRoute = '/profile';
const String preferencesRoute = '/preferences';
const String shareRoute = '/share';
const String pagesRoute = '/pages';
const String pagesDynamicRoute = ':id';
const String firstPageRoute = '/pages/1';
const String openSourceLicensesPageRoute = '/open-source-licenses';
const String appUpdateRequiredRoute = '/app-update-required-route';
const String statisticsRoute = '/statistics';
const String historyRoute = '/history';
const String settingsMoreRoute = '/account/settings-more';
const String loginSecurityRoute = '/account/login-security';
const String changePasswordRoute = '/account/login-security/change-password';
const String achievementsRoute = '/account/achievements';

final goRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: splashRoute,
  observers: AnalyticsService.navigatorObservers(),
  errorBuilder: (context, state) => ErrorScreen(state.error),
  redirect: (context, state) {
    // Defensive: if a full https:// URL slips into the router (cold start),
    // normalize it to a path-only location so routes can match.
    final uri = state.uri;
    if (uri.hasScheme && uri.scheme.startsWith('http')) {
      final normalized = Uri(
        path: uri.path.isEmpty ? '/' : uri.path,
        queryParameters: uri.queryParameters.isEmpty
            ? null
            : uri.queryParameters,
      );
      return normalized.toString();
    }
    return null;
  },
  routes: [
    GoRoute(
      path: homeRoute,
      name: 'Home',
      pageBuilder: (context, state) => _TransitionPage(
        key: state.pageKey,
        child: const HomeScreen(),
      ),
    ),
    GoRoute(
      path: accountRoute,
      name: 'AccountTab',
      pageBuilder: (context, state) => _TransitionPage(
        key: state.pageKey,
        child: const HomeScreen(initialTab: MainTab.account),
      ),
    ),
    GoRoute(
      path: splashRoute,
      name: 'Splash',
      // Use the default MaterialPage route so Hero transitions work correctly
      // when navigating from Splash -> Login.
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: loginRoute,
      name: 'Login',
      // Keep this as a default MaterialPage to preserve Hero flight animations.
      builder: (context, state) {
        final isSignUp = state.uri.queryParameters['mode'] == 'signup';
        return AuthGatewayScreen(initialSignUp: isSignUp);
      },
    ),
    GoRoute(
      path: forgotPasswordRoute,
      name: 'ForgotPassword',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        return ForgotPasswordScreen(initialEmail: email);
      },
    ),
    GoRoute(
      path: signUpRoute,
      name: 'SignUp',
      redirect: (context, state) => '$loginRoute?mode=signup',
    ),
    GoRoute(
      // Share deep link entrypoint: /share?ml=2500
      // Actual behavior is handled by app_links + DeepLinkCubit.
      path: shareRoute,
      name: 'Share',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: debugRoute,
      name: 'Debug',
      pageBuilder: (context, state) => _adaptivePushedPage(
        key: state.pageKey,
        child: const DebugScreen(),
      ),
    ),
    GoRoute(
      path: profileRoute,
      name: 'Profile',
      pageBuilder: (context, state) => _adaptivePushedPage(
        key: state.pageKey,
        child: const ProfileScreen(),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      ),
    ),
    GoRoute(
      path: statisticsRoute,
      name: 'Statistics',
      pageBuilder: (context, state) => _adaptivePushedPage(
        key: state.pageKey,
        child: BlocProvider(
          create: (context) => StatisticsCubit(
            firestoreRepository: context.read<FirestoreRepository>(),
          ),
          child: const StatisticsScreen(),
        ),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      ),
    ),
    GoRoute(
      path: historyRoute,
      name: 'History',
      pageBuilder: (context, state) {
        final homeCubit = state.extra as HomeCubit?;
        return _adaptivePushedPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (context) => HistoryCubit(
              firestoreRepository: context.read<FirestoreRepository>(),
            ),
            child: HistoryScreen(homeCubit: homeCubit),
          ),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      },
    ),
    GoRoute(
      path: preferencesRoute,
      name: 'Preferences',
      pageBuilder: (context, state) => _adaptivePushedPage(
        key: state.pageKey,
        child: const PreferencesScreen(),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      ),
    ),
    GoRoute(
      path: settingsMoreRoute,
      name: 'SettingsMore',
      pageBuilder: (context, state) {
        final accountCubit = state.extra as AccountCubit?;
        final child = accountCubit != null
            ? BlocProvider.value(
                value: accountCubit,
                child: const SettingsMoreScreen(),
              )
            : const SettingsMoreScreen();

        return _adaptivePushedPage(
          key: state.pageKey,
          child: child,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      },
    ),
    GoRoute(
      path: loginSecurityRoute,
      name: 'LoginSecurity',
      pageBuilder: (context, state) => _adaptivePushedPage(
        key: state.pageKey,
        child: const LoginSecurityScreen(),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      ),
      routes: [
        GoRoute(
          path: 'change-password',
          name: 'ChangePassword',
          pageBuilder: (context, state) => _adaptivePushedPage(
            key: state.pageKey,
            child: const ChangePasswordScreen(),
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
          ),
        ),
      ],
    ),
    GoRoute(
      path: achievementsRoute,
      name: 'Achievements',
      pageBuilder: (context, state) => _adaptivePushedPage(
        key: state.pageKey,
        child: BlocProvider(
          create: (context) => AchievementsCubit(
            firestoreRepository: context.read<FirestoreRepository>(),
          )..loadAchievements(),
          child: const AchievementsScreen(),
        ),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      ),
    ),
    GoRoute(
      path: pagesRoute,
      name: 'Pages',
      pageBuilder: (context, state) => _adaptivePushedPage(
        key: state.pageKey,
        child: const PagesListScreen(),
      ),
      routes: <RouteBase>[
        GoRoute(
          path: pagesDynamicRoute,
          name: 'PageDetail',
          // builder: (BuildContext context, GoRouterState state) {
          //   return const PageWidget();
          // },
          pageBuilder: (context, state) => _adaptivePushedPage(
            key: state.pageKey,
            child: const PageWidget(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: openSourceLicensesPageRoute,
      name: 'OpenSourceLicenses',
      pageBuilder: (context, state) => _adaptivePushedPage(
        key: state.pageKey,
        child: const OpenSourceLicensesScreen(),
      ),
    ),
    GoRoute(
      path: appUpdateRequiredRoute,
      name: 'AppUpdateRequired',
      pageBuilder: (context, state) => _adaptivePushedPage(
        key: state.pageKey,
        child: const AppUpdateRequiredScreen(),
      ),
    ),
  ],
);

/// Stack pushes opened via [context.push]: native edge-swipe back on iOS
Page<dynamic> _adaptivePushedPage({
  required LocalKey? key,
  required Widget child,
  Duration duration = const Duration(milliseconds: 300),
  Curve curve = Curves.easeOut,
}) {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
    return CupertinoPage<void>(
      key: key,
      child: child,
    );
  }
  return _TransitionPage(
    key: key,
    child: child,
    duration: duration,
    curve: curve,
  );
}

class _TransitionPage extends CustomTransitionPage<dynamic> {
  _TransitionPage({
    super.key,
    required super.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
  }) : super(
         transitionDuration: duration,
         reverseTransitionDuration: duration,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           final curved = CurvedAnimation(parent: animation, curve: curve);
           return FadeTransition(opacity: curved, child: child);
         },
         // create your own or use an existing one
         // ScaleTransition(scale: animation, child: child),
       );

  final Duration duration;
  final Curve curve;
}
