import 'package:daily_water_tracker/common/di/injector_module.dart';
import 'package:daily_water_tracker/common/utils/crashlytics.dart';
import 'package:daily_water_tracker/common/utils/utils.dart';
import 'package:daily_water_tracker/features/deep_links/services/water_deep_link_service.dart';
import 'package:daily_water_tracker/firebase/services/local_notifications_service.dart';
import 'package:daily_water_tracker/firebase/services/reminder_scheduler_service.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_strategy/url_strategy.dart';

import 'localization_service.dart';
import 'logger.dart';
import 'theme_box.dart';

AppFlavor flutterFlavor = AppFlavor.dev;

class AppBootstrapper {
  Future<void> bootstrap() async {
    flutterFlavor = await AppFlavor.fromAppFlavor();

    await Firebase.initializeApp(
      options: flutterFlavor.getFirebaseOptions,
    );

    try {
      await FirebaseAppCheck.instance.activate(
        providerAndroid: kDebugMode
            ? const AndroidDebugProvider()
            : const AndroidPlayIntegrityProvider(),
        providerApple: kDebugMode
            ? const AppleDebugProvider()
            : const AppleDeviceCheckProvider(),
      );
    } catch (e, st) {
      await basicRecordCrashlyticsError(
        e,
        st,
        reason: 'FirebaseAppCheck.activate failed',
      );
    }

    await InjectorModule.inject();
    await InjectorModule.locator<WaterDeepLinkService>().captureInitialUriEarly();

    await ReminderSchedulerService.ensureTimeZonesInitialized();
    ReminderSchedulerService.logTimezoneDiagnostic();
    await InjectorModule.locator<LocalNotificationsService>().initialize(
      onNotificationTap: routeFromLocalNotificationTap,
    );
    // Reminder reschedule on cold start: PushSessionCubit.initializeColdStart().

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    await LocalizationService().initialize();
    await ThemeBox().initialize();
    await LoggerBootstrapper().setupLogger();

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    AppBlocObserver().observe();
    setPathUrlStrategy();
  }
}

Future<String?> getApplicationVersion() async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}
