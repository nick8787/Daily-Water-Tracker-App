// ignore_for_file: avoid_classes_with_only_static_members

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:daily_water_tracker/common/services/services.dart';
import 'package:daily_water_tracker/common/utils/app_utils.dart';
import 'package:daily_water_tracker/features/app_update/mixin/app_version_mixin.dart';
import 'package:daily_water_tracker/features/deep_links/services/water_deep_link_service.dart';
import 'package:daily_water_tracker/features/web_socket/services/web_socket_service.dart';
import 'package:daily_water_tracker/firebase/services/auth_service.dart';
import 'package:daily_water_tracker/firebase/services/local_notifications_service.dart';
import 'package:daily_water_tracker/firebase/services/remote_config_service.dart';
import 'package:daily_water_tracker/network/web_socket/web_socket_client.dart';
import 'package:get_it/get_it.dart';
import 'package:pub_semver/pub_semver.dart';

import '../../network/network.dart';
import '../../network/refresh_token/dio_token_request_retrier.dart';

part '../../network/dio_bootstrapper.dart';

class InjectorModule {
  static GetIt locator = GetIt.asNewInstance();

  static Future<void> inject() async {
    final credentials = await loadCredentials();
    GetIt.I.registerLazySingleton<Credentials>(() => credentials);

    final literalAppVersion = await getApplicationVersion();
    final currentAppVersion = Version.parse(
      literalAppVersion ?? AppVersionMixin.minFallbackVersion,
    );
    GetIt.I.registerLazySingleton<Version>(() => currentAppVersion);

    final dio = await _DioBootstrapper().setupDio(credentials: credentials);
    final webSocketClient = WebSocketClient(baseUrl: credentials.apiBaseUrl);

    locator.registerSingleton<Dio>(dio);
    locator.registerSingleton<WebSocketClient>(webSocketClient);

    locator.registerLazySingleton<AuthService>(
      () => AuthService(
        googleServerClientId: credentials.googleServerClientId,
        auth: FirebaseAuth.instance,
      ),
    );

    locator.registerLazySingleton<AnalyticsService>(
      () => AnalyticsService(
        analytics: FirebaseAnalytics.instance,
        crashlytics: FirebaseCrashlytics.instance,
      ),
    );

    locator.registerLazySingleton<LocalNotificationsService>(
      () => LocalNotificationsService(),
    );

    locator.registerLazySingleton<RemoteConfigService>(
      () => RemoteConfigService(
        remoteConfig: FirebaseRemoteConfig.instance,
      ),
    );

    locator.registerLazySingleton<WaterDeepLinkService>(
      () => WaterDeepLinkService(),
    );

    locator.registerFactory<ApiClient>(
      () => ApiClientImpl(
        dio: locator(),
      ),
    );
    locator.registerFactory<WebSocketService>(
      () => WebSocketService(
        webSocketClient: locator(),
      ),
    );
  }
}
