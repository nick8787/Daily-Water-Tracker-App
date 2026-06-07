import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_water_tracker/common/assets.dart';
import 'package:daily_water_tracker/common/utils/system_ui_overlay.dart';
import 'package:daily_water_tracker/features/app_update/cubit/app_version_cubit.dart';
import 'package:daily_water_tracker/features/app_update/models/app_version_status.dart';
import 'package:daily_water_tracker/features/deep_links/listeners/deep_link_listeners.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

import 'common/router.dart';
import 'features/theme/theme.dart';

class Application extends StatefulWidget {
  const Application({super.key});

  @override
  State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImages(context);
      precacheSvgs();

      context.read<AppVersionCubit>().initializeAndCheckVersion();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = context.select((ThemeBloc bloc) => bloc.state);
    final locale = context.locale;

    return BlocListener<AppVersionCubit, AppVersionStatus>(
      listener: _onAppVersion,
      child: MaterialApp.router(
        title: LocaleKeys.app_title.tr(),
        routerConfig: goRouter,
        theme: buildAppTheme(
          brightness: Brightness.light,
          appColors: AppColors.light,
          overlay: AppSystemUiOverlay.light,
          locale: locale,
        ),
        darkTheme: buildAppTheme(
          brightness: Brightness.dark,
          appColors: AppColors.dark,
          overlay: AppSystemUiOverlay.dark,
          locale: locale,
        ),
        themeMode: themeState.themeMode,
        themeAnimationDuration: const Duration(milliseconds: 420),
        themeAnimationCurve: Curves.easeInOutCubic,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        builder: (context, child) {
          final brightness = Theme.of(context).brightness;
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: AppSystemUiOverlay.forBrightness(brightness),
            child: DeepLinkListeners(
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }

  void _onAppVersion(BuildContext context, AppVersionStatus status) {
    if (status.isUpdateRequired) {
      goRouter.go(appUpdateRequiredRoute);
    }
  }
}
