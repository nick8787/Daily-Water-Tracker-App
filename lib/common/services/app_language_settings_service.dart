import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// Opens the platform screen where the user can pick the app language
abstract final class AppLanguageSettingsService {
  static const MethodChannel _channel = MethodChannel(
    'com.dailywatertracker.app/language_settings',
  );

  static Future<bool> open() async {
    if (kIsWeb) return false;

    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod<void>('openAppLanguageSettings');
        return true;
      } on PlatformException {
        return openAppSettings();
      }
    }

    if (Platform.isIOS) {
      return openAppSettings();
    }

    return openAppSettings();
  }
}
