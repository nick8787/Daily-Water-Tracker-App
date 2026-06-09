import 'package:daily_water_tracker/common/services/app_bootstrapper.dart';
import 'package:daily_water_tracker/common/services/app_build_info.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

/// Enables Crashlytics collection and attaches build context for reports.
///
/// Must run immediately after [Firebase.initializeApp].
class CrashlyticsBootstrapper {
  static Future<void> initialize() async {
    if (kIsWeb) return;

    final crashlytics = FirebaseCrashlytics.instance;
    await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
    await crashlytics.setCustomKey('app_flavor', flutterFlavor.name);
    await crashlytics.log('crashlytics_initialized');
  }

  /// Flavor/version keys that depend on DI; call after [InjectorModule.inject].
  static Future<void> attachBuildContext() async {
    if (kIsWeb) return;
    if (!GetIt.I.isRegistered<AppBuildInfo>()) return;

    final buildInfo = GetIt.I.get<AppBuildInfo>();
    await FirebaseCrashlytics.instance.setCustomKey(
      'app_version',
      buildInfo.displayLabel,
    );
  }

  /// Wires Flutter framework and async fatal handlers (call once from [main]).
  static void wireGlobalFatalHandlers() {
    if (kIsWeb) return;

    final crashlytics = FirebaseCrashlytics.instance;
    FlutterError.onError = crashlytics.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }
}
