import 'package:daily_water_tracker/common/di/injector_module.dart';
import 'package:daily_water_tracker/common/services/credentials_loader.dart';
import 'package:daily_water_tracker/data/repositories/messaging_repository.dart';
import 'package:daily_water_tracker/features/app_update/cubit/app_version_cubit.dart';
import 'package:daily_water_tracker/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:daily_water_tracker/features/deep_links/cubit/deep_link_cubit.dart';
import 'package:daily_water_tracker/features/deep_links/services/water_deep_link_service.dart';
import 'package:daily_water_tracker/features/locale/cubit/locale_cubit.dart';
import 'package:daily_water_tracker/features/notifications/cubit/push_session_cubit.dart';
import 'package:daily_water_tracker/features/remote_config/cubit/remote_config_cubit.dart';
import 'package:daily_water_tracker/features/web_socket/cubit/web_socket_cubit.dart';
import 'package:daily_water_tracker/firebase/services/auth_service.dart';
import 'package:daily_water_tracker/firebase/services/local_notifications_service.dart';
import 'package:daily_water_tracker/firebase/services/reminder_scheduler_service.dart';
import 'package:daily_water_tracker/firebase/services/remote_config_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pub_semver/pub_semver.dart';

import '../../features/theme/theme.dart';
import '../services/theme_box.dart';

class GlobalBlocProvider extends StatelessWidget {
  const GlobalBlocProvider({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Add here your BLoC/Cubits you are about to use through multiple screens
        BlocProvider(
          create: (context) => LocaleCubit(),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => PushSessionCubit(
            authService: InjectorModule.locator<AuthService>(),
            messagingRepository: context.read<MessagingRepository>(),
            localNotifications:
                InjectorModule.locator<LocalNotificationsService>(),
            reminderScheduler: context.read<ReminderSchedulerService>(),
          )..start(),
          lazy: false,
        ),
        BlocProvider(
          create: (context) =>
              ThemeBloc(Hive.box(ThemeBox.name))..add(const InitTheme()),
        ),
        BlocProvider(
          create: (context) =>
              ConnectivityCubit(credentials: GetIt.I.get<Credentials>()),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => RemoteConfigCubit(
            remoteConfig: InjectorModule.locator<RemoteConfigService>(),
          ),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => DeepLinkCubit(
            service: InjectorModule.locator<WaterDeepLinkService>(),
          ),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => AppVersionCubit(
            currentAppVersion: GetIt.I.get<Version>(),
          ),
        ),
        BlocProvider(
          create: (context) =>
              WebSocketCubit(webSocketService: InjectorModule.locator()),
        ),
      ],
      child: child,
    );
  }
}
