import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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

    CrashlyticsBootstrapper.wireGlobalFatalHandlers();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

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
    if (!kIsWeb) {
      FirebaseCrashlytics.instance.recordError(e, st, fatal: true);
      return;
    }
    basicRecordCrashlyticsError(e, st, reason: 'runZonedGuarded');
  });
}
