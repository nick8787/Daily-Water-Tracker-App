import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'application.dart';
import 'common/assets.dart';
import 'common/l10n/locale_resolver.dart';
import 'common/services/services.dart';
import 'common/utils/crashlytics.dart';
import 'common/widgets/global_bloc_provider.dart';
import 'common/widgets/repository_holder.dart';
import 'features/auth/listeners/analytics_listeners.dart';
import 'features/locale/widgets/locale_listener.dart';
import 'features/notifications/listeners/push_session_listener.dart';
import 'firebase/messaging_background_handler.dart';

Future<void> main() async {
  await runZonedGuarded<Future<void>>(() async {
    final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    await AppBootstrapper().bootstrap();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FlutterError.onError = (details) {
      recordCrashlyticsError(
        details.exception,
        StackTrace.current,
        details.stack,
        reason: 'FlutterError.onError',
        message: details.exceptionAsString(),
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      recordCrashlyticsError(
        error,
        StackTrace.current,
        stack,
        reason: 'PlatformDispatcher.instance.onError',
        message: error.toString(),
      );
      return true;
    };

    final startLocale = LocaleResolver.resolveFromPlatform();

    runApp(
      EasyLocalization(
        supportedLocales: LocalizationService.supportedLocales,
        path: translationsFolderPath,
        fallbackLocale: LocalizationService.englishLocale,
        startLocale: startLocale,
        child: const RepositoriesHolder(
          child: GlobalBlocProvider(
            child: LocaleListener(
              child: PushSessionListener(
                child: AnalyticsListeners(
                  child: Application(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }, (e, st) {
    basicRecordCrashlyticsError(e, st, reason: 'runZonedGuarded');
  });
}
