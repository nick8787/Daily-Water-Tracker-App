import 'dart:io';

import 'package:daily_water_tracker/common/services/app_bootstrapper.dart';
import 'package:daily_water_tracker/common/services/logger.dart';
import 'package:daily_water_tracker/common/utils/app_flavor.dart';
import 'package:daily_water_tracker/features/app_update/models/app_version.dart';
import 'package:flutter/foundation.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:url_launcher/url_launcher.dart';

mixin AppVersionMixin {
  static const iosDevAppId = '123456789';
  static const iosProdAppId = '987654321';

  static const androidDevAppPackageName = 'com.dailywatertracker.app.dev';
  static const androidProdAppPackageName = 'com.dailywatertracker.app';

  static const iosAppStoreLinkPrefix = 'https://apps.apple.com/app/';
  static const iosTestFlightLinkPrefix =
      'itms-beta://beta.itunes.apple.com/v1/app/';

  static const androidGooglePlayLinkPrefix =
      'https://play.google.com/store/apps/details?id=';

  static const minFallbackVersion = '0.0.1';

  String getStoreId() {
    if (Platform.isIOS) {
      switch (flutterFlavor) {
        case AppFlavor.dev:
          return iosDevAppId;
        case AppFlavor.prod:
          return iosProdAppId;
      }
    }
    if (Platform.isAndroid) {
      switch (flutterFlavor) {
        case AppFlavor.dev:
          return androidDevAppPackageName;
        case AppFlavor.prod:
          return androidProdAppPackageName;
      }
    }
    throw Exception(
      'No store id found for platform: $Platform, flavor: $flutterFlavor',
    );
  }

  Future<void> launchToInstallApp({required String storeId}) async {
    try {
      String prefix = '';
      if (Platform.isAndroid) {
        prefix = androidGooglePlayLinkPrefix;
      }

      if (Platform.isIOS) {
        if (flutterFlavor.isDev) {
          prefix = iosTestFlightLinkPrefix;
        } else {
          prefix = iosAppStoreLinkPrefix;
        }
      }

      final Uri uri = Uri.parse('$prefix$storeId');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e, st) {
      logCaughtError('AppVersionMixin.openStore', e, st);
    }
  }

  bool checkIsMinVersionInstalled({
    required AppVersions appVersions,
    required Version currentAppVersion,
  }) {
    if (kIsWeb) {
      return true;
    }
    final minVersion = Platform.isAndroid
        ? appVersions.minAndroidVersion
        : appVersions.minIosVersion;

    if (minVersion == null || minVersion == Version.parse(minFallbackVersion)) {
      return true;
    }

    return minVersion <= currentAppVersion;
  }
}
